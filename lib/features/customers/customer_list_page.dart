import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/api/data_service.dart';
import '../../core/models/customer_model.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  List<CustomerModel> customers = [];
  List<CustomerModel> filteredCustomers = [];
  bool loading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  void _fetchCustomers() async {
    final data = await DataService.getCustomers();
    if (mounted) {
      setState(() {
        customers = data;
        filteredCustomers = data;
        loading = false;
      });
    }
  }

  void _filterCustomers(String query) {
    setState(() {
      filteredCustomers = customers
          .where((c) => c.nama.toLowerCase().contains(query.toLowerCase()) || c.noPlat.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showForm({CustomerModel? customer}) {
    final namaController = TextEditingController(text: customer?.nama);
    final noPlatController = TextEditingController(text: customer?.noPlat);
    final noHpController = TextEditingController(text: customer?.noHp);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          customer == null ? "Tambah Pelanggan" : "Edit Pelanggan",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Nama",
                labelStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: noPlatController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "No. Plat",
                labelStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: noHpController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "No. HP",
                labelStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              final newCustomer = CustomerModel(
                nama: namaController.text,
                noPlat: noPlatController.text,
                noHp: noHpController.text,
              );

              bool success;
              if (customer == null) {
                success = await DataService.addCustomer(newCustomer);
              } else {
                success = await DataService.updateCustomer(customer.id!, newCustomer);
              }

              if (success && mounted) {
                Navigator.pop(context);
                _fetchCustomers();
              }
            },
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteCustomer(int id) async {
    bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Hapus Pelanggan?"),
            content: const Text("Data ini akan dihapus secara permanen."),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Hapus", style: TextStyle(color: Colors.red))),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      bool success = await DataService.deleteCustomer(id);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pelanggan berhasil dihapus")));
          _fetchCustomers();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Gagal menghapus. Pelanggan mungkin terkait dengan riwayat transaksi."),
            backgroundColor: Colors.red,
          ));
        }
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
          "DATA PELANGGAN",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              controller: _searchController,
              onChanged: _filterCustomers,
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                hintText: "Cari nama atau plat nomor...",
                hintStyle: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.4)),
                prefixIcon: const Icon(Icons.search, color: Colors.green),
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
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : filteredCustomers.isEmpty
              ? Center(child: Text("Pelanggan tidak ditemukan", style: TextStyle(color: theme.textTheme.bodyMedium?.color)))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: filteredCustomers.length,
                  itemBuilder: (context, index) {
                    final c = filteredCustomers[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
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
                      child: ListTile(
                        leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.person, color: Colors.white)),
                        title: Text(c.nama, style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
                        subtitle: Text("${c.noPlat} | ${c.noHp ?? '-'}", style: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.5))),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.edit, color: Colors.blue, size: 20), onPressed: () => _showForm(customer: c)),
                            IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () => _deleteCustomer(c.id!)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () => _showForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
