import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/api/data_service.dart';
import '../../core/models/customer_model.dart';
import '../../core/models/product_model.dart';
import '../../core/models/service_model.dart';
import '../../core/utils/notification_service.dart';
import '../../core/utils/notification_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
                        _buildServiceSelector(theme),
                        if (selectedServiceIds.isNotEmpty) ...[
                          const SizedBox(height: 15),
                          _buildSelectedServicesList(theme),
                        ],
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
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            return _buildProductItem(theme, filteredProducts[index]);
                          },
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
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFF8C00).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded, color: Color(0xFFFF8C00)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<CustomerModel>(
                dropdownColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
                value: selectedCustomer,
                hint: Text("Pilih Pelanggan", style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4))),
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.primaryColor),
                style: GoogleFonts.outfit(color: theme.textTheme.bodyLarge?.color, fontSize: 16, fontWeight: FontWeight.w500),
                items: customers.map((c) {
                  return DropdownMenuItem(
                    value: c,
                    child: Text("${c.nama} - ${c.noPlat}"),
                  );
                }).toList(),
                onChanged: (val) => setState(() => selectedCustomer = val),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSelector(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF4285F4).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.build_circle_rounded, color: Color(0xFF4285F4)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ServiceModel>(
                dropdownColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
                value: null,
                hint: Text("Pilih Layanan...", style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4))),
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.primaryColor),
                style: GoogleFonts.outfit(color: theme.textTheme.bodyLarge?.color, fontSize: 16, fontWeight: FontWeight.w500),
                items: services.map((s) {
                  return DropdownMenuItem(
                    value: s,
                    child: Text("${s.namaService} - ${currencyFormat.format(s.harga)}"),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null && !selectedServiceIds.contains(val.id)) {
                    setState(() {
                      selectedServiceIds.add(val.id!);
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedServicesList(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      children: selectedServiceIds.map((id) {
        final service = services.firstWhere((s) => s.id == id);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2D2D2D) : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFF4285F4).withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(service.namaService, style: GoogleFonts.outfit(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(currencyFormat.format(service.harga), style: GoogleFonts.outfit(color: const Color(0xFF4285F4), fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                onPressed: () => setState(() => selectedServiceIds.remove(id)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              )
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProductItem(ThemeData theme, ProductModel product) {
    final isDark = theme.brightness == Brightness.dark;
    int qty = productQuantities[product.id] ?? 0;
    bool isSelected = qty > 0;
    int sisaStok = product.stok - qty;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isSelected 
            ? (isDark ? const Color(0xFF2D2D2D) : Colors.orange.shade50) 
            : (isDark ? const Color(0xFF1A1A1A) : Colors.white),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFFFF8C00).withOpacity(0.5) : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          if (!isDark && !isSelected)
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(15),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: product.gambarUrl != null
                  ? CachedNetworkImage(
                      imageUrl: product.gambarUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(15.0),
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF8C00)),
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.broken_image_rounded, color: theme.textTheme.bodySmall?.color?.withOpacity(0.5), size: 30),
                    )
                  : Icon(Icons.inventory_2_rounded, color: theme.textTheme.bodySmall?.color?.withOpacity(0.5), size: 30),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.namaProduk,
                  style: GoogleFonts.outfit(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  currencyFormat.format(product.harga),
                  style: GoogleFonts.outfit(color: const Color(0xFFFF8C00), fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: sisaStok <= 5 ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Stok: $sisaStok",
                    style: TextStyle(
                      color: sisaStok <= 5 ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF333333) : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: isDark ? Colors.transparent : Colors.grey.shade300),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  )
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove_rounded, color: qty > 0 ? const Color(0xFFFF8C00) : theme.textTheme.bodySmall?.color?.withOpacity(0.3), size: 20),
                  onPressed: qty > 0
                      ? () => setState(() {
                            productQuantities[product.id!] = qty - 1;
                            if (productQuantities[product.id] == 0) productQuantities.remove(product.id);
                          })
                      : null,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                ),
                Text(
                  "$qty",
                  style: GoogleFonts.outfit(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                IconButton(
                  icon: Icon(Icons.add_rounded, color: sisaStok > 0 ? const Color(0xFFFF8C00) : theme.textTheme.bodySmall?.color?.withOpacity(0.3), size: 20),
                  onPressed: sisaStok > 0
                      ? () => setState(() {
                            productQuantities[product.id!] = qty + 1;
                          })
                      : null,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
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
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 25,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
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
                      style: GoogleFonts.outfit(color: theme.textTheme.bodySmall?.color?.withOpacity(0.6), fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(total),
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFF8C00),
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: processing || selectedCustomer == null || (productQuantities.isEmpty && selectedServiceIds.isEmpty)
                          ? [Colors.grey.shade400, Colors.grey.shade500]
                          : [const Color(0xFFFF8C00), const Color(0xFFEA4335)],
                    ),
                    boxShadow: [
                      if (!processing && selectedCustomer != null && (productQuantities.isNotEmpty || selectedServiceIds.isNotEmpty))
                        BoxShadow(
                          color: const Color(0xFFFF8C00).withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        )
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: processing || selectedCustomer == null || (productQuantities.isEmpty && selectedServiceIds.isEmpty) ? null : _processOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: processing
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("PROSES", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
