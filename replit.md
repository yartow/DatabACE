# Ceder - School Grading Management System

## Overview
A school grading management web application with role-based authentication for teachers and parents. Built with React + Express + Node.js + PostgreSQL.

## Features
- **Role-based authentication**: Teachers (full CRUD) and Parents (read-only access to their children)
- **Student Progress Chart (SPC)**: Visual tracking of grades across subjects and terms with charts
- **Term Reports**: Detailed term-by-term report cards with scores, grades, and comments
- **Materials & Examinations**: Track course completion, exam status, and material ordering
- **Excel Import**: Upload Excel files to bulk-import grade data
- **Family-based accounts**: One parent account can view all children in the same family

## Architecture
- **Frontend**: React + Tailwind CSS + Shadcn UI + Recharts + Wouter routing
- **Backend**: Express.js with Replit Auth (OpenID Connect)
- **Database**: PostgreSQL with Drizzle ORM
- **Auth**: Replit Auth integration (server/replit_integrations/auth/)

## Data Model
- `users` / `sessions` - Auth tables (managed by Replit Auth integration)
- `userProfiles` - Extends users with role (teacher/parent) and familyId
- `families` - Groups parents and students
- `students` - Individual students belonging to families
- `subjects` - School subjects/courses
- `terms` - School terms/semesters
- `grades` - Scores per student per subject per term
- `materials` - Books/equipment per subject with ordering status
- `studentSubjects` - Enrollment linking students to subjects (tracks passed/examined)

## Key Files
- `shared/schema.ts` - All Drizzle schemas, relations, insert schemas, and types
- `shared/models/auth.ts` - Auth-specific schemas (users, sessions)
- `server/routes.ts` - All API routes with auth middleware
- `server/storage.ts` - Database storage interface and implementation
- `server/seed.ts` - Database seeding with sample data
- `client/src/App.tsx` - Main app with auth flow and routing
- `client/src/components/app-sidebar.tsx` - Navigation sidebar
- `client/src/pages/` - All page components (dashboard, spc, reports, materials, students, import)

## API Routes
All routes prefixed with `/api/` and protected with `isAuthenticated` middleware.
Teacher-only routes additionally check `profile.role === "teacher"`.

## User Preferences
- App name: "Ceder"
- Progress view terminology: "Student Progress Chart" or "SPC"
- Family-based accounts (one account per family, can see all children)
- Excel import for initial data loading
- User has Figma design for term report (desktop view) - to be refined later
- SPC and materials view designs to be provided later by user
