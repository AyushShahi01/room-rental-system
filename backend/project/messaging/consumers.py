import json
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from django.contrib.auth import get_user_model
from .models import Message
from .serializers import MessageSerializer

User = get_user_model()

class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.user = self.scope.get("user")
        if self.user is None or self.user.is_anonymous:
            await self.close(code=4003)  # Forbidden
            return
            
        self.group_name = f"user_{self.user.id}"
        
        await self.channel_layer.group_add(
            self.group_name,
            self.channel_name
        )
        await self.accept()

    async def disconnect(self, close_code):
        if hasattr(self, 'group_name'):
            await self.channel_layer.group_discard(
                self.group_name,
                self.channel_name
            )

    async def receive(self, text_data):
        try:
            data = json.loads(text_data)
        except json.JSONDecodeError:
            return
            
        action = data.get("action")
        if action == "send_message":
            receiver_id = data.get("receiver_id")
            content = data.get("content")
            booking_id = data.get("booking_id")
            
            if not receiver_id or not content:
                return
                
            # Save message to DB
            message = await self.save_message(receiver_id, content, booking_id)
            if message:
                serialized_msg = await self.serialize_message(message)
                
                # Send to sender group
                await self.channel_layer.group_send(
                    self.group_name,
                    {
                        "type": "chat_message",
                        "message": serialized_msg
                    }
                )
                
                # Send to receiver group
                receiver_group = f"user_{receiver_id}"
                await self.channel_layer.group_send(
                    receiver_group,
                    {
                        "type": "chat_message",
                        "message": serialized_msg
                    }
                )
        elif action == "mark_read":
            message_id = data.get("message_id")
            if message_id:
                await self.mark_message_as_read(message_id)

    async def chat_message(self, event):
        message = event["message"]
        await self.send(text_data=json.dumps({
            "type": "chat_message",
            "message": message
        }))

    @database_sync_to_async
    def save_message(self, receiver_id, content, booking_id=None):
        try:
            receiver = User.objects.get(id=receiver_id)
            if receiver == self.user:
                return None
            message = Message.objects.create(
                sender=self.user,
                receiver=receiver,
                content=content,
                booking_id=booking_id
            )
            try:
                from notifications.helpers import create_notification
                create_notification(receiver, f'New message from {self.user.username}.')
            except Exception:
                pass
            return message
        except Exception:
            return None

    @database_sync_to_async
    def serialize_message(self, message):
        data = MessageSerializer(message).data
        if 'sender' in data and data['sender']:
            data['sender'] = str(data['sender'])
        if 'receiver' in data and data['receiver']:
            data['receiver'] = str(data['receiver'])
        return data

    @database_sync_to_async
    def mark_message_as_read(self, message_id):
        try:
            message = Message.objects.get(id=message_id, receiver=self.user)
            if not message.is_read:
                message.is_read = True
                message.save(update_fields=['is_read'])
        except Exception:
            pass
