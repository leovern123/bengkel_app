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
    String? rawGambar = json['gambar_url'] ?? json['gambar'];
    String? finalGambarUrl;

    if (rawGambar != null) {
      if (rawGambar.startsWith('http')) {
        finalGambarUrl = rawGambar;
      } else {
        // Sesuaikan dengan IP server kamu
        finalGambarUrl = "http://202.155.95.224/storage/$rawGambar";
      }
    }

    return ProductModel(
      id: json['id'],
      namaProduk: json['nama_produk'] ?? '',
      harga: double.tryParse(json['harga'].toString()) ?? 0.0,
      stok: json['stok'] ?? 0,
      gambarUrl: finalGambarUrl,
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
