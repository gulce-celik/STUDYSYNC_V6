package com.studysync.config;

import com.studysync.domain.entity.ReservationRecord;
import com.studysync.domain.entity.UserAccount;
import com.studysync.domain.repository.ReservationRecordRepository;
import com.studysync.domain.repository.UserAccountRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.List;

@Configuration
public class DevDataInitializer {

    @Bean
    public CommandLineRunner initDevData(UserAccountRepository userRepository, 
                                        ReservationRecordRepository reservationRepository,
                                        PasswordEncoder passwordEncoder) {
        return args -> {
            if (userRepository.count() == 0) {
                // 1. Create Fake Users
                UserAccount alice = new UserAccount();
                alice.setName("Alice Smith");
                alice.setNickname("Alice");
                alice.setEmail("alice.student@std.yeditepe.edu.tr");
                alice.setPasswordHash(passwordEncoder.encode("Password123!"));
                alice.setDepartmentId("cse");
                alice.setYear(3);
                alice.setResponsibilityScore(95);

                UserAccount bob = new UserAccount();
                bob.setName("Bob Jones");
                bob.setNickname("Bobby");
                bob.setEmail("bob.student@std.yeditepe.edu.tr");
                bob.setPasswordHash(passwordEncoder.encode("Password123!"));
                bob.setDepartmentId("ie");
                bob.setYear(2);
                bob.setResponsibilityScore(88);

                UserAccount charlie = new UserAccount();
                charlie.setName("Charlie Brown");
                charlie.setNickname("Chuck");
                charlie.setEmail("charlie.student@std.yeditepe.edu.tr");
                charlie.setPasswordHash(passwordEncoder.encode("Password123!"));
                charlie.setDepartmentId("math");
                charlie.setYear(4);
                charlie.setResponsibilityScore(72);

                userRepository.saveAll(List.of(alice, bob, charlie));

                // 2. Create Fake Reservations
                if (reservationRepository.count() == 0) {
                    java.time.LocalDate today = java.time.LocalDate.now();
                    java.time.LocalDate tomorrow = today.plusDays(1);
                    java.time.LocalDate yesterday = today.minusDays(1);
                    java.time.LocalDate nextWeek = today.plusDays(7);

                    String todayIso = today.toString();
                    String tomorrowIso = tomorrow.toString();
                    String yesterdayIso = yesterday.toString();
                    String nextWeekIso = nextWeek.toString();

                    // 1. Alice Active Today
                    ReservationRecord r1 = new ReservationRecord();
                    r1.setUser(alice); r1.setWorkspaceId("desk-5"); r1.setDate(todayIso); r1.setSlotId("slot-3"); r1.setSlotLabel("11:00 - 13:00");
                    r1.setStatus("ACTIVE"); r1.setCourseCode("CSE344"); r1.setQrPayload("QR_A1"); r1.setParticipantsJson("[]");

                    // 2. Bob Active Tomorrow
                    ReservationRecord r2 = new ReservationRecord();
                    r2.setUser(bob); r2.setWorkspaceId("desk-12"); r2.setDate(tomorrowIso); r2.setSlotId("slot-4"); r2.setSlotLabel("13:00 - 15:00");
                    r2.setStatus("ACTIVE"); r2.setCourseCode("IE202"); r2.setQrPayload("QR_B1"); r2.setParticipantsJson("[]");

                    // 3. Alice Group Tomorrow
                    ReservationRecord r3 = new ReservationRecord();
                    r3.setUser(alice); r3.setWorkspaceId("room-A"); r3.setDate(tomorrowIso); r3.setSlotId("slot-2"); r3.setSlotLabel("09:00 - 11:00");
                    r3.setStatus("ACTIVE"); r3.setCourseCode("CSE312"); r3.setQrPayload("QR_A2"); r3.setParticipantsJson("[\"Bob\", \"Charlie\"]");

                    // 4. Charlie Cancelled Past
                    ReservationRecord r4 = new ReservationRecord();
                    r4.setUser(charlie); r4.setWorkspaceId("group-1"); r4.setDate(yesterdayIso); r4.setSlotId("slot-6"); r3.setSlotLabel("17:00 - 20:00");
                    r4.setStatus("CANCELLED"); r4.setCourseCode("MATH301"); r4.setQrPayload("QR_C1"); r4.setParticipantsJson("[]");

                    // 5. Alice Completed Yesterday
                    ReservationRecord r5 = new ReservationRecord();
                    r5.setUser(alice); r5.setWorkspaceId("desk-2"); r5.setDate(yesterdayIso); r5.setSlotId("slot-1"); r5.setSlotLabel("06:00 - 09:00");
                    r5.setStatus("COMPLETED"); r5.setCourseCode("CSE211"); r5.setQrPayload("QR_A3"); r5.setParticipantsJson("[]");

                    // 6. Bob Active Next Week
                    ReservationRecord r6 = new ReservationRecord();
                    r6.setUser(bob); r6.setWorkspaceId("desk-8"); r6.setDate(nextWeekIso); r6.setSlotId("slot-3"); r6.setSlotLabel("11:00 - 13:00");
                    r6.setStatus("ACTIVE"); r6.setCourseCode("IE202"); r6.setQrPayload("QR_B2"); r6.setParticipantsJson("[]");

                    // 7. Charlie Active Today (Evening)
                    ReservationRecord r7 = new ReservationRecord();
                    r7.setUser(charlie); r7.setWorkspaceId("desk-20"); r7.setDate(todayIso); r7.setSlotId("slot-7"); r7.setSlotLabel("20:00 - 23:00");
                    r7.setStatus("ACTIVE"); r7.setCourseCode("MATH301"); r7.setQrPayload("QR_C2"); r7.setParticipantsJson("[]");

                    // 8. Bob Cancelled Today
                    ReservationRecord r8 = new ReservationRecord();
                    r8.setUser(bob); r8.setWorkspaceId("room-B"); r8.setDate(todayIso); r8.setSlotId("slot-2"); r8.setSlotLabel("09:00 - 11:00");
                    r8.setStatus("CANCELLED"); r8.setCourseCode("IE202"); r8.setQrPayload("QR_B3"); r8.setParticipantsJson("[\"Alice\"]");

                    // 9. Alice Active Today (Morning - Instant)
                    ReservationRecord r9 = new ReservationRecord();
                    r9.setUser(alice); r9.setWorkspaceId("desk-1"); r9.setDate(todayIso); r9.setSlotId("slot-1"); r9.setSlotLabel("06:00 - 09:00");
                    r9.setStatus("ACTIVE"); r9.setCourseCode("CSE331"); r9.setQrPayload("QR_A4"); r9.setParticipantsJson("[]");

                    // 10. Charlie Completed Past Week
                    ReservationRecord r10 = new ReservationRecord();
                    r10.setUser(charlie); r10.setWorkspaceId("desk-15"); r10.setDate(yesterdayIso); r10.setSlotId("slot-5"); r10.setSlotLabel("15:00 - 17:00");
                    r10.setStatus("COMPLETED"); r10.setCourseCode("MATH301"); r10.setQrPayload("QR_C3"); r10.setParticipantsJson("[]");

                    reservationRepository.saveAll(List.of(r1, r2, r3, r4, r5, r6, r7, r8, r9, r10));
                }
            }
        };
    }
}
