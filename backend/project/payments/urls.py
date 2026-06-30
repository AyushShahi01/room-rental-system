from django.urls import path
from .views import (
    BookingPaymentsView,
    EsewaVerifyView,
    KhaltiVerifyView,
    MyPaymentsView,
    PaymentDetailView,
    PaymentListCreateView,
    VerifyPaymentView,
)

urlpatterns = [
    path('', PaymentListCreateView.as_view(), name='payment-list-create'),
    path('<int:pk>/', PaymentDetailView.as_view(), name='payment-detail'),
    path('my-payments/', MyPaymentsView.as_view(), name='my-payments'),
    path('history/', MyPaymentsView.as_view(), name='payment-history'),
    path('booking/<int:booking_id>/', BookingPaymentsView.as_view(), name='booking-payments'),
    path('<int:pk>/verify/', VerifyPaymentView.as_view(), name='verify-payment'),
    path('khalti/verify/', KhaltiVerifyView.as_view(), name='khalti-verify'),
    path('esewa/verify/', EsewaVerifyView.as_view(), name='esewa-verify'),
]
