class OrderModel {
  final int? id;
  final int customerId;
  final int userId;
  final DateTime tanggal;
  final DateTime? createdAt;
  final double total;
  final String? customerName;
  final List<OrderDetailModel>? details;

  OrderModel({
    this.id,
    required this.customerId,
    required this.userId,
    required this.tanggal,
    this.createdAt,
    required this.total,
    this.customerName,
    this.details,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Mencoba mengambil waktu dari 'created_at' jika tersedia, jika tidak gunakan 'tanggal'
    DateTime parsedDate;
    if (json['created_at'] != null) {
      parsedDate = DateTime.parse(json['created_at']).toLocal();
    } else {
      parsedDate = DateTime.parse(json['tanggal'] ?? DateTime.now().toString());
    }

    return OrderModel(
      id: json['id'],
      customerId: json['customer_id'],
      userId: json['user_id'],
      tanggal: parsedDate,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']).toLocal() : null,
      total: double.tryParse(json['total'].toString()) ?? 0.0,
      customerName: json['customer'] != null ? json['customer']['nama'] : (json['customer_name'] ?? "Pelanggan"),
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
  final String? productName;
  final String? serviceName;

  OrderDetailModel({
    this.id,
    this.orderId,
    this.serviceId,
    this.productId,
    required this.qty,
    required this.subtotal,
    this.productName,
    this.serviceName,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      id: json['id'],
      orderId: json['order_id'],
      serviceId: json['service_id'],
      productId: json['product_id'],
      qty: json['qty'] ?? 0,
      subtotal: double.tryParse(json['subtotal'].toString()) ?? 0.0,
      productName: json['product'] != null ? json['product']['nama_produk'] : null,
      serviceName: json['service'] != null ? json['service']['nama_service'] : null,
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
