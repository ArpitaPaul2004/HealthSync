# HealthSync backend starter

This is a REST backend scaffold for the uploaded Flutter HealthSync app. It replaces client-only account/appointment/bed data with a shared database.

## Stack
Node.js + Express + Prisma + SQLite for local development. For production, migrate SQLite to PostgreSQL and deploy behind HTTPS.

## Setup
1. Install Node.js 20+.
2. In this folder run:
   ```bash
   npm install
   cp .env.example .env
   ```
   On Windows PowerShell, use `Copy-Item .env.example .env`.
3. Edit `.env`; set `JWT_SECRET` to a long random secret.
4. Initialize the database:
   ```bash
   npx prisma generate
   npx prisma db push
   ```
5. Start:
   ```bash
   npm run dev
   ```
6. Test `GET http://localhost:4000/api/health`.

## Main endpoints
- `POST /api/auth/register` — patient/doctor/hospital-admin registration
- `POST /api/auth/login` — returns JWT and user
- `GET /api/auth/me`, `PATCH /api/auth/me`, `PATCH /api/auth/password`
- `GET /api/doctors`, `GET /api/doctors/:id`
- `GET/POST /api/appointments`, `PATCH /api/appointments/:id/cancel`, `PATCH /api/appointments/:id/complete`
- `GET /api/hospitals`, `GET /api/hospitals/:id`, `GET /api/hospitals/:id/beds`, `POST /api/hospitals`
- `POST /api/beds/bookings`, `GET /api/beds/bookings/mine`, `PATCH /api/beds/bookings/:id/cancel`
- `GET/POST /api/prescriptions`
- `GET /api/notifications`, `PATCH /api/notifications/:id/read`

Protected endpoints require `Authorization: Bearer <token>`.

## Important limitations before production
- This is a starter backend, not a certified clinical system. Add audit logging, rate limiting, email/OTP verification, password reset, backups, encryption and monitoring before real patient use.
- Do not use this as emergency dispatch or clinical decision support without qualified review.
- The current hospital-admin/super-admin screens need additional admin APIs and role approval workflows. Super-admin accounts must be provisioned securely, not through public registration.
- File uploads for lab reports and prescriptions are not included yet; use private object storage and malware scanning, never a public folder.
- The Flutter app currently has `LocalStorageService` using SharedPreferences and some screen files are empty. These APIs will not be used until Flutter UI/service code is updated to call them through Dio.
- Bed availability is updated transactionally, but hospital setup still needs an admin endpoint to create individual bed records. Add it before relying on bed booking.
