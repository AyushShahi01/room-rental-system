# Smart Room Renting System — Backend Remaining Work Plan

> **Last Updated:** 2026-05-31  
> **Estimated Total Effort:** ~8–11 days  
> **Status Legend:** ⬜ Not Started · 🔄 In Progress · ✅ Done

---

## Sprint 1: Core Business Logic Fixes (Day 1)

Quick wins that fix critical business logic already in the codebase.

### 1.1 Auto-flip Room Availability on Booking State Changes
- ⬜ In `BookingApproveView.patch()` — set `booking.room.is_available = False` and save
- ⬜ In `BookingCancelView.patch()` — set `booking.room.is_available = True` and save (only if it was previously approved)
- ⬜ In `BookingRejectView.patch()` — no room change needed (room was never marked unavailable for pending bookings)
- ⬜ Add unit tests for all state transitions

**Files to modify:**
- `bookings/views.py`
- `bookings/tests.py`

---

### 1.2 Restrict Agreement Creation to Landlords Only
- ⬜ Add landlord role check in `AgreementListCreateView.perform_create()`
- ⬜ Verify tenant can only sign, not create

**Files to modify:**
- `agreements/views.py`

---

### 1.3 Add Missing Timestamp Fields to All Models
- ⬜ `Booking` — add `created_at = DateTimeField(auto_now_add=True)`
- ⬜ `Agreement` — add `created_at` and `signed_at = DateTimeField(null=True, blank=True)`
- ⬜ `Payment` — add `created_at = DateTimeField(auto_now_add=True)`
- ⬜ `MaintenanceRequest` — add `created_at = DateTimeField(auto_now_add=True)`
- ⬜ `Message` — add `created_at = DateTimeField(auto_now_add=True)`
- ⬜ `Notification` — add `created_at = DateTimeField(auto_now_add=True)`
- ⬜ Update all serializers to include `created_at` in fields
- ⬜ Run `python manage.py makemigrations` and `migrate`

**Files to modify:**
- `bookings/models.py`, `bookings/serializers.py`
- `agreements/models.py`, `agreements/serializers.py`
- `payments/models.py`, `payments/serializers.py`
- `maintenance/models.py`, `maintenance/serializers.py`
- `messaging/models.py`, `messaging/serializers.py`
- `notifications/models.py`, `notifications/serializers.py`

---

## Sprint 2: Maintenance Photo Upload & Messaging Improvements (Day 2)

### 2.1 Add Image Support to Maintenance Requests
- ⬜ Add `image = ImageField(upload_to='maintenance/images/', null=True, blank=True)` to `MaintenanceRequest` model
- ⬜ Update `MaintenanceSerializer` to include `image` field
- ⬜ Update `MaintenanceListCreateView` to handle multipart form data
- ⬜ Run migrations

**Files to modify:**
- `maintenance/models.py`
- `maintenance/serializers.py`
- `maintenance/views.py`

---

### 2.2 Message Thread Filtering
- ⬜ Add `recipient_id` query parameter filtering in `MessageListCreateView.get_queryset()`
- ⬜ Add conversation list endpoint — unique conversation partners for the authenticated user
- ⬜ Ensure messages are ordered by `created_at` (after Sprint 1.3 adds the field)

**Files to modify:**
- `messaging/views.py`
- `messaging/urls.py`

---

### 2.3 Add `admin` Role to User Model
- ⬜ Add `ADMIN = 'admin', 'Admin'` to `CustomUser.Role` choices
- ⬜ Run migrations

**Files to modify:**
- `users/models.py`

---

### 2.4 Create Formal Permission Classes
- ⬜ Create `users/permissions.py` with `IsTenant`, `IsLandlord`, `IsAdmin` classes
- ⬜ Refactor existing inline role checks in views to use these permission classes

**Files to create:**
- `users/permissions.py`

**Files to modify:**
- `rooms/views.py`
- `bookings/views.py`
- `agreements/views.py`
- `maintenance/views.py`

---

## Sprint 3: Dynamic Agreement Templates (Day 3)

### 3.1 Agreement Content Auto-Generation
- ⬜ Create a utility function `generate_agreement_content(booking)` that merges:
  - Tenant name, Landlord name
  - Room title, price, ward number, province
  - Security deposit, maintenance charges
  - Current date
- ⬜ Use a text template (string or Django template)
- ⬜ Allow landlord to pass `content` to override, or leave blank for auto-generation
- ⬜ Update `AgreementListCreateView.perform_create()` to call the generator
- ⬜ Set `signed_at` timestamp when `SignAgreementView` is called

**Files to create:**
- `agreements/utils.py`

**Files to modify:**
- `agreements/views.py`
- `agreements/serializers.py`

---

## Sprint 4: Khalti Payment Gateway Integration (Days 4–5)

### 4.1 Extend Payment Model
- ⬜ Add `payment_gateway` field — choices: `khalti`, `esewa`, `manual`
- ⬜ Add `transaction_token` field — `CharField(max_length=255, null=True, blank=True)`
- ⬜ Add `gateway_response` field — `JSONField(null=True, blank=True)` to store raw callback data
- ⬜ Update serializer to include new fields
- ⬜ Run migrations

**Files to modify:**
- `payments/models.py`
- `payments/serializers.py`

---

### 4.2 Khalti Verification Endpoint
- ⬜ Read Khalti API docs (https://docs.khalti.com/)
- ⬜ Add `KHALTI_SECRET_KEY` to `.env` and `settings.py`
- ⬜ Create `KhaltiVerifyView` at `POST /api/payments/khalti/verify/`
  - Accept `token`, `amount`, `booking_id`
  - Call Khalti's lookup/verify API server-side
  - Create/update Payment record with `status=verified` or `status=failed`
  - Store Khalti response in `gateway_response`
- ⬜ Add unit tests with mocked Khalti API responses

**Files to create:**
- `payments/gateways/__init__.py`
- `payments/gateways/khalti.py`

**Files to modify:**
- `payments/views.py`
- `payments/urls.py`
- `.env`, `.env.example`
- `project/settings.py`

---

### 4.3 eSewa Verification Endpoint
- ⬜ Read eSewa API docs (https://developer.esewa.com.np/)
- ⬜ Add `ESEWA_SECRET_KEY` / `ESEWA_PRODUCT_CODE` to `.env` and `settings.py`
- ⬜ Create `EsewaVerifyView` at `POST /api/payments/esewa/verify/`
  - Accept `transaction_code`, `amount`, `booking_id`
  - Call eSewa's transaction verification API
  - Create/update Payment record accordingly
- ⬜ Add unit tests with mocked eSewa API responses

**Files to create:**
- `payments/gateways/esewa.py`

**Files to modify:**
- `payments/views.py`
- `payments/urls.py`
- `.env`, `.env.example`
- `project/settings.py`

---

## Sprint 5: Auto-Notifications on Events (Day 6)

### 5.1 Create Notification Helper
- ⬜ Create `notifications/helpers.py` with a `create_notification(user, content)` utility
- ⬜ This function creates a DB `Notification` record (and later triggers FCM push)

**Files to create:**
- `notifications/helpers.py`

---

### 5.2 Wire Notifications into Business Events
- ⬜ **Booking approved** → notify tenant: "Your booking for {room} has been approved!"
- ⬜ **Booking rejected** → notify tenant: "Your booking for {room} has been rejected."
- ⬜ **Booking created** → notify landlord: "New booking request from {tenant} for {room}."
- ⬜ **Booking cancelled** → notify landlord: "Booking for {room} has been cancelled."
- ⬜ **Payment created** → notify landlord: "Payment of NPR {amount} received for {room}."
- ⬜ **Payment verified** → notify tenant: "Your payment of NPR {amount} has been verified."
- ⬜ **Agreement created** → notify tenant: "A lease agreement has been created for your booking."
- ⬜ **Agreement signed** → notify landlord: "Tenant has signed the lease agreement."
- ⬜ **Maintenance created** → notify landlord: "New maintenance request for {room}."
- ⬜ **Maintenance status updated** → notify tenant: "Your maintenance request status: {status}."
- ⬜ **New message** → notify receiver: "New message from {sender}."

**Files to modify:**
- `bookings/views.py`
- `payments/views.py`
- `agreements/views.py`
- `maintenance/views.py`
- `messaging/views.py`

---

## Sprint 6: Firebase Cloud Messaging (Days 7–8)

### 6.1 FCM Setup
- ⬜ Install `firebase-admin` package and add to `requirements.txt`
- ⬜ Create Firebase project and download service account JSON
- ⬜ Add `FIREBASE_CREDENTIALS_PATH` to `.env`
- ⬜ Initialize Firebase Admin SDK in a `notifications/firebase.py` module

**Files to create:**
- `notifications/firebase.py`

**Files to modify:**
- `requirements.txt`
- `.env`, `.env.example`

---

### 6.2 FCM Device Token Management
- ⬜ Add `fcm_token = CharField(max_length=255, null=True, blank=True)` to `CustomUser` model
- ⬜ Create `POST /api/auth/device-token/` endpoint for Flutter app to register/update the device token
- ⬜ Run migrations

**Files to modify:**
- `users/models.py`
- `users/views.py`
- `users/urls.py`
- `users/serializers.py`

---

### 6.3 Push Notification Dispatch
- ⬜ Extend `notifications/helpers.py` → after creating DB notification, also call `firebase.send_push(user.fcm_token, content)` if token exists
- ⬜ Handle FCM errors gracefully (invalid token cleanup, etc.)
- ⬜ Test with a real Flutter device

**Files to modify:**
- `notifications/helpers.py`
- `notifications/firebase.py`

---

## Sprint 7: OTP Verification & Remaining Polish (Days 9–10)

### 7.1 OTP Email Verification
- ⬜ Create `OTP` model — `user (FK)`, `code (CharField)`, `created_at`, `expires_at`, `is_used`
- ⬜ Create `POST /api/auth/otp/send/` — generates 6-digit code, sends via email
- ⬜ Create `POST /api/auth/otp/verify/` — validates code and activates user
- ⬜ Optionally set new users `is_active = False` until OTP verified

**Files to create:**
- `users/otp_models.py` (or add to `users/models.py`)

**Files to modify:**
- `users/views.py`
- `users/urls.py`
- `users/serializers.py`

---

### 7.2 Monthly Rent Invoice Auto-Generation (Optional/Stretch)
- ⬜ Install `django-celery-beat` or use Django management command + cron
- ⬜ Create a task that scans all active bookings monthly
- ⬜ Auto-create `Payment` records with `status=pending` for each active lease
- ⬜ Trigger notification to tenant with amount due

**Files to create:**
- `payments/tasks.py` or `payments/management/commands/generate_invoices.py`

**Files to modify:**
- `requirements.txt`
- `project/settings.py`

---

### 7.3 Rent-Due Cron Job (Optional/Stretch)
- ⬜ Daily management command to scan overdue pending payments
- ⬜ Send push notification warning to tenants with overdue payments

**Files to create:**
- `payments/management/commands/check_overdue_payments.py`

---

### 7.4 URL Alignment with PRD
- ⬜ Add `/api/payments/history/` alias (or rename `my-payments`)
- ⬜ Add `/api/rooms/` `city` query parameter filter
- ⬜ Verify all endpoint paths match PRD §9

**Files to modify:**
- `payments/urls.py`
- `rooms/views.py`

---

## Sprint 8: Final Verification & Deployment Check (Day 11)

### 8.1 Write Missing Tests
- ⬜ `agreements/tests.py` — test CRUD, sign, landlord-only creation
- ⬜ `maintenance/tests.py` — test CRUD, status transitions, image upload
- ⬜ `messaging/tests.py` — test send, thread filter, mark-read
- ⬜ `notifications/tests.py` — test list, mark-read, auto-creation

---

### 8.2 Production Readiness
- ⬜ Run `python manage.py check --deploy` and fix all warnings
- ⬜ Run full test suite: `python manage.py test`
- ⬜ Verify Docker build: `docker-compose up --build`
- ⬜ Test all API endpoints via Swagger UI (`/api/docs/swagger/`)
- ⬜ Update `API_DOCUMENTATION.md` with new endpoints

---

## Visual Sprint Timeline

```
Week 1                              Week 2
┌─────┬─────┬─────┬─────┬─────┐   ┌─────┬─────┬─────┬─────┬─────┐
│ D1  │ D2  │ D3  │ D4  │ D5  │   │ D6  │ D7  │ D8  │ D9  │ D10 │  D11
│     │     │     │     │     │   │     │     │     │     │     │
│Core │Maint│Agree│◄─Khalti──►│   │Noti-│◄──FCM────►│OTP &│Cron │ Test
│Logic│Photo│Temp-│  & eSewa  │   │fica-│  Push     │Poli-│Jobs │  &
│Fixes│Msg  │late │ Gateway   │   │tions│  Notifs   │sh   │     │ Ship
│     │Perms│     │ Integrate │   │Auto │           │     │     │
└─────┴─────┴─────┴─────┴─────┘   └─────┴─────┴─────┴─────┴─────┘
```

---

## Quick Reference: New Files to Create

| File | Sprint | Purpose |
|:---|:---:|:---|
| `users/permissions.py` | 2 | `IsTenant`, `IsLandlord`, `IsAdmin` classes |
| `agreements/utils.py` | 3 | Agreement template generator |
| `payments/gateways/__init__.py` | 4 | Payment gateway package |
| `payments/gateways/khalti.py` | 4 | Khalti API integration |
| `payments/gateways/esewa.py` | 4 | eSewa API integration |
| `notifications/helpers.py` | 5 | Notification creation utility |
| `notifications/firebase.py` | 6 | FCM SDK initialization & dispatch |
| `payments/management/commands/generate_invoices.py` | 7 | Monthly invoice cron |
| `payments/management/commands/check_overdue_payments.py` | 7 | Overdue payment alerts |
