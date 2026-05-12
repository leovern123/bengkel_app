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
  bool loading = true;

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
        loading = false;
      });
    }
  }

  void _showForm({ServiceModel? service}) {
    final namaController = TextEditingController(text: service?.namaService);
    final hargaController = TextEditingController(text: service?.harga.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          service == null ? "Tambah Layanan" : "Edit Layanan",
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Nama Layanan", labelStyle: TextStyle(color: Colors.grey)),
            ),
            TextField(
              controller: hargaController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Harga", labelStyle: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
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
            child: const Text("Simpan"),
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
      if (success) _fetchServices();
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
          "DAFTAR LAYANAN",
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : services.isEmpty
              ? const Center(child: Text("Tidak ada layanan", style: TextStyle(color: Colors.white)))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
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
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  "Jasa Perbaikan",
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
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

