class CustomerModel {
  final int? id;
  final String nama;
  final String noPlat;
  final String? noHp;

  CustomerModel({
    this.id,
    required this.nama,
    required this.noPlat,
    this.noHp,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      nama: json['nama'] ?? '',
      noPlat: json['no_plat'] ?? '',
      noHp: json['no_hp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'no_plat': noPlat,
      'no_hp': noHp,
    };
  }
}
