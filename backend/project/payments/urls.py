from django.urls import path
from .views import (
    RentRecordListCreateView,
    RentRecordDetailView,
    RentDashboardView,
)

urlpatterns = [
    path('', RentRecordListCreateView.as_view(), name='rent-list-create'),
    path('<int:pk>/', RentRecordDetailView.as_view(), name='rent-detail'),
    path('dashboard/', RentDashboardView.as_view(), name='rent-dashboard'),
]
