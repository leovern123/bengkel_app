import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/api/data_service.dart';
import '../../core/models/customer_model.dart';
import '../../core/models/product_model.dart';
import '../../core/models/service_model.dart';
import '../../core/utils/notification_service.dart';
import '../../core/utils/notification_manager.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  List<CustomerModel> customers = [];
  List<ProductModel> products = [];
  List<ProductModel> filteredProducts = [];
  List<ServiceModel> services = [];

  CustomerModel? selectedCustomer;
  Map<int, int> productQuantities = {}; // Product ID -> Quantity
  Set<int> selectedServiceIds = {}; // Service IDs

  bool loading = true;
  bool processing = false;

  final TextEditingController _productSearchController = TextEditingController();
  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    final c = await DataService.getCustomers();
    final p = await DataService.getProducts();
    final s = await DataService.getServices();

    if (mounted) {
      setState(() {
        customers = c;
        products = p;
        filteredProducts = p;
        services = s;
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

  double get total {
    double pTotal = 0;
    productQuantities.forEach((id, qty) {
      try {
        final product = products.firstWhere((p) => p.id == id);
        pTotal += product.harga * qty;
      } catch (e) {
        // Handle case where product might not be in the current list
      }
    });

    double sTotal = 0;
    for (var id in selectedServiceIds) {
      try {
        final service = services.firstWhere((s) => s.id == id);
        sTotal += service.harga;
      } catch (e) {}
    }
    return pTotal + sTotal;
  }
void _processOrder() async {
  if (selectedCustomer == null) return;

  setState(() => processing = true);

  List<Map<String, dynamic>> items = [];

  // =========================
  // SERVICES
  // =========================
  for (var id in selectedServiceIds) {
    final service =
        services.firstWhere((s) => s.id == id);

    items.add({
      'qty': 1,

      'service': {
        'id': id,
        'harga': service.harga,
      }
    });
  }

  // =========================
  // PRODUCTS
  // =========================
  productQuantities.forEach((id, qty) {

    if (qty > 0) {

      items.add({
        'qty': qty,

        'product': {
          'id': id,
        }
      });
    }
  });

    // =========================
    // ORDER DATA
    // =========================
    final orderData = {
      'customer_id': selectedCustomer!.id,

      // sementara hardcode user login
      'user_id': 1,

      'tanggal': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),

      // backend Laravel membaca "details"
      'details': items,
    };

  print(orderData);

  bool success =
      await DataService.addOrder(orderData);

  if (mounted) {

    setState(() => processing = false);

    if (success) {
      // Record real notification for transaction
      NotificationManager.addNotification(
        title: "Transaksi Berhasil",
        body: "Pesanan untuk ${selectedCustomer?.nama} senilai ${currencyFormat.format(total)} telah disimpan.",
        type: NotificationType.success,
      );

      // Check for low stock
      productQuantities.forEach((id, qty) {
        try {
          final product = products.firstWhere((p) => p.id == id);
          int remainingStok = product.stok - qty;
          if (remainingStok <= 5) {
            NotificationManager.addNotification(
              title: "Peringatan Stok!",
              body: "${product.namaProduk} sisa $remainingStok item. Segera restock!",
              type: NotificationType.warning,
            );
            NotificationService.showNotification(
              id: id,
              title: "Stok Menipis!",
              body: "${product.namaProduk} tinggal $remainingStok botol.",
            );
          }
        } catch (e) {}
      });

      NotificationService.showNotification(
        title: "Transaksi Berhasil",
        body: "Pesanan untuk ${selectedCustomer?.nama} senilai ${currencyFormat.format(total)} telah disimpan.",
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Transaksi berhasil disimpan!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Gagal menyimpan transaksi (cek kembali stok barang)."
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
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
          "TRANSAKSI BARU",
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w800,
            color: theme.textTheme.bodyLarge?.color,
            letterSpacing: 1,
          ),
        ),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(theme, "Data Pelanggan"),
                        const SizedBox(height: 12),
                        _buildCustomerSelector(theme),
                        const SizedBox(height: 30),
                        _buildSectionTitle(theme, "Pilih Layanan"),
                        const SizedBox(height: 12),
                        Column(
                          children: services.map((s) => _buildServiceItem(theme, s)).toList(),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSectionTitle(theme, "Pilih Produk / Part"),
                            Icon(Icons.inventory_2_outlined, color: theme.primaryColor, size: 18),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _productSearchController,
                          onChanged: _filterProducts,
                          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                          decoration: InputDecoration(
                            hintText: "Cari produk atau part...",
                            hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4), fontSize: 14),
                            prefixIcon: Icon(Icons.search, color: theme.primaryColor, size: 20),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: isDark ? BorderSide.none : BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: isDark ? BorderSide.none : BorderSide(color: Colors.grey.shade300),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Column(
                          children: filteredProducts.map((p) => _buildProductItem(theme, p)).toList(),
                        ),
                        if (filteredProducts.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                "Produk tidak ditemukan",
                                style: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.4)),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                _buildSummaryPanel(theme),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        color: theme.textTheme.bodyLarge?.color,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCustomerSelector(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CustomerModel>(
          dropdownColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          value: selectedCustomer,
          hint: Text("Pilih Pelanggan", style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4))),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.primaryColor),
          style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 15),
          items: customers.map((c) {
            return DropdownMenuItem(
              value: c,
              child: Text("${c.nama} - ${c.noPlat}"),
            );
          }).toList(),
          onChanged: (val) => setState(() => selectedCustomer = val),
        ),
      ),
    );
  }

  Widget _buildServiceItem(ThemeData theme, ServiceModel service) {
    final isDark = theme.brightness == Brightness.dark;
    bool isSelected = selectedServiceIds.contains(service.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected 
            ? (isDark ? const Color(0xFF2D2D2D) : Colors.orange.shade50) 
            : (isDark ? const Color(0xFF1A1A1A) : Colors.white),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isSelected ? theme.primaryColor.withOpacity(0.3) : (isDark ? Colors.transparent : Colors.grey.shade200),
        ),
      ),
      child: CheckboxListTile(
        activeColor: theme.primaryColor,
        checkColor: Colors.white,
        title: Text(
          service.namaService,
          style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          currencyFormat.format(service.harga),
          style: const TextStyle(color: Color(0xFF4285F4), fontWeight: FontWeight.bold),
        ),
        value: isSelected,
        onChanged: (val) {
          setState(() {
            if (val!) {
              selectedServiceIds.add(service.id!);
            } else {
              selectedServiceIds.remove(service.id);
            }
          });
        },
      ),
    );
  }

  Widget _buildProductItem(ThemeData theme, ProductModel product) {
    final isDark = theme.brightness == Brightness.dark;
    int qty = productQuantities[product.id] ?? 0;
    bool isSelected = qty > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected 
            ? (isDark ? const Color(0xFF2D2D2D) : Colors.orange.shade50) 
            : (isDark ? const Color(0xFF1A1A1A) : Colors.white),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isSelected ? theme.primaryColor.withOpacity(0.3) : (isDark ? Colors.transparent : Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.namaProduk,
                  style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.w600),
                ),
                Text(
                  currencyFormat.format(product.harga),
                  style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove, color: theme.textTheme.bodySmall?.color?.withOpacity(0.5), size: 18),
                  onPressed: qty > 0
                      ? () => setState(() {
                            productQuantities[product.id!] = qty - 1;
                            if (productQuantities[product.id] == 0) productQuantities.remove(product.id);
                          })
                      : null,
                ),
                Text(
                  "$qty",
                  style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.add, color: theme.primaryColor, size: 18),
                  onPressed: () => setState(() {
                    productQuantities[product.id!] = qty + 1;
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryPanel(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.5 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        border: isDark ? null : Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Pembayaran",
                    style: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.5), fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormat.format(total),
                    style: GoogleFonts.outfit(
                      color: theme.textTheme.bodyLarge?.color,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: processing || selectedCustomer == null || (productQuantities.isEmpty && selectedServiceIds.isEmpty) ? null : _processOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8C00),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                ),
                child: processing
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text("PROSES", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
