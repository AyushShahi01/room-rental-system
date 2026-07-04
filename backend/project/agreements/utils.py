from django.utils import timezone

DEFAULT_AGREEMENT_TEMPLATE = """# RESIDENTIAL ROOM RENTAL AGREEMENT

This Room Rental Agreement ("Agreement") is entered into on **{{agreement_date}}** between:

### 1. Landlord Information

**Full Name:** {{landlord_name}}

**Citizenship/ID No.:** {{landlord_id}}

**Phone Number:** {{landlord_phone}}

**Address:** {{landlord_address}}

(Hereinafter referred to as the "Landlord")

AND

### 2. Tenant Information

**Full Name:** {{tenant_name}}

**Citizenship/Passport No.:** {{tenant_id}}

**Phone Number:** {{tenant_phone}}

**Permanent Address:** {{tenant_address}}

(Hereinafter referred to as the "Tenant")

---

## 3. Property Details

The Landlord agrees to rent the following room to the Tenant:

* Property Name: {{property_name}}
* Property Address: {{property_address}}
* Room Number: {{room_number}}
* Floor: {{floor}}
* Room Type: {{room_type}}

---

## 4. Rental Period

* Start Date: {{start_date}}
* End Date: {{end_date}}

If no end date is specified, this agreement shall continue on a month-to-month basis until terminated by either party according to this agreement.

---

## 5. Monthly Rent

The Tenant agrees to pay:

* Monthly Rent: Rs. {{monthly_rent}}
* Due Date: {{due_day}} of every month
* Security Deposit: Rs. {{security_deposit}}

---

## 6. Utility Charges

The Tenant shall be responsible for the following:

☐ Electricity

☐ Water

☐ Internet

☐ Garbage Collection

☐ Other: _______________________

Unless otherwise agreed, utility charges shall be paid separately from the monthly rent.

---

## 7. Security Deposit

The security deposit shall be refundable upon termination of the tenancy after deducting any unpaid rent, damages beyond normal wear and tear, or other outstanding obligations.

---

## 8. Tenant Responsibilities

The Tenant agrees to:

* Pay rent on time.
* Keep the room clean and in good condition.
* Use the property only for residential purposes.
* Not engage in illegal activities.
* Not make structural changes without written permission.
* Inform the landlord immediately of any damages or maintenance issues.

---

## 9. Landlord Responsibilities

The Landlord agrees to:

* Provide peaceful possession of the rented room.
* Maintain essential services whenever reasonably possible.
* Perform major repairs not caused by tenant negligence.
* Respect the Tenant's privacy and provide reasonable notice before entering the room except during emergencies.

---

## 10. Visitors

Visitors are permitted provided they do not disturb other tenants or violate the property's rules. Overnight stays require prior approval from the Landlord.

---

## 11. Termination

Either party may terminate this agreement by providing **{{notice_period}} days' written notice**, unless otherwise required by applicable law.

Outstanding rent and utility payments must be settled before vacating the premises.

---

## 12. Damages

The Tenant shall be responsible for damages caused by negligence, misuse, or intentional acts.

Normal wear and tear shall not be considered damage.

---

## 13. House Rules

The Tenant agrees to follow the property's house rules, including but not limited to:

* Maintain cleanliness.
* Avoid excessive noise.
* No illegal substances.
* Respect neighboring tenants.
* Follow parking regulations, if applicable.

---

## 14. Governing Law

This Agreement shall be governed by the applicable laws of Nepal.

---

## 15. Additional Terms

{{additional_terms}}

---

## Declaration

Both parties declare that they have read, understood, and voluntarily agreed to the terms and conditions stated in this Agreement.

### Landlord

Signature: ___________________________

Name: {{landlord_name}}

Date: __________________

---

### Tenant

Signature: ___________________________

Name: {{tenant_name}}

Date: __________________

---

### Witness 1

Name: ___________________________

Signature: ___________________________

Phone: ___________________________

---

### Witness 2

Name: ___________________________

Signature: ___________________________

Phone: ___________________________"""

def generate_agreement_content(booking, rent_price=None, house_rules=None, additional_description=None):
    room = booking.room
    tenant = booking.tenant
    landlord = room.landlord
    today = timezone.localdate().isoformat()

    tenant_name = tenant.get_full_name() or tenant.username
    landlord_name = landlord.get_full_name() or landlord.username

    # Use landlord's custom policy template if set, otherwise fallback to the default template
    template = room.agreement_policy if room.agreement_policy and room.agreement_policy.strip() else DEFAULT_AGREEMENT_TEMPLATE

    landlord_address = f"Ward {landlord.ward}, {landlord.city}, {landlord.district}, {landlord.province}" if landlord.city else "Nepal"
    tenant_address = f"Ward {tenant.ward}, {tenant.city}, {tenant.district}, {tenant.province}" if tenant.city else "Nepal"

    monthly_rent = rent_price if rent_price is not None else room.price

    # Compile additional terms
    terms_list = []
    if house_rules:
        terms_list.append(f"**House Rules:**\n{house_rules}")
    if additional_description:
        terms_list.append(f"**Additional Description:**\n{additional_description}")
    
    additional_terms = "\n\n".join(terms_list) if terms_list else (room.description or "None")

    replacements = {
        "{{agreement_date}}": today,
        "{{landlord_name}}": landlord_name,
        "{{landlord_id}}": str(landlord.id)[:8],
        "{{landlord_phone}}": landlord.email or "N/A",
        "{{landlord_address}}": landlord_address,
        "{{tenant_name}}": tenant_name,
        "{{tenant_id}}": str(tenant.id)[:8],
        "{{tenant_phone}}": tenant.email or "N/A",
        "{{tenant_address}}": tenant_address,
        "{{property_name}}": room.title or "Room",
        "{{property_address}}": f"Ward {room.ward_number}, {room.state}, {room.province}",
        "{{room_number}}": str(room.id or "N/A"),
        "{{floor}}": "N/A",
        "{{room_type}}": "Furnished" if room.furnished_status else "Unfurnished",
        "{{start_date}}": today,
        "{{end_date}}": "Month-to-Month",
        "{{monthly_rent}}": str(monthly_rent),
        "{{due_day}}": "1st",
        "{{security_deposit}}": str(room.security_deposit or (float(monthly_rent) * 2 if monthly_rent else 0)),
        "{{notice_period}}": "30",
        "{{additional_terms}}": additional_terms,
    }

    content = template
    for placeholder, val in replacements.items():
        content = content.replace(placeholder, str(val))

    return content
