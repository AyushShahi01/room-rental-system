# 🔐 Authentication API Documentation

**Base URL:** `http://localhost:8000/api/v1/auth`  
**Content-Type:** `application/json`  
**Auth Header:** `Authorization: Bearer <access_token>`

---

## Endpoints Overview

| Method | Endpoint | Auth | Description |
|--------|----------|:----:|-------------|
| POST | `/register/` | ❌ | Register a new user |
| POST | `/login/` | ❌ | Login and receive JWT tokens |
| POST | `/logout/` | ✅ | Blacklist refresh token |
| POST | `/refresh/` | ❌ | Refresh access token |
| GET | `/me/` | ✅ | Get current user profile |
| POST | `/verify-email/` | ❌ | Verify email with OTP |
| POST | `/resend-verification/` | ❌ | Resend verification OTP |
| POST | `/forgot-password/` | ❌ | Request password reset OTP |
| POST | `/reset-password/` | ❌ | Reset password with OTP |
| POST | `/change-password/` | ✅ | Change password (authenticated) |

---

## 1. Register

Create a new user account. Sends an email verification OTP automatically.

**`POST /api/v1/auth/register/`**

### Request Body

| Field | Type | Required | Description |
|-------|------|:--------:|-------------|
| `email` | string | ✅ | Valid email address |
| `full_name` | string | ❌ | User's full name |
| `phone` | string | ❌ | Phone number (with country code) |
| `role` | string | ❌ | One of: `tenant`, `landlord`, `admin`. Default: `tenant` |
| `password` | string | ✅ | Min 8 characters, must pass Django validators |
| `password_confirm` | string | ✅ | Must match `password` |

### Example Request

```json
{
  "email": "john@example.com",
  "full_name": "John Doe",
  "phone": "+9779800000000",
  "role": "tenant",
  "password": "StrongPass123!",
  "password_confirm": "StrongPass123!"
}
```

### Success Response — `201 Created`

```json
{
  "message": "Registration successful. Please check your email for verification.",
  "user": {
    "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "email": "john@example.com",
    "full_name": "John Doe",
    "phone": "+9779800000000",
    "role": "tenant",
    "is_active": true,
    "is_verified": false,
    "created_at": "2026-03-04T04:00:00Z",
    "profile": {
      "profile_picture": null,
      "address": null,
      "occupation": null,
      "date_of_birth": null,
      "created_at": "2026-03-04T04:00:00Z",
      "updated_at": "2026-03-04T04:00:00Z"
    }
  }
}
```

### Error Response — `400 Bad Request`

```json
{
  "email": ["A user with this email already exists."],
  "password": ["This password is too common."],
  "password_confirm": ["Passwords do not match."]
}
```

---

## 2. Login

Authenticate and receive JWT token pair. Records login history and device info.

**`POST /api/v1/auth/login/`**

### Request Body

| Field | Type | Required | Description |
|-------|------|:--------:|-------------|
| `email` | string | ✅ | Registered email |
| `password` | string | ✅ | Account password |

### Example Request

```json
{
  "email": "john@example.com",
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
    "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "email": "john@example.com",
    "full_name": "John Doe",
    "phone": "+9779800000000",
    "role": "tenant",
    "is_active": true,
    "is_verified": false,
    "created_at": "2026-03-04T04:00:00Z",
    "profile": { ... }
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

**`POST /api/v1/auth/logout/`** 🔒 _Requires Authentication_

### Request Body

| Field | Type | Required | Description |
|-------|------|:--------:|-------------|
| `refresh` | string | ✅ | The refresh token to blacklist |

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

**`POST /api/v1/auth/refresh/`**

### Request Body

| Field | Type | Required | Description |
|-------|------|:--------:|-------------|
| `refresh` | string | ✅ | Valid refresh token |

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

**`GET /api/v1/auth/me/`** 🔒 _Requires Authentication_

### Success Response — `200 OK`

```json
{
  "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "email": "john@example.com",
  "full_name": "John Doe",
  "phone": "+9779800000000",
  "role": "tenant",
  "is_active": true,
  "is_verified": true,
  "created_at": "2026-03-04T04:00:00Z",
  "profile": {
    "profile_picture": null,
    "address": null,
    "occupation": null,
    "date_of_birth": null,
    "created_at": "2026-03-04T04:00:00Z",
    "updated_at": "2026-03-04T04:00:00Z"
  }
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

**`POST /api/v1/auth/verify-email/`**

### Request Body

| Field | Type | Required | Description |
|-------|------|:--------:|-------------|
| `email` | string | ✅ | User's email address |
| `otp_code` | string | ✅ | 6-digit OTP code |

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

**`POST /api/v1/auth/resend-verification/`**

### Request Body

| Field | Type | Required | Description |
|-------|------|:--------:|-------------|
| `email` | string | ✅ | User's email address |

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

**`POST /api/v1/auth/forgot-password/`**

### Request Body

| Field | Type | Required | Description |
|-------|------|:--------:|-------------|
| `email` | string | ✅ | Registered email address |

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

**`POST /api/v1/auth/reset-password/`**

### Request Body

| Field | Type | Required | Description |
|-------|------|:--------:|-------------|
| `email` | string | ✅ | Registered email address |
| `otp_code` | string | ✅ | 6-digit OTP code |
| `new_password` | string | ✅ | New password (min 8 chars) |

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

**`POST /api/v1/auth/change-password/`** 🔒 _Requires Authentication_

### Request Body

| Field | Type | Required | Description |
|-------|------|:--------:|-------------|
| `old_password` | string | ✅ | Current password |
| `new_password` | string | ✅ | New password (min 8 chars) |
| `new_password_confirm` | string | ✅ | Must match `new_password` |

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

| Role | Value | Description |
|------|-------|-------------|
| Tenant | `tenant` | Default role for regular users |
| Landlord | `landlord` | Property owners |
| Admin | `admin` | Full system access |

---

## Rate Limiting

| User Type | Limit |
|-----------|-------|
| Anonymous | 100 requests/day |
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
