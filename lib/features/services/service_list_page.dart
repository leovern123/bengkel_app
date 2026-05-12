import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/api/data_service.dart';
import '../../core/models/service_model.dart';

class ServiceListPage extends StatefulWidget {
  const ServiceListPage({super.key});

  @override
  State<ServiceListPage> createState() => _ServiceListPageState();
}

class _ServiceListPageState extends State<ServiceListPage> {
  List<ServiceModel> services = [];
  List<ServiceModel> filteredServices = [];
  bool loading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  void _fetchServices() async {
    final data = await DataService.getServices();
    if (mounted) {
      setState(() {
        services = data;
        filteredServices = data;
        loading = false;
      });
    }
  }

  void _filterServices(String query) {
    setState(() {
      filteredServices = services
          .where((s) => s.namaService.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showForm({ServiceModel? service}) {
    final namaController = TextEditingController(text: service?.namaService);
    final hargaController = TextEditingController(text: service?.harga.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          service == null ? "Tambah Layanan" : "Edit Layanan",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Nama Layanan",
                labelStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: hargaController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Harga",
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              final newService = ServiceModel(
                namaService: namaController.text,
                harga: double.tryParse(hargaController.text) ?? 0.0,
              );

              bool success;
              if (service == null) {
                success = await DataService.addService(newService);
              } else {
                success = await DataService.updateService(service.id!, newService);
              }

              if (success && mounted) {
                Navigator.pop(context);
                _fetchServices();
              }
            },
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteService(int id) async {
    bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Hapus Layanan?"),
            content: const Text("Data ini akan dihapus secara permanen."),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Hapus", style: TextStyle(color: Colors.red))),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      bool success = await DataService.deleteService(id);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Layanan berhasil dihapus")));
          _fetchServices();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Gagal menghapus. Layanan mungkin sudah ada di riwayat transaksi."),
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
          "DAFTAR LAYANAN",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              controller: _searchController,
              onChanged: _filterServices,
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                hintText: "Cari layanan...",
                hintStyle: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.4)),
                prefixIcon: const Icon(Icons.search, color: Colors.blue),
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
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : filteredServices.isEmpty
              ? Center(child: Text("Layanan tidak ditemukan", style: TextStyle(color: theme.textTheme.bodyMedium?.color)))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: filteredServices.length,
                  itemBuilder: (context, index) {
                    final service = filteredServices[index];
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
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.build, color: Colors.blue),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service.namaService,
                                  style: TextStyle(
                                    color: theme.textTheme.bodyLarge?.color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Jasa Perbaikan",
                                  style: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.5), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Rp ${service.harga.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(icon: const Icon(Icons.edit, color: Colors.blue, size: 20), onPressed: () => _showForm(service: service)),
                                  IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () => _deleteService(service.id!)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () => _showForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
