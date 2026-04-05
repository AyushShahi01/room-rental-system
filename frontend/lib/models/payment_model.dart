class PaymentModel {
  String id;
  double amount;
  String date;
  String method;
  String status;

  PaymentModel({
    required this.id,
    required this.amount,
    required this.date,
    required this.method,
    required this.status,
  });
}
