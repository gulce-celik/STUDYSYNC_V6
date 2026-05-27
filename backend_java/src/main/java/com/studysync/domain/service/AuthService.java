/* FILE PURPOSE: Is kurallari ve use-case akislari; controller ve repository arasinda orkestrasyon. */

package com.studysync.domain.service;

import com.studysync.domain.dto.LoginRequestDto;
import com.studysync.domain.dto.LoginResponseDto;
import com.studysync.domain.dto.RegisterRequestDto;
import com.studysync.domain.dto.UpdatePlannerPreferencesRequestDto;
import com.studysync.domain.dto.UpdateCoursesRequestDto;
import com.studysync.domain.dto.UserSummaryDto;
import com.studysync.domain.dto.ChangePasswordRequestDto;
import com.studysync.domain.dto.ForgotPasswordRequestDto;
import com.studysync.domain.entity.UserAccount;
import com.studysync.domain.entity.PasswordResetToken;
import com.studysync.domain.exception.EmailAlreadyExistsException;
import com.studysync.domain.exception.InvalidCredentialsException;
import com.studysync.domain.exception.InvalidDomainException;
import com.studysync.domain.exception.UserNotFoundException;
import com.studysync.domain.mapper.UserAccountMapper;
import com.studysync.domain.repository.CourseCatalogRepository;
import com.studysync.domain.repository.PasswordResetTokenRepository;
import com.studysync.domain.repository.UserAccountRepository;
import com.studysync.security.JwtTokenProvider;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;
import com.studysync.domain.entity.PendingRegistration;
import com.studysync.domain.repository.PendingRegistrationRepository;
import com.studysync.domain.dto.ActionResultDto;
import com.studysync.domain.dto.VerifyOtpRequestDto;

/**
 * Kimlik doğrulama ve kayıt — login JWT, refresh akışı, e-posta tekilliği.
 *
 * <p>
 * <b>login:</b> {@link UserAccountRepository#findByEmailIgnoreCase(String)} +
 * {@link PasswordEncoder#matches};
 * başarıda {@link com.studysync.security.JwtTokenProvider} ile tokenlar
 * (şimdilik stub string).
 *
 * <p>
 * <b>register:</b> alan doğrulama, şifre hash, {@link UserAccount} insert;
 * isteğe bağlı ders seçimleri.
 */
@Service
public class AuthService {

    private final UserAccountRepository userAccountRepository;
    private final ReferenceCatalogService referenceCatalogService;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;
    private final PendingRegistrationRepository pendingRegistrationRepository;
    private final EmailService emailService;
    private final CourseCatalogRepository courseCatalogRepository;
    private final PasswordResetTokenRepository passwordResetTokenRepository;
    private final SecureRandom secureRandom = new SecureRandom();

    public AuthService(
            UserAccountRepository userAccountRepository,
            ReferenceCatalogService referenceCatalogService,
            PasswordEncoder passwordEncoder,
            JwtTokenProvider jwtTokenProvider,
            PendingRegistrationRepository pendingRegistrationRepository,
            EmailService emailService,
            CourseCatalogRepository courseCatalogRepository,
            PasswordResetTokenRepository passwordResetTokenRepository) {
        this.userAccountRepository = userAccountRepository;
        this.referenceCatalogService = referenceCatalogService;
        this.passwordEncoder = passwordEncoder;
        this.jwtTokenProvider = jwtTokenProvider;
        this.pendingRegistrationRepository = pendingRegistrationRepository;
        this.emailService = emailService;
        this.courseCatalogRepository = courseCatalogRepository;
        this.passwordResetTokenRepository = passwordResetTokenRepository;
    }

    public LoginResponseDto login(LoginRequestDto request) {
        UserAccount userAccount = userAccountRepository.findByEmailIgnoreCase(request.email())
                .orElseThrow(InvalidCredentialsException::new);

        if (!passwordEncoder.matches(request.password(), userAccount.getPasswordHash())) {
            throw new InvalidCredentialsException();
        }

        // Antigravity Modification: Wired up secure JJWT cryptographic signing logic
        // instead of generating stub token strings.
        String accessToken = jwtTokenProvider.createAccessTokenForUserId(userAccount.getId());
        String refreshToken = jwtTokenProvider.createRefreshTokenValue();

        final UserSummaryDto summary = toSummary(userAccount);

        return new LoginResponseDto(accessToken, refreshToken, summary);
    }

    @Transactional
    public ActionResultDto register(RegisterRequestDto request) {
        if (userAccountRepository.existsByEmailIgnoreCase(request.email())) {
            throw new EmailAlreadyExistsException(request.email());
        }

        // Antigravity Modification: Hardcoded University domain rule rejection policy mapping.
        if (!request.email().trim().toLowerCase().endsWith("@std.yeditepe.edu.tr")) {
            throw new InvalidDomainException("@std.yeditepe.edu.tr");
        }

        String email = request.email().trim().toLowerCase();
        
        Optional<PendingRegistration> existingPendingOpt = pendingRegistrationRepository.findByEmailIgnoreCase(email);
        PendingRegistration pending;
        if (existingPendingOpt.isPresent()) {
            pending = existingPendingOpt.get();
            // Rate limit check: wait at least 60 seconds before sending another OTP
            if (pending.getCreatedAt().plusSeconds(60).isAfter(LocalDateTime.now())) {
                throw new RuntimeException("Lütfen yeni kod istemeden önce 60 saniye bekleyin."); // 429 logic handled by exception handler ideally
            }
        } else {
            pending = new PendingRegistration();
        }

        pending.setEmail(email);
        pending.setPasswordHash(passwordEncoder.encode(request.password()));
        pending.setName(request.name());
        pending.setNickname(request.nickname());
        pending.setDepartmentId(request.departmentId());
        pending.setYear(request.year());
        pending.setKvkkAccepted(request.kvkkAccepted());
        if (request.selectedCourseCodes() != null) {
            pending.setEnrolledCourses(new java.util.ArrayList<>(request.selectedCourseCodes()));
        }

        // Generate 6-digit OTP
        String otp = String.format("%06d", secureRandom.nextInt(1000000));
        pending.setOtpCode(otp);
        pending.setCreatedAt(LocalDateTime.now());
        pending.setExpiresAt(LocalDateTime.now().plusMinutes(5));
        pending.setAttempts(0);

        pending.setVerified(false);

        pendingRegistrationRepository.save(pending);
        emailService.sendOtpEmail(email, otp);

        return new ActionResultDto(true, "Doğrulama kodu e-posta adresinize gönderildi.", null, null);
    }

    @Transactional
    public ActionResultDto verifyOtp(VerifyOtpRequestDto request) {
        String email = request.email().trim().toLowerCase();
        PendingRegistration pending = pendingRegistrationRepository.findByEmailIgnoreCase(email)
                .orElseThrow(() -> new RuntimeException("Bekleyen kayıt bulunamadı."));

        if (pending.getAttempts() >= 3) {
            pending.setExpiresAt(LocalDateTime.now()); // Expire immediately
            pendingRegistrationRepository.save(pending);
            throw new RuntimeException("Çok fazla hatalı deneme yaptınız. Lütfen yeni kod isteyin.");
        }

        if (pending.getExpiresAt().isBefore(LocalDateTime.now())) {
            throw new RuntimeException("Doğrulama kodunun süresi dolmuş. Lütfen yeni kod isteyin.");
        }

        if (!pending.getOtpCode().equals(request.otpCode())) {
            pending.setAttempts(pending.getAttempts() + 1);
            pendingRegistrationRepository.save(pending);
            throw new RuntimeException("Geçersiz doğrulama kodu.");
        }

        pending.setVerified(true);
        pendingRegistrationRepository.save(pending);
        
        return new ActionResultDto(true, "E-posta doğrulandı.", null, null);
    }

    @Transactional
    public LoginResponseDto registerComplete(RegisterRequestDto request) {
        String email = request.email().trim().toLowerCase();
        PendingRegistration pending = pendingRegistrationRepository.findByEmailIgnoreCase(email)
                .orElseThrow(() -> new RuntimeException("Bekleyen kayıt bulunamadı."));

        if (!pending.isVerified()) {
            throw new RuntimeException("Lütfen önce e-posta adresinizi doğrulayın.");
        }

        // OTP Validated! Move to UserAccount
        UserAccount u = new UserAccount();
        u.setEmail(pending.getEmail());
        u.setPasswordHash(pending.getPasswordHash());
        u.setName(pending.getName());
        u.setNickname(request.nickname());
        u.setDepartmentId(request.departmentId());
        u.setYear(request.year());
        u.setResponsibilityScore(75);
        u.setKvkkAccepted(request.kvkkAccepted());
        if (request.selectedCourseCodes() != null) {
            u.setEnrolledCourses(new java.util.ArrayList<>(request.selectedCourseCodes()));
        }
        
        userAccountRepository.save(u);
        pendingRegistrationRepository.delete(pending);

        final UserSummaryDto summary = toSummary(u);

        String accessToken = jwtTokenProvider.createAccessTokenForUserId(u.getId());
        String refreshToken = jwtTokenProvider.createRefreshTokenValue();

        return new LoginResponseDto(accessToken, refreshToken, summary);
    }

    /** Refresh token doğrula, rotation, yeni access üret. */
    public LoginResponseDto refresh(String refreshToken) {
        throw new UnsupportedOperationException("TODO: RefreshTokenRepository + JwtTokenProvider rotation");
    }

    public UserSummaryDto getCurrentUser(UserAccount currentUser) {
        return toSummary(currentUser);
    }

    @Transactional
    public void updatePlannerPreferences(UserAccount currentUser, UpdatePlannerPreferencesRequestDto request) {
        UserAccount managed = userAccountRepository.findById(currentUser.getId())
                .orElseThrow(() -> new RuntimeException("User not found: " + currentUser.getId()));
        if (request.studyGoal() != null) {
            managed.setStudyGoal(request.studyGoal().isBlank() ? null : request.studyGoal().trim());
        }
        if (request.preferredTime() != null) {
            managed.setPreferredTime(request.preferredTime().isBlank() ? null : request.preferredTime().trim());
        }
        if (request.preferredDays() != null) {
            managed.setPreferredDays(request.preferredDays().isBlank() ? null : request.preferredDays().trim());
        }
        userAccountRepository.saveAndFlush(managed);
    }

    private UserSummaryDto toSummary(UserAccount userAccount) {
        final String deptName = referenceCatalogService
                .resolveDepartmentName(userAccount.getDepartmentId())
                .orElse(userAccount.getDepartmentId());
        return UserAccountMapper.toSummary(userAccount, deptName);
    }

    @Transactional
    public void changePassword(UserAccount currentUser, ChangePasswordRequestDto request) {
        if (!passwordEncoder.matches(request.currentPassword(), currentUser.getPasswordHash())) {
            throw new InvalidCredentialsException(); // Can reuse or create new exception
        }
        currentUser.setPasswordHash(passwordEncoder.encode(request.newPassword()));
        userAccountRepository.save(currentUser);
    }

    @Transactional
    public void updateEnrolledCourses(UserAccount currentUser, UpdateCoursesRequestDto request) {
        UserAccount managed = userAccountRepository.findById(currentUser.getId())
                .orElseThrow(() -> new RuntimeException("User not found: " + currentUser.getId()));

        List<String> incoming = request.courses() != null ? request.courses() : List.of();
        if (incoming.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Select at least one course");
        }

        Set<String> catalogCodes = courseCatalogRepository.findAll().stream()
                .map(c -> c.getCode())
                .filter(code -> code != null && !code.isBlank())
                .map(AuthService::normalizeCourseCode)
                .collect(Collectors.toSet());

        List<String> valid = new ArrayList<>();
        for (String raw : incoming) {
            if (raw == null || raw.isBlank()) {
                continue;
            }
            String normalized = normalizeCourseCode(raw);
            if (catalogCodes.contains(normalized)) {
                valid.add(normalized);
            }
        }

        if (valid.isEmpty()) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST, "Courses must exist in the system catalog");
        }

        managed.getEnrolledCourses().clear();
        managed.getEnrolledCourses().addAll(valid.stream().distinct().toList());

        userAccountRepository.saveAndFlush(managed);
    }

    @Transactional
    public void forgotPassword(ForgotPasswordRequestDto request, String backendBaseUrl) {
        String email = request.email().trim().toLowerCase();
        UserAccount user = userAccountRepository.findByEmailIgnoreCase(email)
                .orElseThrow(() -> new UserNotFoundException("No user found registered with this email address."));

        // Delete any existing tokens for this email before issuing a new OTP.
        passwordResetTokenRepository.deleteByEmailIgnoreCase(email);

        String otp = String.format("%06d", secureRandom.nextInt(1000000));
        PasswordResetToken resetToken = new PasswordResetToken(
                otp,
                email,
                LocalDateTime.now().plusMinutes(15));
        passwordResetTokenRepository.save(resetToken);

        emailService.sendPasswordResetEmail(email, otp);
    }

    @Transactional
    public void resetPassword(String token, String newPassword) {
        PasswordResetToken resetToken = passwordResetTokenRepository.findByToken(token)
                .orElseThrow(() -> new RuntimeException("Invalid or expired password reset link."));

        if (resetToken.isExpired()) {
            passwordResetTokenRepository.delete(resetToken);
            throw new RuntimeException("Password reset link has expired.");
        }

        UserAccount user = userAccountRepository.findByEmailIgnoreCase(resetToken.getEmail())
                .orElseThrow(() -> new RuntimeException("User not found."));

        user.setPasswordHash(passwordEncoder.encode(newPassword));
        userAccountRepository.save(user);
        passwordResetTokenRepository.delete(resetToken);
    }

    @Transactional
    public void resetPasswordOtp(String email, String otpCode, String newPassword) {
        String normalizedEmail = email.trim().toLowerCase();
        PasswordResetToken resetToken = passwordResetTokenRepository.findByEmailIgnoreCase(normalizedEmail)
                .orElseThrow(() -> new RuntimeException("Invalid or expired verification code."));

        if (resetToken.isExpired()) {
            passwordResetTokenRepository.delete(resetToken);
            throw new RuntimeException("Verification code has expired. Please request a new code.");
        }

        if (!resetToken.getToken().equals(otpCode.trim())) {
            throw new RuntimeException("Invalid verification code.");
        }

        UserAccount user = userAccountRepository.findByEmailIgnoreCase(normalizedEmail)
                .orElseThrow(() -> new RuntimeException("User not found."));

        user.setPasswordHash(passwordEncoder.encode(newPassword));
        userAccountRepository.save(user);
        passwordResetTokenRepository.delete(resetToken);
    }

    private static String normalizeCourseCode(String code) {
        return code.trim().toUpperCase(Locale.ROOT).replace("-", "");
    }
}
