from django.urls import path
from .views import PaymentListCreateView, PaymentDetailView, MyPaymentsView, BookingPaymentsView, VerifyPaymentView

urlpatterns = [
    path('', PaymentListCreateView.as_view(), name='payment-list-create'),
    path('<int:pk>/', PaymentDetailView.as_view(), name='payment-detail'),
    path('my-payments/', MyPaymentsView.as_view(), name='my-payments'),
    path('booking/<int:booking_id>/', BookingPaymentsView.as_view(), name='booking-payments'),
    path('<int:pk>/verify/', VerifyPaymentView.as_view(), name='verify-payment'),
]
