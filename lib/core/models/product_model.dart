class ProductModel {
  final int? id;
  final String namaProduk;
  final double harga;
  final int stok;
  final String? gambarUrl;

  ProductModel({
    this.id,
    required this.namaProduk,
    required this.harga,
    required this.stok,
    this.gambarUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      namaProduk: json['nama_produk'] ?? '',
      // Menangani konversi dari String atau int ke double
      harga: double.tryParse(json['harga'].toString()) ?? 0.0,
      stok: json['stok'] ?? 0,
      gambarUrl: json['gambar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_produk': namaProduk,
      'harga': harga,
      'stok': stok,
    };
  }
}
