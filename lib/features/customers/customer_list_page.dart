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
  bool loading = true;

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
        loading = false;
      });
    }
  }

  void _showForm({CustomerModel? customer}) {
    final namaController = TextEditingController(text: customer?.nama);
    final noPlatController = TextEditingController(text: customer?.noPlat);
    final noHpController = TextEditingController(text: customer?.noHp);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          customer == null ? "Tambah Pelanggan" : "Edit Pelanggan",
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Nama", labelStyle: TextStyle(color: Colors.grey)),
            ),
            TextField(
              controller: noPlatController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "No. Plat", labelStyle: TextStyle(color: Colors.grey)),
            ),
            TextField(
              controller: noHpController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "No. HP", labelStyle: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
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
            child: const Text("Simpan"),
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
      if (success) _fetchCustomers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("DATA PELANGGAN", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : customers.isEmpty
              ? const Center(child: Text("Belum ada pelanggan", style: TextStyle(color: Colors.white)))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final c = customers[index];
                    return Card(
                      color: const Color(0xFF1E1E1E),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.person, color: Colors.white)),
                        title: Text(c.nama, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text("${c.noPlat} | ${c.noHp ?? '-'}", style: const TextStyle(color: Colors.grey)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showForm(customer: c)),
                            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteCustomer(c.id!)),
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
