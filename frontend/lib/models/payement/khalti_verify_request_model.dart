class KhaltiVerifyRequest {
  final String pidx;
  final String amount;
  final int bookingId;

  KhaltiVerifyRequest({
    required this.pidx,
    required this.amount,
    required this.bookingId,
  });

  Map<String, dynamic> toJson() => {
    "pidx": pidx,
    "amount": amount,
    "booking_id": bookingId,
  };
}
