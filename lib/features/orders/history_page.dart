import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/api/data_service.dart';
import '../../core/models/order_model.dart';
import '../../core/models/customer_model.dart';
import '../../core/models/product_model.dart';
import '../../core/models/service_model.dart';
import '../../core/utils/receipt_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<OrderModel> orders = [];
  List<OrderModel> filteredOrders = [];
  List<CustomerModel> customers = [];
  List<ProductModel> products = [];
  List<ServiceModel> services = [];
  bool loading = true;
  final TextEditingController _searchController = TextEditingController();
  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    final o = await DataService.getOrders();
    final c = await DataService.getCustomers();
    final p = await DataService.getProducts();
    final s = await DataService.getServices();
    if (mounted) {
      setState(() {
        orders = o.reversed.toList(); // Newest first
        filteredOrders = orders;
        customers = c;
        products = p;
        services = s;
        loading = false;
      });
    }
  }

  void _filterOrders(String query) {
    setState(() {
      filteredOrders = orders.where((order) {
        final customerName = _getCustomerName(order.customerId).toLowerCase();
        return customerName.contains(query.toLowerCase());
      }).toList();
    });
  }

  String _getItemName(OrderDetailModel item) {
    if (item.productId != null) {
      try {
        return products.firstWhere((p) => p.id == item.productId).namaProduk;
      } catch (e) {
        return "Produk #${item.productId}";
      }
    } else if (item.serviceId != null) {
      try {
        return services.firstWhere((s) => s.id == item.serviceId).namaService;
      } catch (e) {
        return "Layanan #${item.serviceId}";
      }
    }
    return "Unknown Item";
  }

  String _getCustomerName(int id) {
    try {
      return customers.firstWhere((c) => c.id == id).nama;
    } catch (e) {
      return "Unknown";
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
          "RIWAYAT TRANSAKSI",
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w800, 
            color: theme.textTheme.bodyLarge?.color, 
            letterSpacing: 1
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              controller: _searchController,
              onChanged: _filterOrders,
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                hintText: "Cari nama pelanggan...",
                hintStyle: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.4)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFFF8C00)),
                filled: true,
                fillColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: isDark ? BorderSide.none : BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: isDark ? BorderSide.none : BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF8C00)))
          : RefreshIndicator(
              onRefresh: _fetchHistory,
              color: const Color(0xFFFF8C00),
              child: filteredOrders.isEmpty
                  ? _buildEmptyState(theme)
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        return _buildOrderCard(theme, order);
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 80, color: theme.textTheme.bodySmall?.color?.withOpacity(0.1)),
          const SizedBox(height: 20),
          Text(
            "Belum ada transaksi",
            style: GoogleFonts.outfit(color: theme.textTheme.bodySmall?.color?.withOpacity(0.5), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(ThemeData theme, OrderModel order) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showOrderDetail(order),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8C00).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.receipt_long_rounded, color: Color(0xFFFF8C00), size: 24),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getCustomerName(order.customerId),
                        style: GoogleFonts.outfit(
                          color: theme.textTheme.bodyLarge?.color, 
                          fontWeight: FontWeight.bold, 
                          fontSize: 16
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormat.format(order.tanggal),
                        style: GoogleFonts.outfit(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.5), 
                          fontSize: 12
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currencyFormat.format(order.total),
                      style: GoogleFonts.outfit(color: const Color(0xFFFF8C00), fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "SELESAI",
                        style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOrderDetail(OrderModel order) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(25),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Text(
                "Detail Transaksi",
                style: GoogleFonts.outfit(
                  color: theme.textTheme.bodyLarge?.color,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailRow(
                theme,
                "Pelanggan",
                _getCustomerName(order.customerId),
              ),
              _buildDetailRow(
                theme,
                "Tanggal",
                dateFormat.format(order.tanggal),
              ),
              Divider(
                color: isDark ? Colors.white12 : Colors.grey.shade200,
                height: 40,
              ),
              Text(
                "Item / Layanan",
                style: GoogleFonts.outfit(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 15),
              ...(order.details ?? []).map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${item.qty}x",
                          style: const TextStyle(
                            color: Color(0xFFFF8C00),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          _getItemName(item),
                          style: TextStyle(
                            color: theme.textTheme.bodyLarge?.color,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        currencyFormat.format(item.subtotal),
                        style: TextStyle(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              Divider(
                color: isDark ? Colors.white12 : Colors.grey.shade200,
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Akhir",
                    style: TextStyle(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    currencyFormat.format(order.total),
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFF8C00),
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _printReceipt(order),
                  icon: const Icon(Icons.print_rounded),
                  label: Text(
                    "PRINT STRUK",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8C00),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }

  void _printReceipt(OrderModel order) async {
    final customer = customers.firstWhere((c) => c.id == order.customerId,
        orElse: () => CustomerModel(nama: "Pelanggan #${order.customerId}", noPlat: ""));

    List<Map<String, dynamic>> receiptItems = [];

    if (order.details != null) {
      for (var detail in order.details!) {
        String name = "Unknown";
        double subtotal = detail.subtotal;

        if (detail.serviceId != null) {
          final s = services.firstWhere((s) => s.id == detail.serviceId,
              orElse: () => ServiceModel(namaService: "Layanan #${detail.serviceId}", harga: 0));
          name = s.namaService;
        } else if (detail.productId != null) {
          final p = products.firstWhere((p) => p.id == detail.productId,
              orElse: () => ProductModel(namaProduk: "Produk #${detail.productId}", harga: 0, stok: 0));
          name = p.namaProduk;
        }

        receiptItems.add({
          'name': name,
          'qty': detail.qty,
          'price': subtotal / detail.qty,
          'subtotal': subtotal,
        });
      }
    }

    try {
      await ReceiptService.printReceipt(
        order: order,
        customer: customer,
        items: receiptItems,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mencetak: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildDetailRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.5), fontSize: 14)),
          Text(value, style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
