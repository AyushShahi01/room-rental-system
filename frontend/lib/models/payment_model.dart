class PaymentModel {
  final String id;
  final double amount;
  final String date;
  final String method;
  final String status;

  PaymentModel({
    this.id = '',
    this.amount = 0.0,
    this.date = '',
    this.method = '',
    this.status = '',
  });
}
