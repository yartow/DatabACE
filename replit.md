# Ceder - School Grading Management System

## Overview
A school grading management web application for an ACE/PACE curriculum school. Built with React + Express + Node.js + PostgreSQL. Role-based authentication: teachers have full CRUD, parents have read-only access.

## Features
- **Role-based authentication**: Teachers (full CRUD) and Parents (read-only access to their children)
- **Student Progress Chart (SPC)**: Visual tracking of PACE completion across subjects with bar charts
- **Term Reports**: Term-based reports with schedule data and course progress by subject group
- **Courses & PACEs**: Browse courses, PACEs, and PACE-Course links with filtering
- **Excel Import**: Upload Excel files to preview data
- **Family-based accounts**: One parent account can view all children in the same family

## Architecture
- **Frontend**: React + Tailwind CSS + Shadcn UI + Recharts + Wouter routing
- **Backend**: Express.js with Replit Auth (OpenID Connect)
- **Database**: PostgreSQL with Drizzle ORM
- **Auth**: Replit Auth integration (server/replit_integrations/auth/)

## Data Model (PACE Curriculum)
- `users` / `sessions` - Auth tables (managed by Replit Auth integration)
- `userProfiles` - Extends users with role (teacher/parent) and familyId
- `students` - Student records (id, surname, firstNames, callName, alias)
- `courses` - ACE courses with subject info, levels, PACE ranges, star values, pass thresholds (16 columns)
- `paces` - Individual PACE booklets (12 columns). No direct FK to courses.
- `paceCourses` - Intermediary table linking PACEs to Courses (paceId → paces, courseId → courses). 9 columns including creditValuePace, passThreshold, active status
- `dates` - School calendar with term/week info, holidays, weekends (10 columns)

- `enrollments` - Student-course enrollments (studentId → students, courseId → courses, dateStarted, dateEnded, grade, remarks). Auto-generated ID.

**Key constraint**: No direct FK between `paces` and `courses`. The relationship goes through `paceCourses` intermediary table.

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
- 22 students, 164 courses, 1357 PACEs, 1374 PaceCourses, 1622 dates
- Seeded from Excel file, gated to NODE_ENV !== "production"
- Some PaceCourses skipped due to missing references or duplicate IDs in source data

## API Routes
All routes prefixed with `/api/` and protected with `isAuthenticated` middleware.
- GET /api/profile, POST /api/profile - User profile management
- GET /api/students, GET /api/students/:id, POST/PATCH/DELETE /api/students/:id - Student CRUD (write ops teacher-only)
- GET /api/courses, GET /api/courses/:id - Course listing
- GET /api/paces - PACE listing
- GET /api/pace-courses?paceId=X&courseId=X - PaceCourse filtering
- GET /api/dates?term=X - Date/calendar filtering
- GET /api/enrollments?studentId=X - Get enrollments for a student
- POST /api/enrollments - Create enrollment (teacher-only)
- PATCH /api/enrollments/:id - Update enrollment (teacher-only)
- DELETE /api/enrollments/:id - Delete enrollment (teacher-only)
- GET /api/dashboard/stats - Dashboard statistics
- POST /api/upload/excel - Excel file upload and parsing (teacher-only)

## User Preferences
- App name: "Ceder"
- Progress view terminology: "Student Progress Chart" or "SPC"
- Family-based accounts (one account per family, can see all children)
- Excel import for initial data loading
- User has Figma design for term report (desktop view) - to be refined later
- SPC and materials view designs to be provided later by user
- PACE = Packet of Accelerated Christian Education (ACE curriculum)
