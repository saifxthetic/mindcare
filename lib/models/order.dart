class OrderModel {
  final int id;
  final double totalAmount;
  final String status;
  final String paymentMethod;

  OrderModel({
    required this.id,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0.0,
      status: json['status']?.toString() ?? 'Pending',
      paymentMethod: json['payment_method']?.toString() ?? 'Demo Payment',
    );
  }
}
