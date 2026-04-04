from django.urls import path
from .views import RoomListCreateView, RoomDetailView, MyRoomsView, RoomAvailabilityView

urlpatterns = [
    path('', RoomListCreateView.as_view(), name='room-list-create'),
    path('<int:pk>/', RoomDetailView.as_view(), name='room-detail'),
    path('my-rooms/', MyRoomsView.as_view(), name='my-rooms'),
    path('<int:pk>/availability/', RoomAvailabilityView.as_view(), name='room-availability'),
]
