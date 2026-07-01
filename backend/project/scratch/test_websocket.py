import os
import django
import asyncio

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'project.settings')
django.setup()

from channels.testing import WebsocketCommunicator
from project.asgi import application
from django.contrib.auth import get_user_model
from rest_framework_simplejwt.tokens import AccessToken
from asgiref.sync import sync_to_async

User = get_user_model()

async def test_websocket():
    print("Starting WebSocket integration test...")
    user1, _ = await sync_to_async(User.objects.get_or_create)(username='testuser1', defaults={'email': 'test1@example.com'})
    user2, _ = await sync_to_async(User.objects.get_or_create)(username='testuser2', defaults={'email': 'test2@example.com'})
    
    token = str(AccessToken.for_user(user1))
    print(f"Generated JWT token for user1 (UUID: {user1.id})")
    
    communicator = WebsocketCommunicator(application, f"ws/chat/?token={token}")
    
    print("Connecting to ws/chat/ WebSocket...")
    connected, subprotocol = await communicator.connect()
    print("Connected status:", connected)
    
    if not connected:
        print("Failed to connect!")
        return
        
    payload = {
        "action": "send_message",
        "receiver_id": str(user2.id),
        "content": "Hi from WebSocket!"
    }
    print("Sending message payload:", payload)
    await communicator.send_json_to(payload)
    
    print("Waiting for broadcast message...")
    response = await communicator.receive_json_from()
    print("Received message back:", response)
    
    assert response['type'] == 'chat_message'
    assert response['message']['content'] == "Hi from WebSocket!"
    assert response['message']['sender'] == str(user1.id)
    
    await communicator.disconnect()
    print("WebSocket integration test passed successfully!")

if __name__ == "__main__":
    asyncio.run(test_websocket())
