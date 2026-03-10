# Ceder - School Grading Management System

## Overview
A school grading management web application for an ACE/PACE curriculum school. Built with React + Express + Node.js + PostgreSQL. Role-based authentication: teachers have full CRUD, parents have read-only access.

## Features
- **Role-based authentication**: Teachers (full CRUD) and Parents (read-only access to their children)
- **Year Report (SPC page)**: Formal Year Report view matching Figma design — title header (logo/school/year), green info panels, category blocks with per-course term grades + PACE counts + YTD totals, behavioral assessment (In Relation to Work/Others), signature boxes. Weighted averages for category totals. Print support. Dynamic data from enrollments grouped by subjectGroup.
- **Term Reports**: Term-based reports with schedule data and course progress by subject group
- **Courses & PACEs**: Browse courses, PACEs, and PACE-Course links with filtering
- **Excel Import**: Upload Excel files to preview data
- **Family-based accounts**: One parent account can view all children in the same family
- **Enrollment management**: Course-based enrollment with optional start dates; individual PACE number tracking

## Architecture
- **Frontend**: React + Tailwind CSS + Shadcn UI + Wouter routing
- **Backend**: Express.js with Replit Auth (OpenID Connect)
- **Database**: PostgreSQL with Drizzle ORM
- **Auth**: Replit Auth integration (server/replit_integrations/auth/)

## Data Model (PACE Curriculum)
- `users` / `sessions` - Auth tables (managed by Replit Auth integration)
- `userProfiles` - Extends users with role (teacher/parent) and familyId
- `students` - Student records (auto-generated ID, surname, firstNames, callName, alias, isDyslexic, active, reasonInactive, remarks, dateOfBirth, familyId FK→families)
- `families` - Family records (id, firstName, lastName, address max 120 chars, city, postalCode)
- `personnel` - Staff records (id, firstName, lastName, group: Kindergarten/ABCs/Juniors/Seniors, type: Supervisor/Monitor/Intern/Secretary/Board Member/Principal)
- `parents` - Parent records (id, firstName, lastName, phoneNumber stored as "+31624745057" format, familyId FK→families)
- `courses` - ACE courses with subject info, levels, PACE ranges, star values, pass thresholds. Includes `icceAlias` and `certificateName`. Has `subjectId` FK to subjects table.
- `subjects` - Subject definitions with color info (id, subject, colorId, color, colorCode hex)
- `paces` - Individual PACE booklets (12 columns). No direct FK to courses.
- `paceCourses` - Intermediary table linking PACEs to Courses (paceId → paces, courseId → courses). 9 columns including creditValuePace, passThreshold, active status
- `dates` - School calendar with term/week info, holidays, weekends, yearTerm (e.g. "25–26")
- `enrollments` - Student-course enrollments with per-number tracking. Each enrollment row = one PACE number (studentId, courseId, number, dateStarted nullable, dateEnded, grade, remarks). Auto-generated ID.

**Key constraint**: No direct FK between `paces` and `courses`. The relationship goes through `paceCourses` intermediary table.

**Pass thresholds**: >= 80% for most courses; Word Building = 90% except dyslexic students get 80%.

**Subject colors**: Maths=yellow(#FFD700), Language=red(#FF0000), Word Building=purple(#800080), Literature=dark red(#8B0000), Science=blue(#0000FF), Social Studies=green(#008000), Biblical Studies=sandy orange(#F4A460), Art Electives=purple(#800080), Technology Electives=dark grey(#404040), Supplementary=white(#FFFFFF), Electives=grey(#808080)

## Key Files
- `shared/schema.ts` - All Drizzle schemas, relations, insert schemas, and types
- `shared/models/auth.ts` - Auth-specific schemas (users, sessions)
- `server/routes.ts` - All API routes with auth middleware
- `server/storage.ts` - Database storage interface and implementation
- `server/seed.ts` - Database seeding from Excel file (attached_assets/WORKBOOK_v0.3_1772895537061.xlsx)
- `client/src/App.tsx` - Main app with auth flow and routing
- `client/src/components/app-sidebar.tsx` - Navigation sidebar
- `client/src/pages/` - All page components (dashboard, spc, reports, materials, students, enrollments, import)

## Seeded Data
- 22 students, 164 courses, 1357 PACEs, 1374 PaceCourses, 1622 dates, 11 subjects
- 513 dates have yearTerm values
- Seeded from Excel file, gated to NODE_ENV !== "production"

## API Routes
All routes prefixed with `/api/` and protected with `isAuthenticated` middleware.
- GET /api/profile, POST /api/profile - User profile management
- GET /api/students, GET /api/students/:id, POST/PATCH/DELETE /api/students/:id - Student CRUD (write ops teacher-only)
- GET /api/courses, GET /api/courses/:id - Course listing
- GET /api/paces - PACE listing
- GET /api/pace-courses?paceId=X&courseId=X - PaceCourse filtering
- GET /api/subjects - All subjects with colors
- GET /api/dates?term=X - Date/calendar filtering
- GET /api/enrollments?studentId=X - Get enrollments for a student
- POST /api/enrollments/course - Create enrollment for course (teacher-only, dateStarted optional)
- PATCH /api/enrollments/:id - Update individual enrollment number (teacher-only)
- DELETE /api/enrollments/course/:studentId/:courseId - Delete all enrollment rows for a student-course pair
- DELETE /api/enrollments/:id - Delete single enrollment row (teacher-only)
- GET/POST/PATCH/DELETE /api/personnel - Personnel CRUD (teacher-only writes)
- GET/POST/PATCH/DELETE /api/families - Family CRUD (teacher-only writes)
- GET/POST/PATCH/DELETE /api/parents - Parent CRUD (teacher-only writes, phone stripped on save)
- GET /api/enrollments/template - Download Excel enrollment import template (.xlsx)
- POST /api/enrollments/import - Bulk import enrollments from Excel (teacher-only, validates student/course existence)
- GET /api/dashboard/stats - Dashboard statistics
- POST /api/upload/excel - Excel file upload and parsing (teacher-only)

## User Preferences
- App name: "Ceder"
- Progress view terminology: "Student Progress Chart" or "SPC"
- Family-based accounts (one account per family, can see all children)
- Excel import for initial data loading
- User has Figma design for term report (desktop view) - to be refined later
- PACE = Packet of Accelerated Christian Education (ACE curriculum)
