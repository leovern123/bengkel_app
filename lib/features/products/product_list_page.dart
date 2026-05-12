import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/api/data_service.dart';
import '../../core/models/product_model.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<ProductModel> products = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  void _fetchProducts() async {
    final data = await DataService.getProducts();
    if (mounted) {
      setState(() {
        products = data;
        loading = false;
      });
    }
  }

  void _showForm({ProductModel? product}) {
    final namaController = TextEditingController(text: product?.namaProduk);
    final hargaController = TextEditingController(text: product?.harga.toStringAsFixed(0));
    final stokController = TextEditingController(text: product?.stok.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          product == null ? "Tambah Produk" : "Edit Produk",
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Nama Produk", labelStyle: TextStyle(color: Colors.grey)),
            ),
            TextField(
              controller: hargaController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Harga", labelStyle: TextStyle(color: Colors.grey)),
            ),
            TextField(
              controller: stokController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Stok", labelStyle: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              final newProduct = ProductModel(
                namaProduk: namaController.text,
                harga: double.tryParse(hargaController.text) ?? 0.0,
                stok: int.tryParse(stokController.text) ?? 0,
              );

              bool success;
              if (product == null) {
                success = await DataService.addProduct(newProduct);
              } else {
                success = await DataService.updateProduct(product.id!, newProduct);
              }

              if (success && mounted) {
                Navigator.pop(context);
                _fetchProducts();
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(int id) async {
    bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Hapus Produk?"),
            content: const Text("Data ini akan dihapus secara permanen."),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Hapus", style: TextStyle(color: Colors.red))),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      bool success = await DataService.deleteProduct(id);
      if (success) _fetchProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "DAFTAR PRODUK",
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF8C00)))
          : products.isEmpty
              ? const Center(child: Text("Tidak ada produk", style: TextStyle(color: Colors.white)))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: product.gambarUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      product.gambarUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, color: Colors.orange),
                                    ),
                                  )
                                : const Icon(Icons.image, color: Colors.orange),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.namaProduk,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Rp ${product.harga.toStringAsFixed(0)}",
                                  style: const TextStyle(color: Color(0xFFFF8C00)),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    "Stok",
                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                  Text(
                                    product.stok.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 10),
                              IconButton(icon: const Icon(Icons.edit, color: Colors.blue, size: 20), onPressed: () => _showForm(product: product)),
                              IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () => _deleteProduct(product.id!)),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () => _showForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

