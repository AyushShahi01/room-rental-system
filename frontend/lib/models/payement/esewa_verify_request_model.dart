class EsewaVerifyRequest {
  final String transactionUuid;
  final String amount;
  final int bookingId;

  EsewaVerifyRequest({
    required this.transactionUuid,
    required this.amount,
    required this.bookingId,
  });

  Map<String, dynamic> toJson() => {
    "transaction_uuid": transactionUuid,
    "amount": amount,
    "booking_id": bookingId,
  };
}
