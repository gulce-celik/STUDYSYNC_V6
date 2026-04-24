 STUDY AREA 
SR-01 – User Authentication
The system shall allow only users with a valid university e-mail address to register and log in to the platform.         email verification  , OTP(one time password) ???

SR-02 – Data Integration from A7
The system shall retrieve faculty, department, and course information from the university’s A7 system through a Python-based web scraping module at least once per semester to ensure updated academic data. 
A7 site
↓
Python script
↓
course list çek
↓
sisteme aktar  (all departments?? Only the Engineering department??)

SR-03 – Data Storage and Formatting
The system shall store the retrieved academic data in an Excel-based structured data pool before transferring it into the main system database to minimize scheduling inconsistencies.
for manual verification before database import         (excel directly)
scrape
↓
Excel (really necessary?? Or directly to the database??) 
↓
manual check (Excel is for : data validation manual editing)
↓
database

SR-04 – Course-Syllabus Upload
The system shall allow authorized administrators to upload limited syllabus data for each course to enable topic-based matching in the Study Buddy module.   key syllabus topics
Due to access restrictions in the university systems, syllabus data will be entered manually by authorized administrators.

USER : course selection ->  topic list(admin )  -> topic selection
student interest                                                
↓               
topic embedding
↓
similarity
↓
study buddy suggestion

SR-05 – Slot Definition
The system shall divide each day into predefined reservation slots (morning, class-hour blocks, evening blocks, and night block) according to the time intervals defined in the project scope. 
 EKSİK !!!If a user fails to check in within 15 minutes, the reservation is cancelled and the slot becomes available for other users for the remaining duration.

SR-06 – Maximum Daily Reservation Limit
The system shall restrict each user to a maximum of two (2) slot reservations per day.

SR-07 – Reservation Conflict Prevention
The system shall prevent users from reserving overlapping time slots.

When to do the reservation ? CAN RESERVE FOR NEXT 3 DAYS?? Two reservation days per week

SR-08 – QR Code Check-in Requirement
The system shall require users to complete a QR-based check-in within the first 15 minutes of their reserved slot; otherwise, the reservation shall be automatically canceled.

Leave Early button  ->reputation score or extra slot or future reservation priority
student presses leave
↓
slot becomes available
↓
others can reserve ( for remaining time )

SR-09 – Group Room Validation ??? Strict
For group rooms, the system shall require each listed participant to individually complete QR check-in; if at least one participant fails to check in, the reservation shall be canceled.

SR-10 – Automatic Availability Update
The system shall automatically change the workspace status to “Available (Blue)” if a reservation is canceled due to no check-in.
Advance reservation -max 3 days ahead TWO RES DAYS PER WEEK
Daily limit -max 2 slot per day
Check-in rule 15 min->cancel
Cancel  slot   immediately available

SR-11 – Cancellation Policy Enforcement
The system shall not refund reservation points for cancellations made less than one (1) hour before the slot start time or after the slot has begun.

SR-12 – Responsibility Score Mechanism
The system shall assign and dynamically update a responsibility score for each user based on attendance behavior and rule compliance.
WHAT HAPPENS FOR 2 ATTEMPTS AT THE SAME TIME?
User clicks reserve
↓
Backend tries to insert reservation
↓
Database constraint check
↓
success → reservation created
fail → slot already taken

SR-13 – Priority Restriction Rule
The system shall limit low-responsibility-score users from making priority reservations during high-demand periods.

What are the high-demand periods? 
normal user → before 2 days reservation
high score user → before 3 days reservation
OR for under predefined scores -> decrease in reservation number e.g max 1 per week etc(EMRE)

SR-14 – Real-Time Map Visualization
The system shall provide a real-time digital map interface where workspaces are displayed as Blue (Available) or Red (Occupied).  refresh every 10 seC??

SR-15 – Active Reservation Ticket Display
The system shall generate a digital “Active Reservation Ticket” that users can display on their mobile device as proof of reservation rights.
User: Ali
Location: Study Area
Slot: 10:00 – 12:00
Seat: 12
Status: Active

SR-16 – AI-Based Course Difficulty Scoring
The system shall collect and store course difficulty ratings from students who have previously completed the course. 

USERS CAN RATE CURRENT COURSES - LIKEL TO END OF SEMESTER


SR-17 – Study Time Recommendation Engine
The AI module shall recommend a minimum number of study hours (in slot units) based on the difficulty score of the selected course.

SR-18 – Schedule-Aware Slot Suggestion
The AI module shall analyze the user’s course schedule and suggest suitable available slots that do not conflict with class hours. User course schedule ?? user enters the system?? WHy

Select times when you are NOT available USER
Monday
[ ] 08-10
[x] 10-12
[x] 12-14
[ ] 14-16

 USER : Select your courses -> CSE344 ,IE202 ,MATH301

AI
available_slots
-
unavailable_times
=
suggested_slots

Step 1 — User selects major  - > Department: Computer Engineering
Step 2 — System show related courses
Available Courses
☐ CSE344
☐ CSE331
☐ CSE312
☐ MATH301
☐ IE202
User choses courses.
☑ CSE344
☑ IE202
☑ MATH301
Bu SR-02’deki A7 data scraping ile uyumlu çünkü: course list ,department list zaten sistemde olacak.
Step 3 — Weekly time grid
User’a bir haftalık zaman tablosu gösterirsiniz.
Örnek:
       MON   TUE   WED   THU   FRI
08-10   [ ]   [ ]   [ ]   [ ]   [ ]
10-12   [X]   [ ]   [X]   [ ]   [ ]
12-14   [X]   [ ]   [ ]   [ ]   [ ]
14-16   [ ]   [ ]   [ ]   [ ]   [ ]
16-18   [ ]   [ ]   [ ]   [ ]   [ ]
User burada işaretler: X = unavailable
Buna şunlar dahil olabilir: ders saatleri , club meeting , personal time WHEN SELECTING TIMES IF COURSE FIXED CAN CHANGE IF WANTS
Böylece:
✔ Ders programını tam olarak girmesine gerek yok
 ✔ Ama sistem conflict bilgisine sahip oluyor
***AI side
AI mantığı şöyle olur:
Selected_courses + course_difficulty + unavailable_times + available_slots -> AI slot recommendation
Candidate_slots = all_slots - unavailable_times - reserved_slots Then AI: rank slots based on difficulty + user pattern
***Related parts
SR-16Course difficulty → user course selection sayesinde mümkün.
SR-17 Study time recommendation , difficulty score → recommended hours
SR-18 Schedule aware suggestionunavailable_times → conflict filtering

SR-19 – Study Buddy Matching - After selection ask collabrate or not?? 
The system shall match users who reserve the same slot and select the same course topic, enabling peer-based collaborative studying.EKSİK CÜMLE :  Study buddy groups shall be limited to a maximum of four users per group to maintain effective collaboration and align with workspace capacity.
"People studying CSE344 in this slot"

Do you want to collaborate with other students?
[ ] Yes – allow study buddy matching
[ ] No – private reservation
FINAL MODEL
USER SELECTS COURSE, 
[ ] Yes – allow study buddy matching
[ ] No – private reservation
ADS FOR MATCH SYSTEM CHOOSES UP TO HOW MANY PEOPLE(UNLIMITED), TOPIC, COURSE
ACCESS TO LIMITED PROFILE INFO MAIL , CURRENTLY TAKING COURSES
COMPLAIN 10 PEOPLE THEN NO ACCESS TO STUDY BUDDY SYSTEM FOR 1 MONTH
MATCHING WITH STUDY BUDDY
WHEN RES TIME COMES CHOOSE GROUP ROOM OR CHOOSE CLOSER TABLES 
SR-20 – Capacity Management   Study buddy: max study group size = USER SELECTS
The system shall prevent reservations exceeding the physical capacity of each workspace (group rooms and general study area).

SR-21 – Performance Requirement FastAPI / Flask + PostgreSQL
The system shall update reservation status changes (booking, cancellation, check-in) within a maximum of five (5) seconds under normal operating conditions.

SR-22 – Data Security and Privacy
The system shall store user data, academic data, and responsibility scores securely and restrict access to authorized roles only.

CANCELEDSR-23 – Administrative Monitoring Panel - ADMIN LOGIN TO SYSTEM??
The system shall provide an administrative dashboard where authorized faculty staff can monitor usage statistics, peak hours, rule violations, and overall system efficiency metrics.

same login screen+role based access+admin dashboard  ??? 2DIF UI DESIGN
Usage statistics,Peak hours,Rule violations,System efficiency metrics
Total reservations today: 124
Peak hour: 18:00–20:00
No-show rate: 12%
Most used room: Study Room B   simple booking app ❌campus management system ✅??

SR-24 – Rating HOW TO KNOW USERS PASSED COURSE END OF SEMESTER
The system shall allow users to rate classes through 1-5 stars based on difficulty level.

SR-25 – Uploading Schedule SELECT
The system shall allow users to upload their weekly schedule.

SR-26 – Study Buddy
The system shall guide students according to study buddy requirements (whether they want to indulge or not). 

SR-27 – Automated Notifications
The system shall send automated reminders to users 30 minutes before their reserved slot begins and a final warning 5 minutes before the QR check-in deadline expires. MAIL?

SR-28 – Waitlist Management
The system shall allow users to join a waitlist for a fully booked slot and automatically notify the first waitlisted user via push notification or email if a cancellation occurs.
A reservation cancelled -> NOTIFICATION TO WAITLIST -> A seat is available. But can reserve anybody user can see how many people in waitlist

HOW MANY PEOPLE IN WAITLIST 
SR-29 – Reservation Day  
The system shall open the following week's reservations on each Sunday. Twice a week

SR-30 – One Week Reservations NOT ONE WEEK
The system shall allow reservations only if they are chosen in the following week.

SR-31 – Penalty Enforcement  instant booking possible 
The system shall temporarily suspend reservation privileges (e.g., for 7 days) for users who did not show up (did not scan the QR) for their reservations at their reserved time.

SR-32 – Accessibility (WCAG Compliance)
The user interface of the platform shall comply with WCAG WEB STANDARD?? 2.1 Level AA standards to ensure basic accessibility for students with visual or physical impairments.
???Basit şeyler yeterli: butonlar büyük,contrast iyi ,ikonların label’ı var,font büyütülebiliyor
SR-33 – Various Devices 
The system shall support every device for user access. (Different screen width) NOTCOMPTER
The mobile application shall support different screen sizes
including smartphones and tablets.
The UI shall adapt to different screen widths using responsive layouts.

SR-34 – Automated Penalty Forgiveness  recovery system
The system shall implement a "Redemption Protocol" where a user's responsibility score (SR-12) naturally recovers by a fixed percentage for every 5 consecutive successful check-ins without any rule violations.

CLEAR DEF?? WHAT IS PROTOCOL : The responsibility score shall increase by 5% after every five consecutive successful check-ins without violations.

CANCELEDSR-35 – Spontaneous Extension  - PUSH NOTF CAN BE HARD ??
The system shall send a push notification 15 minutes before a session ends, allowing the user to extend their reservation by one additional slot with a single tap, provided the seat has no upcoming bookings.
Ask Attend waitlist??
Extension allowed only if: next slot is empty AND no waitlist exists IMP TO INDICATE

SR-36 – Profile Personalization
The system shall allow users to customize their profile by setting their major, default study habits (e.g., "Night Owl", "Morning Person"), and preferred study buddy topics to speed up the AI matching process. 

Preferred study time
( ) Morning Person
( ) Afternoon
( ) Night Owl

AI SUGGESTION 
Night Owl → evening slots
Morning → morning slots

Preferred Study Style
( ) Silent study
( ) Discussion-based study
( ) Problem solving together

User A → silent MATCH        User A → silent          NO
User B → silent MATCH        User B → discussion NO

Study Preference
( ) Mostly solo
( ) Sometimes group
( ) Prefer group study

Select topics you like studying with others:
[ ] Algorithms
[ ] Data Structures
[ ] Databases
[ ] Machine Learning
Preferred Study Courses
[ ] CSE344
[ ] CSE331
[ ] CSE211

Profile Settings
**Major
[Computer Engineering ▼]
**Study Habit
( ) Morning Person
( ) Night Owl
**Preferred Study Topics
[ ] Algorithms
[ ] Databases
[ ] AI
**Save
Major +  Study Style (silent / discussion) + Group Preference (solo / group)

AI PART USER SELECTS COURSE ENTERS A TOPIC ASK FOR STUDY MANAGEMENT AND RESERVATION SLOT

SR-37 – Automatic Dark Mode Switch 
The application shall automatically switch to a high-contrast dark theme during evening and night slots to reduce eye strain and minimize screen glare in dimly lit study environments.

SHOULD SELECT OTHERWISE OFF : Auto dark mode: ON/OFF
System default Light Dark

SR-38 – Digital Lost & Found Pin 
The application shall include a localized "Lost & Found" feature allowing users to digitally pin an alert to a specific workspace on the map if they realize they forgot a personal item (e.g., charger, notes) immediately after their slot ends.
IN MAP
blue = available
red = occupied
yellow = lost item
auto delete after 24 hours

EKLENMESİ GEREKENLER ?
***Sisteme kaç kişi aynı anda girebilir
Performance Requirement:
The system is designed to support up to 500 concurrent users 
performing reservation, cancellation, and check-in operations. 
Under normal operating conditions, the system shall update 
reservation status within 5 seconds.

***Sistem kaç saniye rezervasyonu tutabilir TUTMAZ(mavi koltuk rezervasyon onaylanana kadar ne kadar süre kullanıcıya ayrılıyo)










***Beraber çalışmak isteyenler nasıl birden fazla kişilik rezervasyon yapabilir ?
Organizer creates group reservation
↓
Invitations sent
↓
Participants have 10 minutes to respond
↓
System checks responses -> Reservation confirmed/cancelled.
(10 minutes expired→ reservation cancelled)
1️⃣ User group room seçer
Reserve Group Room
Capacity: 4
2️⃣ Katılımcıları ekler
Search user : Ali Yılmaz ali.yilmaz@uni.edu Computer Engineering NICK NAME 
Add participants
email:[ayse@uni.edu] veya search by name
Organizer creates reservation
↓
Invites friends
↓
Friends accept
↓
Final participant list created
↓
QR check-in required
3️⃣ Sistem rezervasyon oluşturur
reservation_id
participants = 3
room_capacity = 4
4️⃣ Slot zamanı geldiğinde herkes : QR check-in
General study area → individual reservation
Group rooms → friend group reservation 
Study Buddy → ONLY MATCHING SYSTEM
JUST TO HAVE AN IDEA ABOUT THE SYSTEM BASICS ?? 
Volere Template Requirment Types
Type	Açıklama
Functional	sistem davranışı
Non-Functional	kalite özellikleri
Constraint	teknoloji / platform sınırları
Data	veri kaynakları ve format
Business Rules	kurum politikaları
UI	arayüz davranışı
Operational	sistem operasyonu
Functional: ~22


Business Rule: ~7


Non-Functional: ~5


Data: ~2


Constraint: ~1 
Requirements Type Classification
| ID    | Requirement                        | Type           |
| SR-01 | User Authentication                | Functional     |
| SR-02 | Data Integration from A7           | Constraint     |
| SR-03 | Data Storage and Formatting        | Data           |
| SR-04 | Course-Syllabus Upload             | Functional     |
| SR-05 | Slot Definition                    | Business Rule  |
| SR-06 | Maximum Daily Reservation Limit    | Business Rule  |
| SR-07 | Reservation Conflict Prevention    | Functional     |
| SR-08 | QR Code Check-in Requirement       | Functional     |
| SR-09 | Group Room Validation              | Functional     |
| SR-10 | Automatic Availability Update      | Functional     |
| SR-11 | Cancellation Policy Enforcement    | Business Rule  |
| SR-12 | Responsibility Score Mechanism     | Functional     |
| SR-13 | Priority Restriction Rule          | Business Rule  |
| SR-14 | Real-Time Map Visualization        | Functional     |
| SR-15 | Active Reservation Ticket Display  | Functional     |
| SR-16 | AI-Based Course Difficulty Scoring | Data           |
| SR-17 | Study Time Recommendation Engine   | Functional     |
| SR-18 | Schedule-Aware Slot Suggestion     | Functional     |
| SR-19 | Study Buddy Matching               | Functional     |
| SR-20 | Capacity Management                | Functional     |
| SR-21 | Performance Requirement            | Non-Functional |
| SR-22 | Data Security and Privacy          | Non-Functional |
| SR-23 | Administrative Monitoring Panel    | Functional     |
| SR-24 | Rating                             | Functional     |
| SR-25 | Uploading Schedule                 | Functional     |
| SR-26 | Study Buddy Guidance               | Functional     |
| SR-27 | Automated Notifications            | Functional     |
| SR-28 | Waitlist Management                | Functional     |
| SR-29 | Reservation Day                    | Business Rule  |
| SR-30 | One Week Reservations              | Business Rule  |
| SR-31 | Penalty Enforcement                | Business Rule  |
| SR-32 | Accessibility (WCAG)               | Non-Functional |
| SR-33 | Various Devices                    | Non-Functional |
| SR-34 | Automated Penalty Forgiveness      | Business Rule  |
| SR-35 | Spontaneous Extension              | Functional     |
| SR-36 | Profile Personalization            | Functional     |
| SR-37 | Automatic Dark Mode Switch         | Non-Functional |
| SR-38 | Digital Lost & Found Pin           | Functional     |

1️⃣ System capacity (scalability)
The system shall support at least 100/500 concurrent users.
Non-Functional (performance/scalability) 
G
3️⃣ Group reservation mechanism
The system shall allow users to create group reservations and invite participants.


