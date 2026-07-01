from django.urls import path
from .views import (
    RoomListCreateView,
    RoomDetailView,
    MyRoomsView,
    RoomAvailabilityView,
    RoomImageListView,
    RoomImageUploadView,
    RoomImageDeleteView,
    RecommendedRoomsView,
)

urlpatterns = [
    path('', RoomListCreateView.as_view(), name='room-list-create'),
    path('<int:pk>/', RoomDetailView.as_view(), name='room-detail'),
    path('my-rooms/', MyRoomsView.as_view(), name='my-rooms'),
    path('<int:pk>/availability/', RoomAvailabilityView.as_view(), name='room-availability'),
    # Images
    path('<int:room_id>/images/', RoomImageListView.as_view(), name='room-image-list'),
    path('<int:room_id>/images/upload/', RoomImageUploadView.as_view(), name='room-image-upload'),
    path('<int:room_id>/images/<int:image_id>/', RoomImageDeleteView.as_view(), name='room-image-delete'),
    path('recommendations/', RecommendedRoomsView.as_view(), name='recommended-rooms'),
]
