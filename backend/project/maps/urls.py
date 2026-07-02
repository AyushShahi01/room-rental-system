"""
maps/urls.py
============
URL routes for the maps app.
"""

from django.urls import path
from .views import RoomLocationListView, RoomLocationDetailView, ShortestRouteView

app_name = 'maps'

urlpatterns = [
    # Room location endpoints
    path('rooms/', RoomLocationListView.as_view(), name='room-location-list'),
    path('rooms/<int:pk>/', RoomLocationDetailView.as_view(), name='room-location-detail'),

    # Routing endpoint
    path('route/shortest/', ShortestRouteView.as_view(), name='shortest-route'),
]
