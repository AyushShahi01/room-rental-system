from django.urls import path
from .views import MaintenanceListCreateView, MaintenanceDetailView, MaintenanceStatusUpdateView, MyMaintenanceView, RoomMaintenanceView

urlpatterns = [
    path('', MaintenanceListCreateView.as_view(), name='maintenance-list-create'),
    path('<int:pk>/', MaintenanceDetailView.as_view(), name='maintenance-detail'),
    path('<int:pk>/status/', MaintenanceStatusUpdateView.as_view(), name='maintenance-status'),
    path('my-requests/', MyMaintenanceView.as_view(), name='my-requests'),
    path('room/<int:room_id>/', RoomMaintenanceView.as_view(), name='room-requests'),
]
