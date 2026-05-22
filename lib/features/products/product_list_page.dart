import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/api/data_service.dart';
import '../../core/models/product_model.dart';
import '../../core/widgets/empty_state_widget.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<ProductModel> products = [];
  List<ProductModel> filteredProducts = [];
  bool loading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final data = await DataService.getProducts();
    if (mounted) {
      setState(() {
        products = data;
        filteredProducts = data;
        loading = false;
      });
    }
  }

  void _filterProducts(String query) {
    setState(() {
      filteredProducts = products
          .where((p) => p.namaProduk.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "DAFTAR PRODUK",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              controller: _searchController,
              onChanged: _filterProducts,
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                hintText: "Cari produk...",
                hintStyle: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.4)),
                prefixIcon: const Icon(Icons.search, color: Colors.orange),
                filled: true,
                fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15), 
                  borderSide: isDark ? BorderSide.none : BorderSide(color: Colors.grey.shade300)
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15), 
                  borderSide: isDark ? BorderSide.none : BorderSide(color: Colors.grey.shade300)
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF8C00)))
          : filteredProducts.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.inventory_2_outlined,
                  title: "Belum Ada Produk",
                  subtitle: "Mulai tambahkan sparepart atau produk yang dijual di bengkel.",
                  actionLabel: "Tambah Produk",
                  onAction: () => _showForm(),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          if (!isDark)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            )
                        ],
                        border: Border.all(color: isDark ? Colors.transparent : Colors.grey.shade100),
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
                                  style: TextStyle(
                                    color: theme.textTheme.bodyLarge?.color,
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
                                  if (product.stok < 5)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      margin: const EdgeInsets.only(bottom: 4),
                                      decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                                      child: const Text("Stok Rendah", style: TextStyle(color: Colors.red, fontSize: 8, fontWeight: FontWeight.bold)),
                                    ),
                                  Text(
                                    "Stok",
                                    style: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.5), fontSize: 12),
                                  ),
                                  Text(
                                    product.stok.toString(),
                                    style: TextStyle(
                                      color: product.stok < 5 ? Colors.red : theme.textTheme.bodyLarge?.color,
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

  void _showForm({ProductModel? product}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final namaController = TextEditingController(text: product?.namaProduk);
    final hargaController = TextEditingController(text: product?.harga.toStringAsFixed(0));
    final stokController = TextEditingController(text: product?.stok.toString());
    XFile? pickedImage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> pickImage() async {
            final ImagePicker picker = ImagePicker();
            final XFile? image = await picker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              setDialogState(() {
                pickedImage = image;
              });
            }
          }

          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              product == null ? "Tambah Produk" : "Edit Produk",
              style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade300),
                      ),
                      child: pickedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: kIsWeb ? Image.network(pickedImage!.path, fit: BoxFit.cover) : Image.file(File(pickedImage!.path), fit: BoxFit.cover),
                            )
                          : product?.gambarUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network(product!.gambarUrl!, fit: BoxFit.cover),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo, color: Colors.orange.withOpacity(0.5), size: 40),
                                    const SizedBox(height: 8),
                                    Text("Upload Gambar", style: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.5))),
                                  ],
                                ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: namaController,
                    style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                    decoration: InputDecoration(
                      labelText: "Nama Produk",
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: isDark ? BorderSide.none : BorderSide(color: Colors.grey.shade300)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: hargaController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                    decoration: InputDecoration(
                      labelText: "Harga",
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: isDark ? BorderSide.none : BorderSide(color: Colors.grey.shade300)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: stokController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                    decoration: InputDecoration(
                      labelText: "Stok",
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: isDark ? BorderSide.none : BorderSide(color: Colors.grey.shade300)),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal", style: TextStyle(color: Colors.grey))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  final newProduct = ProductModel(
                    namaProduk: namaController.text,
                    harga: double.tryParse(hargaController.text) ?? 0.0,
                    stok: int.tryParse(stokController.text) ?? 0,
                  );

                  bool success;
                  if (product == null) {
                    success = await DataService.addProduct(newProduct, imageFile: pickedImage);
                  } else {
                    success = await DataService.updateProduct(product.id!, newProduct, imageFile: pickedImage);
                  }

                  if (success && mounted) {
                    Navigator.pop(context);
                    _fetchProducts();
                  }
                },
                child: const Text("Simpan", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteProduct(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Produk"),
        content: const Text("Yakin ingin menghapus produk ini?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await DataService.deleteProduct(id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Produk berhasil dihapus")));
        _fetchProducts();
      }
    }
  }
}