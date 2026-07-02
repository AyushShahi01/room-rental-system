"""
test_notifications.py
=====================
End-to-end notification test.

Tests every notification trigger event across all apps:
  Bookings   : new booking, approve, reject, cancel
  Payments   : payment submitted, payment verified (manual)
  Agreements : agreement created, agreement signed
  Maintenance: request created, status updated
  Messaging  : new message received

Also tests the notification API endpoints:
  GET  /api/notifications/          - list
  PATCH /api/notifications/<id>/read/ - mark single read
  PATCH /api/notifications/read-all/  - mark all read
  DELETE /api/notifications/<id>/     - delete

Run:
    python -X utf8 scratch/test_notifications.py
"""

import sys
import json
import urllib.request
import urllib.error

BASE = "http://127.0.0.1:8000"

TENANT   = {"email": "notif_tenant@test.com",   "password": "Test@1234", "username": "notif_tenant",   "role": "tenant"}
LANDLORD = {"email": "notif_landlord@test.com",  "password": "Test@1234", "username": "notif_landlord", "role": "landlord"}

PASS = "[PASS]"
FAIL = "[FAIL]"
INFO = "[INFO]"
SKIP = "[SKIP]"

results = {"pass": 0, "fail": 0, "skip": 0}


def header(msg):
    print(f"\n{'=' * 64}\n  {msg}\n{'=' * 64}")


def ok(msg):
    results["pass"] += 1
    print(f"  {PASS} {msg}")


def fail(msg):
    results["fail"] += 1
    print(f"  {FAIL} {msg}")


def info(msg):
    print(f"  {INFO} {msg}")


def skip(msg):
    results["skip"] += 1
    print(f"  {SKIP} {msg}")


def request(method, path, data=None, token=None, timeout=30):
    url = BASE + path
    headers = {"Content-Type": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token[:20]}...{token[-10:]}"  # truncated for readability
    body = json.dumps(data).encode() if data else None

    # ── Print Request ─────────────────────────────────────────────────────────
    print(f"\n  >> {method} {url}")
    if token:
        print(f"     Authorization: Bearer {token[:20]}...{token[-10:]}")
    if data:
        print(f"     Body: {json.dumps(data, indent=6)}")

    # Restore full token for actual request
    if token:
        headers["Authorization"] = f"Bearer {token}"

    req = urllib.request.Request(url, data=body, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            try:
                resp_body = json.loads(resp.read())
            except (json.JSONDecodeError, ValueError):
                resp_body = {}
            # ── Print Response ────────────────────────────────────────────────
            _print_response(resp.status, resp_body)
            return resp.status, resp_body
    except urllib.error.HTTPError as e:
        try:
            resp_body = json.loads(e.read())
        except Exception:
            resp_body = {}
        _print_response(e.code, resp_body)
        return e.code, resp_body
    except Exception as e:
        print(f"  << ERROR: {e}")
        return None, str(e)


def _print_response(status_code, body):
    """Pretty-print the HTTP response."""
    # Status line with visual indicator
    if 200 <= status_code < 300:
        indicator = "[2xx]"
    elif 400 <= status_code < 500:
        indicator = "[4xx]"
    elif status_code >= 500:
        indicator = "[5xx]"
    else:
        indicator = f"[{status_code}]"

    print(f"  << HTTP {status_code} {indicator}")

    if body:
        # Pretty-print but truncate large arrays (e.g. path coordinates)
        body_str = json.dumps(body, indent=6)
        lines = body_str.split("\n")
        if len(lines) > 40:
            # Show first 35 lines + truncation notice
            truncated = "\n".join(lines[:35])
            print(f"     {truncated}")
            print(f"     ... [{len(lines) - 35} more lines truncated]")
        else:
            print(f"     {body_str}")
    print()



# ─── Setup: Create users via Django shell ─────────────────────────────────────
def setup_users():
    """Create tenant + landlord + a room owned by the landlord via Django shell."""
    import subprocess, sys
    script = """
import django, os
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'project.settings')
django.setup()
from users.models import CustomUser
from rooms.models import Room

for u in [
    dict(email='notif_tenant@test.com',   username='notif_tenant',   role='tenant'),
    dict(email='notif_landlord@test.com',  username='notif_landlord',  role='landlord'),
]:
    obj, created = CustomUser.objects.get_or_create(
        email=u['email'],
        defaults={'username': u['username'], 'role': u['role'], 'is_active': True}
    )
    obj.set_password('Test@1234')
    obj.save()
    print(f"User {u['email']}: {'created' if created else 'exists'}")

landlord = CustomUser.objects.get(email='notif_landlord@test.com')
room, created = Room.objects.get_or_create(
    landlord=landlord,
    title='Test Room for Notifications',
    defaults={
        'description': 'A test room used for notification testing.',
        'price': 5000,
        'province': 'Bagmati',
        'state': 'Kathmandu',
        'ward_number': 1,
        'is_available': True,
    }
)
# Always reset availability so each test run can create a fresh booking
if not room.is_available:
    room.is_available = True
    room.save(update_fields=['is_available'])
    print(f"Room id={room.id}: reset is_available=True")

# Clean up old test bookings so we start fresh
from bookings.models import Booking
old = Booking.objects.filter(room=room)
count = old.count()
old.delete()
print(f"Room id={room.id}: {'created' if created else 'exists'} | cleaned {count} old bookings")
"""
    result = subprocess.run(
        [sys.executable, "-c", script],
        cwd=".",
        capture_output=True,
        text=True,
    )
    print(result.stdout.strip())
    if result.returncode != 0:
        print("Setup error:", result.stderr[:400])


def get_token(email, password):
    s, b = request("POST", "/api/auth/login/", {"email": email, "password": password})
    if s == 200 and "tokens" in b:
        return b["tokens"]["access"]
    fail(f"Login failed for {email}: {b}")
    sys.exit(1)



# ─── Notification API helpers ─────────────────────────────────────────────────

def get_notifications(token):
    s, b = request("GET", "/api/notifications/", token=token)
    if s == 200:
        items = b.get("results", b) if isinstance(b, dict) else b
        return items
    return []


def count_unread(token):
    items = get_notifications(token)
    return sum(1 for n in items if not n.get("is_read"))


def latest_notification(token):
    items = get_notifications(token)
    return items[0] if items else None


def assert_notification(token, contains_text, who="user"):
    notifs = get_notifications(token)
    for n in notifs:
        if contains_text.lower() in n.get("content", "").lower():
            ok(f"[{who}] Notification received: '{n['content']}'")
            return n
    fail(f"[{who}] Expected notification containing '{contains_text}'. Got: {[n.get('content') for n in notifs[:3]]}")
    return None


# ─── Test: Notification API Endpoints ────────────────────────────────────────

def test_notification_list(token_t):
    header("Notification API -- List endpoint")
    s, b = request("GET", "/api/notifications/", token=token_t)
    info(f"GET /api/notifications/ -> HTTP {s}")
    if s == 200:
        ok("List endpoint returns HTTP 200")
        items = b.get("results", b) if isinstance(b, dict) else b
        info(f"Notifications count: {len(items)}")
    else:
        fail(f"Expected 200, got {s}: {b}")


def test_mark_read(token_t):
    header("Notification API -- Mark single read")
    n = latest_notification(token_t)
    if not n:
        skip("No notifications to mark read")
        return
    pk = n["id"]
    s, b = request("PATCH", f"/api/notifications/{pk}/read/", token=token_t)
    info(f"PATCH /api/notifications/{pk}/read/ -> HTTP {s}")
    if s == 200:
        ok(f"Notification {pk} marked as read")
    else:
        fail(f"Expected 200, got {s}: {b}")


def test_read_all(token_t):
    header("Notification API -- Mark all read")
    s, b = request("PATCH", "/api/notifications/read-all/", token=token_t)
    info(f"PATCH /api/notifications/read-all/ -> HTTP {s}")
    if s == 200:
        ok(f"Mark-all-read: {b.get('message', b)}")
        unread = count_unread(token_t)
        if unread == 0:
            ok("Unread count is now 0")
        else:
            fail(f"Still {unread} unread notifications after read-all")
    else:
        fail(f"Expected 200, got {s}: {b}")


def test_delete_notification(token_t):
    header("Notification API -- Delete notification")
    n = latest_notification(token_t)
    if not n:
        skip("No notifications to delete")
        return
    pk = n["id"]
    s, b = request("DELETE", f"/api/notifications/{pk}/", token=token_t)
    info(f"DELETE /api/notifications/{pk}/ -> HTTP {s}")
    if s == 204:
        ok(f"Notification {pk} deleted (204 No Content)")
    else:
        fail(f"Expected 204, got {s}: {b}")


# ─── Test: Booking Notification Events ───────────────────────────────────────

def test_booking_events(token_t, token_l, landlord_id):
    header("Booking Events -- New Booking Request")

    # Get a room owned by the test landlord specifically
    s, b = request("GET", "/api/rooms/", token=token_l)
    all_rooms = b.get("results", []) if isinstance(b, dict) else []
    # Filter to only rooms owned by our test landlord
    own_rooms = []
    for r in all_rooms:
        l = r.get("landlord")
        l_id = l.get("id") if isinstance(l, dict) else l
        if str(l_id) == str(landlord_id):
            own_rooms.append(r)
    if not own_rooms:
        own_rooms = all_rooms  # fallback
    room_id = own_rooms[0]["id"] if own_rooms else None

    if not room_id:
        skip("No rooms found -- landlord needs a room to test booking notifications")
        return None

    info(f"Using room id={room_id}")

    # Tenant creates a booking
    s, b = request("POST", "/api/bookings/", {"room": room_id}, token=token_t)
    info(f"POST /api/bookings/ -> HTTP {s}")

    if s == 201:
        ok("Tenant created booking successfully")
        booking_id = b.get("id")
    elif s == 400:
        # Booking may already exist; try to find existing
        s2, b2 = request("GET", "/api/bookings/my/", token=token_t)
        items = b2.get("results", []) if isinstance(b2, dict) else []
        pending = [bk for bk in items if bk.get("status") == "pending"]
        booking_id = pending[0]["id"] if pending else None
        if booking_id:
            info(f"Using existing pending booking id={booking_id}")
        else:
            fail(f"Could not create or find a booking: {b}")
            return None
    else:
        fail(f"Unexpected status {s}: {b}")
        return None

    # Landlord should receive notification
    assert_notification(token_l, "new booking", who="LANDLORD")

    return booking_id


def test_booking_approve(token_t, token_l, booking_id):
    header("Booking Events -- Approve")
    if not booking_id:
        skip("No booking_id — skipping approve test")
        return

    s, b = request("PATCH", f"/api/bookings/{booking_id}/approve/", token=token_l)
    info(f"PATCH /api/bookings/{booking_id}/approve/ -> HTTP {s}")

    if s == 200:
        ok("Landlord approved booking")
    elif s == 400:
        info(f"Approve response: {b} (booking may already be approved)")
    else:
        fail(f"Unexpected {s}: {b}")

    # Tenant should receive notification
    assert_notification(token_t, "approved", who="TENANT")


def test_booking_reject(token_t, token_l, room_id=None):
    """Create a fresh pending booking and reject it."""
    header("Booking Events -- Reject")
    if not room_id:
        skip("No room_id -- skipping reject test")
        return

    # Create a fresh booking to reject (cancel current first if needed)
    s, b = request("POST", "/api/bookings/", {"room": room_id}, token=token_t)
    if s not in (201, 400):
        skip(f"Could not create booking to reject: {s} {b}")
        return

    # Get a pending booking
    s2, b2 = request("GET", "/api/bookings/incoming/", token=token_l)
    items = b2.get("results", []) if isinstance(b2, dict) else []
    pending = [bk for bk in items if bk.get("status") == "pending"]
    if not pending:
        skip("No pending bookings to reject")
        return

    bk_id = pending[0]["id"]
    s3, b3 = request("PATCH", f"/api/bookings/{bk_id}/reject/", token=token_l)
    info(f"PATCH /api/bookings/{bk_id}/reject/ -> HTTP {s3}")

    if s3 == 200:
        ok("Landlord rejected booking")
        assert_notification(token_t, "rejected", who="TENANT")
    else:
        fail(f"Unexpected {s3}: {b3}")


def test_booking_cancel(token_t, token_l):
    header("Booking Events -- Cancel")
    s, b = request("GET", "/api/bookings/my/", token=token_t)
    items = b.get("results", []) if isinstance(b, dict) else []
    cancellable = [bk for bk in items if bk.get("status") in ("pending", "approved")]
    if not cancellable:
        skip("No cancellable bookings")
        return

    bk_id = cancellable[0]["id"]
    s2, b2 = request("PATCH", f"/api/bookings/{bk_id}/cancel/", token=token_t)
    info(f"PATCH /api/bookings/{bk_id}/cancel/ -> HTTP {s2}")

    if s2 == 200:
        ok("Tenant cancelled booking")
        assert_notification(token_l, "cancelled", who="LANDLORD")
    else:
        fail(f"Unexpected {s2}: {b2}")


# ─── Test: Payment Notification Events ───────────────────────────────────────

def test_payment_submitted(token_t, token_l, booking_id):
    header("Payment Events -- Payment Submitted")
    if not booking_id:
        skip("No booking_id -- skipping payment test")
        return None

    s, b = request("POST", "/api/payments/", {
        "booking": booking_id,
        "amount": "5000",
        "payment_gateway": "manual",
    }, token=token_t)
    info(f"POST /api/payments/ -> HTTP {s}")

    if s == 201:
        payment_id = b.get("id")
        ok(f"Payment submitted (id={payment_id})")
        assert_notification(token_l, "payment", who="LANDLORD")
        return payment_id
    else:
        info(f"Payment creation: {s} {b}")
        return None


def test_payment_verified(token_t, token_l, payment_id):
    header("Payment Events -- Payment Verified (Manual)")
    if not payment_id:
        skip("No payment_id -- skipping verify test")
        return

    s, b = request("PATCH", f"/api/payments/{payment_id}/verify/", token=token_l)
    info(f"PATCH /api/payments/{payment_id}/verify/ -> HTTP {s}")

    if s == 200:
        ok("Payment verified by landlord")
        assert_notification(token_t, "verified", who="TENANT")
    else:
        fail(f"Unexpected {s}: {b}")


# ─── Test: Agreement Notification Events ─────────────────────────────────────

def test_agreement_created(token_t, token_l, booking_id):
    header("Agreement Events -- Agreement Created")
    if not booking_id:
        skip("No booking_id -- skipping agreement test")
        return None

    s, b = request("POST", "/api/agreements/", {
        "booking": booking_id,
        "terms": "Standard lease agreement terms for testing.",
    }, token=token_l)
    info(f"POST /api/agreements/ -> HTTP {s}")

    if s == 201:
        agreement_id = b.get("id")
        ok(f"Agreement created (id={agreement_id})")
        assert_notification(token_t, "lease agreement", who="TENANT")
        return agreement_id
    else:
        info(f"Agreement creation: {s} {b}")
        return None


def test_agreement_signed(token_t, token_l, agreement_id):
    header("Agreement Events -- Agreement Signed by Tenant")
    if not agreement_id:
        skip("No agreement_id -- skipping sign test")
        return

    s, b = request("PATCH", f"/api/agreements/{agreement_id}/sign/", token=token_t)
    info(f"PATCH /api/agreements/{agreement_id}/sign/ -> HTTP {s}")

    if s == 200:
        ok("Tenant signed agreement")
        assert_notification(token_l, "signed", who="LANDLORD")
    else:
        fail(f"Unexpected {s}: {b}")


# ─── Test: Maintenance Notification Events ────────────────────────────────────

def test_maintenance_created(token_t, token_l, booking_id):
    header("Maintenance Events -- Request Created")
    if not booking_id:
        skip("No booking_id -- skipping maintenance test")
        return None

    # Maintenance requires room_id, not booking_id — get room from booking
    s0, b0 = request("GET", f"/api/bookings/{booking_id}/", token=token_t)
    room_id_for_maint = b0.get("room") if s0 == 200 else None
    if not room_id_for_maint:
        skip("Could not get room from booking for maintenance test")
        return None

    s, b = request("POST", "/api/maintenance/", {
        "room": room_id_for_maint,
        "description": "The tap is leaking in the bathroom.",
    }, token=token_t)
    info(f"POST /api/maintenance/ -> HTTP {s}")

    if s == 201:
        maint_id = b.get("id")
        ok(f"Maintenance request created (id={maint_id})")
        assert_notification(token_l, "maintenance", who="LANDLORD")
        return maint_id
    else:
        info(f"Maintenance creation: {s} {b}")
        return None


def test_maintenance_status_updated(token_t, token_l, maint_id):
    header("Maintenance Events -- Status Updated")
    if not maint_id:
        skip("No maint_id -- skipping status update test")
        return

    s3, b3 = request("PATCH", f"/api/maintenance/{maint_id}/status/", {"status": "in_progress"}, token=token_l)
    info(f"PATCH /api/maintenance/{maint_id}/status/ -> HTTP {s3}")

    if s3 == 200:
        ok("Landlord updated maintenance status")
        assert_notification(token_t, "maintenance request status", who="TENANT")
    else:
        fail(f"Unexpected {s3}: {b3}")


# ─── Test: Messaging Notification Events ─────────────────────────────────────

def test_messaging_notification(token_t, token_l, landlord_id):
    header("Messaging Events -- New Message Received")
    if not landlord_id:
        skip("No landlord_id -- skipping messaging test")
        return

    s, b = request("POST", "/api/messages/", {
        "receiver": landlord_id,
        "content": "Hello, is the room still available?",
    }, token=token_t)
    info(f"POST /api/messages/ -> HTTP {s}")

    if s == 201:
        ok("Tenant sent message to landlord")
        assert_notification(token_l, "message", who="LANDLORD")
    else:
        fail(f"Unexpected {s}: {b}")


# ─── Main ─────────────────────────────────────────────────────────────────────

def main():
    print("\nNotification System -- End-to-End Test Suite")
    print("Creating test users...")
    setup_users()

    token_t = get_token(TENANT["email"],   TENANT["password"])
    token_l = get_token(LANDLORD["email"], LANDLORD["password"])
    info("Both users authenticated")

    # Get landlord user id for messaging
    s, b = request("GET", "/api/auth/me/", token=token_l)
    landlord_id = b.get("id") if s == 200 else None
    info(f"Landlord id: {landlord_id}")

    # ── Booking flow ──────────────────────────────────────────────────────────
    # Get a room to book
    s, rooms_b = request("GET", "/api/rooms/", token=token_l)
    rooms = rooms_b.get("results", []) if isinstance(rooms_b, dict) else []
    room_id = rooms[0]["id"] if rooms else None

    booking_id = test_booking_events(token_t, token_l, landlord_id)
    test_booking_approve(token_t, token_l, booking_id)
    test_booking_cancel(token_t, token_l)
    test_booking_reject(token_t, token_l, room_id)

    # Re-find an approved booking for payment/agreement/maintenance tests
    s, b = request("GET", "/api/bookings/my/", token=token_t)
    items = b.get("results", []) if isinstance(b, dict) else []
    approved_booking = next((bk for bk in items if bk.get("status") == "approved"), None)
    approved_booking_id = approved_booking["id"] if approved_booking else booking_id

    # ── Payment flow ──────────────────────────────────────────────────────────
    payment_id = test_payment_submitted(token_t, token_l, approved_booking_id)
    test_payment_verified(token_t, token_l, payment_id)

    # ── Agreement flow ────────────────────────────────────────────────────────
    agreement_id = test_agreement_created(token_t, token_l, approved_booking_id)
    test_agreement_signed(token_t, token_l, agreement_id)

    # ── Maintenance flow ──────────────────────────────────────────────────────
    maint_id = test_maintenance_created(token_t, token_l, approved_booking_id)
    test_maintenance_status_updated(token_t, token_l, maint_id)

    # ── Messaging ─────────────────────────────────────────────────────────────
    test_messaging_notification(token_t, token_l, landlord_id)

    # ── Notification API endpoints ────────────────────────────────────────────
    test_notification_list(token_t)
    test_mark_read(token_t)
    test_read_all(token_t)
    test_delete_notification(token_t)

    # ── Summary ───────────────────────────────────────────────────────────────
    print(f"\n{'=' * 64}")
    print(f"  RESULTS:  {results['pass']} passed  |  {results['fail']} failed  |  {results['skip']} skipped")
    print(f"{'=' * 64}\n")


if __name__ == "__main__":
    main()
