from django.urls import path
from .views import AgreementListCreateView, AgreementDetailView, SignAgreementView, BookingAgreementView

urlpatterns = [
    path('', AgreementListCreateView.as_view(), name='agreement-list-create'),
    path('<int:pk>/', AgreementDetailView.as_view(), name='agreement-detail'),
    path('<int:pk>/sign/', SignAgreementView.as_view(), name='sign-agreement'),
    path('booking/<int:booking_id>/', BookingAgreementView.as_view(), name='booking-agreement'),
]
