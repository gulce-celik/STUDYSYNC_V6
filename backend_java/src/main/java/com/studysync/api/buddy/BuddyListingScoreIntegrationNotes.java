/* SPEC ONLY — this class is not a Spring bean and is not referenced. Backend teammates: implement
 * the described pieces elsewhere and delete or trim this file when done. */

package com.studysync.api.buddy;

/**
 * Study Buddy “post listing” × responsibility score — what to add on the server (EN).
 *
 * <h2>Context</h2>
 * The mobile app may apply a <strong>local</strong> score penalty when the user posts a listing.
 * Production should mirror that in the database via {@link
 * com.studysync.domain.service.ResponsibilityScoreService}.
 *
 * <h2>REST (suggested; align with your {@code /api/v1/...} conventions)</h2>
 * <ul>
 *   <li><strong>POST</strong> {@code /api/v1/study-buddies/listings} (or {@code /study-buddy/listings})
 *   <li>Auth: JWT, current user only
 *   <li>Request body: {@code courseCode} (string), {@code purpose} (string/enum: exam, project, …),
 *   optional {@code preferredWeekday}, optional campus {@code slotId} or time label, optional {@code note}
 *   <li>Response: e.g. listing id + <strong>updated</strong> {@code responsibilityScore}, or 4xx if limit/score
 *   blocks the action
 * </ul>
 *
 * <h2>Responsibility score</h2>
 * <ul>
 *   <li>On success: {@code applyDelta(userId, -1)} (tune; mobile demo uses −1 per post to avoid harsh drops)
 *   <li>Clamp final score 0–100 (existing user column)
 *   <li>Reject if score would go below a policy floor, or if user exceeded rate limit (e.g. max 2
 *   listings per 7 days — match product; not implemented on mobile as persistence)
 * </ul>
 *
 * <h2>Data (optional but useful)</h2>
 * <ul>
 *   <li>New entity/table for listings: user id, timestamps, course, purpose, optional slot/day, for
 *   rate limiting and analytics
 *   <li>Alternatively policy-only: no new table, only score delta + log line (weaker for abuse
 *   investigation)
 * </ul>
 *
 * <h2>Downstream</h2>
 * <ul>
 *   <li>GET /dashboard/home already returns {@code responsibilityScore}; no DTO change if the column
 *   is updated in the same transaction
 *   <li>Server-side “70+ to reserve” (when you enforce it) should use the same stored score
 *   <li>After API exists, Flutter can POST first, then refresh dashboard and drop the local-only
 *   {@code ResponsibilityLedger} penalty for that action
 * </ul>
 *
 * <h2>Where to implement (typical layout in this project)</h2>
 * <ul>
 *   <li>New/extended REST class next to this package’s controller(s)
 *   <li>Service: delegate score to {@code ResponsibilityScoreService}; add listing create + limits
 *   in {@code StudyBuddyService} or a new {@code BuddyListingService}
 *   <li>Policy: consider a small policy class (similar in spirit to {@code
 *   com.studysync.domain.policy.CancellationScoringPolicy}) for delta + cap constants
 * </ul>
 */
public final class BuddyListingScoreIntegrationNotes {

  private BuddyListingScoreIntegrationNotes() {}
}
