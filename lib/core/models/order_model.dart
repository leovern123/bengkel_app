class OrderModel {
  final int? id;
  final int customerId;
  final int userId;
  final DateTime tanggal;
  final double total;
  final List<OrderDetailModel>? details;

  OrderModel({
    this.id,
    required this.customerId,
    required this.userId,
    required this.tanggal,
    required this.total,
    this.details,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      customerId: json['customer_id'],
      userId: json['user_id'],
      tanggal: json['tanggal'] != null 
          ? DateTime.parse(json['tanggal']) 
          : DateTime.now(),
      total: double.tryParse(json['total'].toString()) ?? 0.0,
      details: json['details'] != null
          ? (json['details'] as List)
              .map((i) => OrderDetailModel.fromJson(i))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'user_id': userId,
      'tanggal': tanggal.toIso8601String().split('T')[0], // YYYY-MM-DD
      'total': total,
      'details': details?.map((e) => e.toJson()).toList(),
    };
  }
}

class OrderDetailModel {
  final int? id;
  final int? orderId;
  final int? serviceId;
  final int? productId;
  final int qty;
  final double subtotal;

  OrderDetailModel({
    this.id,
    this.orderId,
    this.serviceId,
    this.productId,
    required this.qty,
    required this.subtotal,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      id: json['id'],
      orderId: json['order_id'],
      serviceId: json['service_id'],
      productId: json['product_id'],
      qty: json['qty'] ?? 0,
      subtotal: double.tryParse(json['subtotal'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'product_id': productId,
      'qty': qty,
      'subtotal': subtotal,
    };
  }
}
