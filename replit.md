# Ceder - School Grading Management System

## Overview
A school grading management web application for an ACE/PACE curriculum school. Built with React + Express + Node.js + PostgreSQL. Role-based authentication: teachers have full CRUD, parents have read-only access.

## Features
- **Role-based authentication**: Teachers (full CRUD) and Parents (read-only access to their children)
- **Student Progress Chart (SPC page, /spc)**: Per-student PACE progress view with colored/grey stars showing pass/fail per PACE number, grades, and term labels. Subject color coding from subjects table.
- **Term Reports (/reports)**: Formal Year Report view matching Figma design — title header (Ceder logo/school/year), green info panels (student name+group top-left, supervisor+report date top-right), three category blocks (Academic Studies, Nederlands, Supplementary Activities), behavioral assessment (In Relation to Work/Others), signature boxes. Supervisor derived from personnel table (rank 1 for student's group). Print support.
- **Courses & PACEs (/materials)**: Browse courses, PACEs, and PACE-Course links with filtering. Teachers can: add courses with PACE numbers, edit course/PACE-course details inline, import/export Courses and PaceCourses via Excel with conflict resolution dialog, download templates.
- **Inventory (/inventory)**: Track physical PACE booklets. Grouped by PACE version (paceVersions table). Expandable rows show per-student/location breakdown. Filters by type (PACE/Score Key/Material), course, PACE number. "Show only inventory locations" checkbox filters to IDs 9996–9999. Excel import with conflict resolution. 4 virtual inventory students: IDs 9996=Kindergarten, 9997=ABCs, 9998=Juniors, 9999=Seniors (aliases INV-KG/INV-ABC/INV-JNR/INV-SNR).
- **Order Materials (/order-materials)**: Workflow for ordering PACE materials. Draft mode shows live enrollment data with columns: ID, Course, PACE #, Qty, Student, Initially to order, From Inventory, Final to order. "Hide students" checkbox collapses to grouped view summing quantities. "Add order" dialog for manual PACE/student additions. "Save order list" saves snapshot with auto-name. "Open order list" loads saved lists with Delivered checkboxes and "Process delivery" button that increments inventory for checked items. Teacher-only access.
- **Excel Import**: Upload Excel files to preview data
- **Family-based accounts**: One parent account can view all children in the same family
- **Enrollment management**: Course-based enrollment with optional start dates; individual PACE number tracking; supplementary activity enrollment (Music, Physical Education, Project, Other)

## Architecture
- **Frontend**: React + Tailwind CSS + Shadcn UI + Wouter routing
- **Backend**: Express.js with Replit Auth (OpenID Connect)
- **Database**: PostgreSQL with Drizzle ORM
- **Auth**: Replit Auth integration (server/replit_integrations/auth/)

## Data Model (PACE Curriculum)
- `users` / `sessions` - Auth tables (managed by Replit Auth integration)
- `userProfiles` - Extends users with role (teacher/parent) and familyId
- `students` - Student records (auto-generated ID, surname, firstNames, callName, alias, isDyslexic, active, reasonInactive, remarks, dateOfBirth, familyId FK→families, group: Kindergarten/ABCs/Juniors/Seniors)
- `families` - Family records (id, firstName, lastName, address max 120 chars, city, postalCode)
- `personnel` - Staff records (id, firstName, lastName, group: Kindergarten/ABCs/Juniors/Seniors, type: Supervisor/Monitor/Intern/Secretary/Board Member/Principal, rank: integer)
- `parents` - Parent records (id, firstName, lastName, phoneNumber stored as "+31624745057" format, familyId FK→families)
- `subjectGroups` - Subject group definitions (id, subjectGroup, remarks varchar(1200))
- `subjects` - Subject definitions with color info (id, subject, colorId, color, colorCode hex, subjectGroupId FK→subjectGroups)
- `courses` - ACE courses with subject info, levels, PACE ranges, star values, pass thresholds. Includes `icceAlias`, `certificateName`, and `remarks` (varchar 1000, imported from Excel Course sheet). Has `subjectId` FK to subjects table.
- `paces` - Individual PACE booklets (12 columns). No direct FK to courses.
- `paceCourses` - Intermediary table linking PACEs to Courses (paceId → paces, courseId → courses). 11 columns including creditValuePace, passThreshold, active status, starValue (smallint default 1), weight (smallint default 1). `number` is varchar(10) to support alphanumeric PACE numbers.
- `dates` - School calendar with term/week info, holidays, weekends, yearTerm (e.g. "25–26", computed from date)
- `enrollments` - Student-course enrollments with per-number tracking. Each enrollment row = one PACE number (studentId, courseId, number varchar(10), dateStarted nullable, dateEnded, grade, remarks). Auto-generated ID.
- `supplementaryActivities` - Supplementary activity enrollments (id auto, studentId FK→students, yearTerm, term, grade varchar(4), activity text)
- `paceVersions` - Physical edition versions of a PACE booklet (id auto, yearRevised, type enum "PACE"/"Score Key"/"Material", edition smallint, paceId FK→paces)
- `inventory` - Stock tracking (id auto, paceVersionsId FK→paceVersions, studentId FK→students, numberInPossession smallint). Student IDs 9996–9999 are virtual inventory locations.
- `orderLists` - Saved order list snapshots (id auto, name, term, yearTerm, createdAt timestamp)
- `orderListItems` - Individual items in an order list (id auto, orderListId FK→orderLists, paceId FK→paces nullable, courseId FK→courses nullable, enrollmentNumber, studentId FK→students, enrollmentId FK→enrollments nullable, quantity, initiallyToOrder, fromInventory, finalToOrder, delivered boolean)

**Key constraint**: No direct FK between `paces` and `courses`. The relationship goes through `paceCourses` intermediary table.

**Pass thresholds**: >= 80% for most courses; Word Building = 90% except dyslexic students get 80%.

**Subject colors**: Maths=yellow(#FFD700), Language=red(#FF0000), Word Building=purple(#800080), Literature=dark red(#8B0000), Science=blue(#0000FF), Social Studies=green(#008000), Biblical Studies=sandy orange(#F4A460), Art Electives=purple(#800080), Technology Electives=dark grey(#404040), Supplementary=white(#FFFFFF), Electives=grey(#808080)

**Report category blocks**:
- Block 1 "Academic Studies": All enrolled courses except Nederlands courses
- Block 2 "Nederlands": Only courses named "Taal", "Spelling", "Lezen", "Taal (PACE)", "Spelling (PACE)"
- Block 3 "Supplementary Activities": From supplementary_activities table (Music, Physical Education, Project, etc.), no averages

## Key Files
- `shared/schema.ts` - All Drizzle schemas, relations, insert schemas, and types
- `shared/models/auth.ts` - Auth-specific schemas (users, sessions)
- `server/routes.ts` - All API routes with auth middleware
- `server/storage.ts` - Database storage interface and implementation
- `server/seed.ts` - Database seeding from Excel file (attached_assets/WORKBOOK_v0.3_1772895537061.xlsx)
- `client/src/App.tsx` - Main app with auth flow and routing
- `client/src/components/app-sidebar.tsx` - Navigation sidebar
- `client/src/pages/` - All page components (dashboard, spc, reports, materials, students, enrollments, import, export)

## Seeded Data
- 22 students, 164 courses, 1357 PACEs, 1374 PaceCourses, 1622 dates, 11 subjects, 5 subject groups
- All dates have yearTerm values (computed from date serial: school year starts August, e.g. "22–23")
- Subject groups seeded from Course sheet SubjectGroup column
- Subjects updated with subjectGroupId from Course sheet
- Seeded from Excel file, gated to NODE_ENV !== "production"

## API Routes
All routes prefixed with `/api/` and protected with `isAuthenticated` middleware.
- GET /api/profile, POST /api/profile - User profile management
- GET /api/students, GET /api/students/:id, POST/PATCH/DELETE /api/students/:id - Student CRUD (write ops teacher-only)
- GET /api/courses, GET /api/courses/:id, PATCH /api/courses/:id - Course CRUD (write ops teacher-only)
- GET /api/paces - PACE listing
- GET /api/pace-courses?paceId=X&courseId=X, PATCH /api/pace-courses/:id - PaceCourse filtering/update (write ops teacher-only)
- GET /api/subjects - All subjects with colors
- GET /api/subject-groups - All subject groups
- GET /api/dates?term=X - Date/calendar filtering
- GET /api/enrollments?studentId=X - Get enrollments for a student (parents restricted to own family's students)
- POST /api/enrollments/course - Create enrollment for course (teacher-only, dateStarted optional)
- PATCH /api/enrollments/:id - Update individual enrollment number (teacher-only)
- DELETE /api/enrollments/course/:studentId/:courseId - Delete all enrollment rows for a student-course pair
- DELETE /api/enrollments/:id - Delete single enrollment row (teacher-only)
- GET/POST/PATCH/DELETE /api/personnel - Personnel CRUD (teacher-only writes)
- GET/POST/PATCH/DELETE /api/families - Family CRUD (teacher-only writes)
- GET/POST/PATCH/DELETE /api/parents - Parent CRUD (teacher-only writes, phone stripped on save)
- GET /api/supplementary-activities?studentId=X - Get supplementary activities (parents restricted to own family's students)
- POST/PATCH/DELETE /api/supplementary-activities - Supplementary activity CRUD (teacher-only writes)
- GET /api/enrollments/template - Download Excel enrollment import template (.xlsx)
- POST /api/enrollments/import - Bulk import enrollments from Excel (teacher-only, validates student/course existence)
- GET /api/dashboard/stats - Dashboard statistics
- POST /api/upload/excel - Excel file upload and parsing (teacher-only)
- GET /api/invitations - List all invitations (admin-only)
- POST /api/invitations - Create invitation with role/familyId/email (admin-only)
- DELETE /api/invitations/:id - Revoke invitation (admin-only)
- GET /api/invitations/redeem/:token - Validate invitation token (public)
- POST /api/invitations/redeem/:token - Redeem invitation, create profile (authenticated)
- GET /api/admin/users - List all user profiles with user info (admin-only)
- PATCH /api/admin/users/:userId - Update isAdmin flag (admin-only, can't modify self)
- DELETE /api/admin/users/:userId - Remove user profile (admin-only, can't delete self)

## Invitation System
- Account creation requires an invitation from an admin teacher
- Self-service role selection has been removed from the setup profile page
- Admin teachers can create invite links (valid 7 days) for parents and teachers
- Invite flow: Admin creates invite → copies link → shares with invitee → invitee clicks link → logs in via Replit Auth → profile auto-created with pre-configured role and family
- Admin page (/admin) accessible only to admin teachers, shows invitations tab and users tab
- Admin teachers can promote/demote other teachers to admin, delete user profiles

### Making the First Admin
Since admin status is managed manually, the first admin must be set via SQL:
```sql
UPDATE user_profiles SET is_admin = true WHERE user_id = 'YOUR_USER_ID';
```
Find your user_id by running: `SELECT * FROM user_profiles;`

## PWA & Native Feel
- PWA manifest at `client/public/manifest.json` — app is installable on iOS/Android home screens
- Icons: `icon-192.png`, `icon-512.png`, `apple-touch-icon.png` in `client/public/`
- Session duration: 30 days (configured in `server/replit_integrations/auth/replitAuth.ts`)
- Theme color: `#16a34a` (green) — matches browser chrome on mobile
- Apple meta tags for standalone mode, status bar, and app title
- Only loads Inter and Open Sans fonts (trimmed from 30+ Google Fonts)

## User Preferences
- App name: "Ceder"
- Progress view terminology: "Student Progress Chart" or "SPC"
- Family-based accounts (one account per family, can see all children)
- Excel import for initial data loading
- User has Figma design for term report (desktop view) - to be refined later
- PACE = Packet of Accelerated Christian Education (ACE curriculum)
