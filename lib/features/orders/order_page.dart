import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/api/data_service.dart';
import '../../core/models/customer_model.dart';
import '../../core/models/product_model.dart';
import '../../core/models/service_model.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  List<CustomerModel> customers = [];
  List<ProductModel> products = [];
  List<ServiceModel> services = [];
  
  CustomerModel? selectedCustomer;
  List<ProductModel> selectedProducts = [];
  List<ServiceModel> selectedServices = [];
  
  bool loading = true;

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
        services = s;
        loading = false;
      });
    }
  }

  double get total {
    double pTotal = selectedProducts.fold(0.0, (sum, item) => sum + item.harga);
    double sTotal = selectedServices.fold(0.0, (sum, item) => sum + item.harga);
    return pTotal + sTotal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "BUAT TRANSAKSI",
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Pilih Pelanggan", style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<CustomerModel>(
                        dropdownColor: const Color(0xFF1E1E1E),
                        value: selectedCustomer,
                        hint: const Text("Pilih Pelanggan", style: TextStyle(color: Colors.grey)),
                        isExpanded: true,
                        style: const TextStyle(color: Colors.white),
                        items: customers.map((c) {
                          return DropdownMenuItem(
                            value: c,
                            child: Text("${c.nama} (${c.noPlat})"),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => selectedCustomer = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text("Layanan & Produk", style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView(
                      children: [
                        ...services.map((s) => CheckboxListTile(
                              title: Text(s.namaService, style: const TextStyle(color: Colors.white)),
                              subtitle: Text("Rp ${s.harga}", style: const TextStyle(color: Colors.blue)),
                              value: selectedServices.contains(s),
                              onChanged: (val) {
                                setState(() {
                                  if (val!) {
                                    selectedServices.add(s);
                                  } else {
                                    selectedServices.remove(s);
                                  }
                                });
                              },
                            )),
                        const Divider(color: Colors.grey),
                        ...products.map((p) => CheckboxListTile(
                              title: Text(p.namaProduk, style: const TextStyle(color: Colors.white)),
                              subtitle: Text("Rp ${p.harga}", style: const TextStyle(color: Colors.orange)),
                              value: selectedProducts.contains(p),
                              onChanged: (val) {
                                setState(() {
                                  if (val!) {
                                    selectedProducts.add(p);
                                  } else {
                                    selectedProducts.remove(p);
                                  }
                                });
                              },
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Total Bayar", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            Text("Rp $total", style: const TextStyle(color: Color(0xFFFF8C00), fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: selectedCustomer == null || (selectedProducts.isEmpty && selectedServices.isEmpty)
                                ? null
                                : () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Transaksi Berhasil (Simulasi)")),
                                    );
                                    Navigator.pop(context);
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF8C00),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("PROSES TRANSAKSI", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
