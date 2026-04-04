from django.urls import path
from .views import MessageListCreateView, MessageDetailView, BookingMessagesView, MarkMessageReadView

urlpatterns = [
    path('', MessageListCreateView.as_view(), name='message-list-create'),
    path('<int:pk>/', MessageDetailView.as_view(), name='message-detail'),
    path('booking/<int:booking_id>/', BookingMessagesView.as_view(), name='booking-messages'),
    path('<int:pk>/read/', MarkMessageReadView.as_view(), name='mark-message-read'),
]
