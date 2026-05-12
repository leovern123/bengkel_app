class ServiceModel {
  final int? id;
  final String namaService;
  final double harga;

  ServiceModel({
    this.id,
    required this.namaService,
    required this.harga,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      namaService: json['nama_service'] ?? '',
      harga: double.tryParse(json['harga'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_service': namaService,
      'harga': harga,
    };
  }
}
