from django.urls import path
from .views import NotificationListView, NotificationActionView, ReadAllNotificationsView, DeleteNotificationView

urlpatterns = [
    path('', NotificationListView.as_view(), name='notification-list'),
    path('<int:pk>/read/', NotificationActionView.as_view(), name='mark-notification-read'),
    path('read-all/', ReadAllNotificationsView.as_view(), name='read-all-notifications'),
    path('<int:pk>/', DeleteNotificationView.as_view(), name='delete-notification'),
]
