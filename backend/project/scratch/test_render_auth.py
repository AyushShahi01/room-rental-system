import requests
import uuid

# Configuration
BASE_URL = "https://www.roomrental.tech/api/"

def test_registration_and_login():
    print(f"Testing hosted API at: {BASE_URL}")
    
    # Generate unique credentials
    username = f"testuser_{uuid.uuid4().hex[:6]}"
    email = f"{username}@example.com"
    password = "SecurePassword123!"
    
    # 1. Try Registering a user on the hosted server
    reg_url = f"{BASE_URL}auth/register/"
    reg_data = {
        "username": username,
        "email": email,
        "password": password,
        "role": "tenant",
        "first_name": "Test",
        "last_name": "User"
    }
    
    print(f"\n1. Sending registration request to {reg_url}...")
    try:
        response = requests.post(reg_url, json=reg_data, timeout=15)
        print(f"Status Code: {response.status_code}")
        print(f"Response Headers: {dict(response.headers)}")
        print(f"Response Body: {response.text}")
        
        if response.status_code not in (200, 201):
            print("[FAILURE] Registration failed on the hosted server.")
            return
    except Exception as e:
        print(f"[ERROR] Connection to {reg_url} failed: {e}")
        return

    # 2. Try Logging In with the newly created credentials
    login_url = f"{BASE_URL}auth/login/"
    login_data = {
        "username": username,
        "password": password
    }
    
    print(f"\n2. Sending login request to {login_url}...")
    try:
        response = requests.post(login_url, json=login_data, timeout=15)
        print(f"Status Code: {response.status_code}")
        print(f"Response Body: {response.text}")
        
        if response.status_code == 200:
            print("[SUCCESS] Login succeeded on the hosted server!")
            tokens = response.json().get('tokens', {})
            access_token = tokens.get('access')
            
            # 3. Test an authenticated endpoint using the token
            profile_url = f"{BASE_URL}auth/me/"
            headers = {"Authorization": f"Bearer {access_token}"}
            print(f"\n3. Testing authenticated endpoint {profile_url}...")
            prof_resp = requests.get(profile_url, headers=headers, timeout=15)
            print(f"Status Code: {prof_resp.status_code}")
            print(f"Response Body: {prof_resp.text}")
        else:
            print("[FAILURE] Login failed on the hosted server.")
    except Exception as e:
        print(f"[ERROR] Connection to {login_url} failed: {e}")

if __name__ == "__main__":
    test_registration_and_login()
