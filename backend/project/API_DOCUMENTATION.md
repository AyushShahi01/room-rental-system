# 🔐 Authentication API Documentation

**Base URL:** `http://localhost:8000/api/auth`  
**Content-Type:** `application/json`  
**Auth Header:** `Authorization: Bearer <access_token>`

---

## Endpoints Overview

| Method | Endpoint                | Auth | Description                     |
| ------ | ----------------------- | :--: | ------------------------------- |
| POST   | `/register/`            |  ❌  | Register a new user             |
| POST   | `/login/`               |  ❌  | Login and receive JWT tokens    |
| POST   | `/logout/`              |  ✅  | Blacklist refresh token         |
| POST   | `/refresh/`             |  ❌  | Refresh access token            |
| GET    | `/me/`                  |  ✅  | Get current user profile        |
| POST   | `/verify-email/`        |  ❌  | Verify email with OTP           |
| POST   | `/resend-verification/` |  ❌  | Resend verification OTP         |
| POST   | `/forgot-password/`     |  ❌  | Request password reset OTP      |
| POST   | `/reset-password/`      |  ❌  | Reset password with OTP         |
| POST   | `/change-password/`     |  ✅  | Change password (authenticated) |

---

## 1. Register

Create a new user account. Sends an email verification OTP automatically.

**`POST /api/auth/register/`**

### Request Body

| Field      | Type   | Required | Description                                     |
| ---------- | ------ | :------: | ----------------------------------------------- |
| `username` | string |    ✅    | Unique username                                 |
| `email`    | string |    ✅    | Valid email address                             |
| `role`     | string |    ❌    | One of: `tenant`, `landlord`. Default: `tenant` |
| `password` | string |    ✅    | Min 8 characters, must pass Django validators   |

### Example Request

```json
{
  "username": "john_doe",
  "email": "john@example.com",
  "role": "tenant",
  "password": "StrongPass123!"
}
```

### Success Response — `201 Created`

```json
{
  "message": "Registration successful.",
  "tokens": {
    "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
  },
  "user": {
    "id": 1,
    "username": "john_doe",
    "email": "john@example.com",
    "first_name": "",
    "last_name": "",
    "role": "tenant",
    "tenant_id": 1,
    "landlord_id": null
  }
}
```

### Error Response — `400 Bad Request`

```json
{
  "username": ["A user with that username already exists."],
  "role": ["\"tenent\" is not a valid choice."],
  "password": ["This password is too common."]
}
```

---

## 2. Login

Authenticate and receive JWT token pair. Records login history and device info.

**`POST /api/auth/login/`**

### Request Body

| Field             | Type   | Required | Description                      |
| ----------------- | ------ | :------: | -------------------------------- |
| `usernameOrEmail` | string |   ✅\*   | Username or registered email     |
| `username`        | string |    ❌    | Legacy username-only login field |
| `email`           | string |    ❌    | Legacy email-only login field    |
| `password`        | string |    ✅    | Account password                 |

### Example Request

```json
{
  "usernameOrEmail": "john@example.com",
  "password": "StrongPass123!"
}
```

### Success Response — `200 OK`

```json
{
  "message": "Login successful.",
  "tokens": {
    "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
  },
  "user": {
    "id": 1,
    "username": "john_doe",
    "email": "john@example.com",
    "first_name": "",
    "last_name": "",
    "role": "tenant",
    "tenant_id": 1,
    "landlord_id": null
  }
}
```

### Error Response — `401 Unauthorized`

```json
{
  "errors": {
    "non_field_errors": ["Invalid email or password."]
  }
}
```

---

## 3. Logout

Blacklist the refresh token to invalidate the session.

**`POST /api/auth/logout/`** 🔒 _Requires Authentication_

### Request Body

| Field     | Type   | Required | Description                    |
| --------- | ------ | :------: | ------------------------------ |
| `refresh` | string |    ✅    | The refresh token to blacklist |

### Example Request

```json
{
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

### Success Response — `200 OK`

```json
{
  "message": "Logged out successfully."
}
```

### Error Response — `400 Bad Request`

```json
{
  "non_field_errors": ["Invalid or expired refresh token."]
}
```

---

## 4. Refresh Token

Get a new access token using a valid refresh token. The old refresh token is blacklisted and a new one is returned (rotation enabled).

**`POST /api/auth/refresh/`**

### Request Body

| Field     | Type   | Required | Description         |
| --------- | ------ | :------: | ------------------- |
| `refresh` | string |    ✅    | Valid refresh token |

### Example Request

```json
{
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

### Success Response — `200 OK`

```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

### Error Response — `401 Unauthorized`

```json
{
  "detail": "Token is blacklisted",
  "code": "token_not_valid"
}
```

---

## 5. Me (Current User)

Get the authenticated user's profile.

**`GET /api/auth/me/`** 🔒 _Requires Authentication_

### Success Response — `200 OK`

```json
{
  "id": 1,
  "username": "john_doe",
  "email": "john@example.com",
  "first_name": "",
  "last_name": "",
  "role": "tenant",
  "tenant_id": 1,
  "landlord_id": null
}
```

### Error Response — `401 Unauthorized`

```json
{
  "detail": "Authentication credentials were not provided."
}
```

---

## 6. Verify Email

Verify the user's email using the OTP received via email.

**`POST /api/auth/verify-email/`**

### Request Body

| Field      | Type   | Required | Description          |
| ---------- | ------ | :------: | -------------------- |
| `email`    | string |    ✅    | User's email address |
| `otp_code` | string |    ✅    | 6-digit OTP code     |

### Example Request

```json
{
  "email": "john@example.com",
  "otp_code": "482931"
}
```

### Success Response — `200 OK`

```json
{
  "message": "Email verified successfully."
}
```

### Error Responses

**`400 Bad Request`** — Invalid or expired OTP:

```json
{
  "error": "OTP has expired or is invalid. Please request a new one."
}
```

**`400 Bad Request`** — Wrong OTP code:

```json
{
  "error": "Invalid OTP code."
}
```

**`404 Not Found`** — Email not registered:

```json
{
  "error": "No account found with this email."
}
```

---

## 7. Resend Verification

Resend the email verification OTP. Response is always success to prevent email enumeration.

**`POST /api/auth/resend-verification/`**

### Request Body

| Field   | Type   | Required | Description          |
| ------- | ------ | :------: | -------------------- |
| `email` | string |    ✅    | User's email address |

### Example Request

```json
{
  "email": "john@example.com"
}
```

### Response — `200 OK` (always)

```json
{
  "message": "If an unverified account exists with this email, a verification code has been sent."
}
```

---

## 8. Forgot Password

Initiate password reset by sending an OTP to the user's email. Response is always success to prevent email enumeration.

**`POST /api/auth/forgot-password/`**

### Request Body

| Field   | Type   | Required | Description              |
| ------- | ------ | :------: | ------------------------ |
| `email` | string |    ✅    | Registered email address |

### Example Request

```json
{
  "email": "john@example.com"
}
```

### Response — `200 OK` (always)

```json
{
  "message": "If an account exists with this email, a password reset code has been sent."
}
```

---

## 9. Reset Password

Reset the password using the OTP received from the forgot-password flow.

**`POST /api/auth/reset-password/`**

### Request Body

| Field          | Type   | Required | Description                |
| -------------- | ------ | :------: | -------------------------- |
| `email`        | string |    ✅    | Registered email address   |
| `otp_code`     | string |    ✅    | 6-digit OTP code           |
| `new_password` | string |    ✅    | New password (min 8 chars) |

### Example Request

```json
{
  "email": "john@example.com",
  "otp_code": "593812",
  "new_password": "NewStrongPass456!"
}
```

### Success Response — `200 OK`

```json
{
  "message": "Password reset successfully. You can now log in with your new password."
}
```

### Error Responses

**`400 Bad Request`**:

```json
{
  "error": "OTP has expired or is invalid. Please request a new one."
}
```

**`404 Not Found`**:

```json
{
  "error": "No account found with this email."
}
```

---

## 10. Change Password

Change password for an authenticated user. Requires the current password.

**`POST /api/auth/change-password/`** 🔒 _Requires Authentication_

### Request Body

| Field                  | Type   | Required | Description                |
| ---------------------- | ------ | :------: | -------------------------- |
| `old_password`         | string |    ✅    | Current password           |
| `new_password`         | string |    ✅    | New password (min 8 chars) |
| `new_password_confirm` | string |    ✅    | Must match `new_password`  |

### Example Request

```json
{
  "old_password": "StrongPass123!",
  "new_password": "EvenStronger789!",
  "new_password_confirm": "EvenStronger789!"
}
```

### Success Response — `200 OK`

```json
{
  "message": "Password changed successfully."
}
```

### Error Responses

**`400 Bad Request`**:

```json
{
  "old_password": ["Current password is incorrect."],
  "new_password_confirm": ["New passwords do not match."]
}
```

---

## Authentication

All endpoints marked with 🔒 require the `Authorization` header:

```
Authorization: Bearer <access_token>
```

**Token Lifetimes:**
| Token | Lifetime |
|-------|----------|
| Access Token | 15 minutes |
| Refresh Token | 7 days |

**Token Rotation:** When you refresh, the old refresh token is blacklisted and a new one is issued.

---

## User Roles

| Role     | Value      | Description                    |
| -------- | ---------- | ------------------------------ |
| Tenant   | `tenant`   | Default role for regular users |
| Landlord | `landlord` | Property owners                |

---

## Rate Limiting

| User Type     | Limit             |
| ------------- | ----------------- |
| Anonymous     | 100 requests/day  |
| Authenticated | 1000 requests/day |

When rate-limited, the API returns `429 Too Many Requests`.

---

## Error Format

All validation errors follow this format:

```json
{
  "field_name": ["Error message 1", "Error message 2"]
}
```

Non-field errors use `non_field_errors` key. Single error messages use `error` or `detail` key.

---

## Recent Backend Additions

### Auth & Devices

- `POST /api/auth/device-token/` updates the authenticated user's FCM token.
- `POST /api/auth/otp/send/` sends a 6-digit email OTP to the authenticated user's email address.
- `POST /api/auth/otp/verify/` verifies an unused, unexpired OTP code.

### Messaging

- `GET /api/messages/?recipient_id=<user_id>` returns the authenticated user's thread with a specific recipient.
- `GET /api/messages/conversations/` returns unique conversation partners ordered by latest message.

### Payments

- `GET /api/payments/history/` is an alias for the authenticated tenant payment history.
- `POST /api/payments/khalti/verify/` verifies Khalti KPG-2 payments with `pidx`, `amount`, and `booking_id`.
- `POST /api/payments/esewa/verify/` verifies eSewa payments with `transaction_uuid`, `amount`, and `booking_id`.
- Payment records include `payment_gateway`, `transaction_token`, and `gateway_response`.

### Rooms

- `GET /api/rooms/?city=<city>` filters by the existing room `state` field for PRD compatibility.

### Environment Variables

```env
KHALTI_SECRET_KEY=your-khalti-secret-key
KHALTI_API_BASE_URL=https://dev.khalti.com/api/v2
ESEWA_PRODUCT_CODE=EPAYTEST
ESEWA_API_BASE_URL=https://rc.esewa.com.np
FIREBASE_CREDENTIALS_PATH=/absolute/path/to/firebase-service-account.json
```
