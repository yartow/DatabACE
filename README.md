# Ceder — School Grading Management System

A web application for managing student progress, materials, and reports at ICS De Ceder – Boskoop, an ACE/PACE curriculum school.

## Features

| Page | Description |
|---|---|
| Dashboard | Overview statistics |
| Students | Student records, families, parents, personnel |
| Enrollments | Per-student PACE enrollment management with number tracking |
| SPC | Student Progress Chart — star-based PACE progress per subject |
| Reports | Year report with PDF/print layout (Ceder letterhead) |
| Materials | Courses & PACEs — inline editing, Excel import/export |
| Inventory | Physical PACE stock tracking by location and student |
| Order Materials | Order workflow: draft → save → deliver → update inventory |
| Admin | Invitation management, user roles |

## Tech Stack

- **Frontend**: React, Tailwind CSS, Shadcn UI, Wouter, TanStack Query
- **Backend**: Express.js (Node.js)
- **Database**: PostgreSQL with Drizzle ORM
- **Auth**: Replit Auth (OpenID Connect) — invitation-only account creation
- **Exports**: Excel (xlsx), PDF (browser print)

## Roles

| Role | Access |
|---|---|
| Teacher | Full read/write access to all data |
| Parent | Read-only access to their own children's data |
| Admin | Teacher + can manage users and invitations |

## Getting Started

The app runs on Replit. The workflow `Start application` runs `npm run dev`, which starts both the Express backend and the Vite frontend on the same port.

### Database

PostgreSQL is provided via Replit's built-in database integration. Schema is managed with Drizzle ORM.

To push schema changes:
```bash
npm run db:push
```

### First Admin

After first login, set your account as admin via SQL:
```sql
UPDATE user_profiles SET is_admin = true WHERE user_id = 'YOUR_USER_ID';
```

Find your user ID:
```sql
SELECT * FROM user_profiles;
```

### Inviting Users

Admins create invitation links via the Admin page (`/admin`). Each link is valid for 7 days and pre-configures the role (teacher/parent) and optional family link.

## Data Model Highlights

- **PACE**: A packet of learning material (Packet of Accelerated Christian Education)
- **Enrollment**: One row per PACE number per student per course
- **Inventory**: Tracked by `paceVersions` (edition/type) per student or storage location
- **Inventory locations**: Student IDs 9996–9999 (Kindergarten, ABCs, Juniors, Seniors)
- **Order list**: Snapshot of what needs to be ordered; supports delivery tracking

The relationship between `paces` and `courses` goes through the `paceCourses` intermediary table — there is no direct foreign key.

## Excel Import / Export

All major tables support Excel import with conflict resolution:

| Endpoint | Description |
|---|---|
| `GET /api/courses/template` | Courses + PaceCourses templates |
| `POST /api/courses/import` | Import courses or pace-courses |
| `GET /api/inventory/template` | PaceVersions + Inventory template (pre-filled) |
| `POST /api/inventory/import` | Import pace versions and/or inventory rows |
| `GET /api/enrollments/template` | Enrollment import template |
| `POST /api/enrollments/import` | Bulk import enrollments |

## Documentation

A Dutch-language instruction manual is available at [`docs/handleiding.md`](docs/handleiding.md). It covers all pages with step-by-step instructions and screenshot placeholders.

## PWA

The app is installable as a PWA on iOS and Android home screens. Theme color: `#16a34a` (green).
