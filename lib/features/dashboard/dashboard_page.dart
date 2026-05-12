import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../auth/auth_service.dart';
import '../auth/login_page.dart';

import '../../core/api/data_service.dart';

import '../products/product_list_page.dart';
import '../services/service_list_page.dart';
import '../customers/customer_list_page.dart';
import '../orders/order_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  String userName = "Loading...";

  int productCount = 0;
  int serviceCount = 0;
  int customerCount = 0;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final profile = await AuthService.profile();
    final products = await DataService.getProducts();
    final services = await DataService.getServices();
    final customers = await DataService.getCustomers();

    if (mounted) {
      setState(() {
        userName = profile?['name'] ?? "User";
        productCount = products.length;
        serviceCount = services.length;
        customerCount = customers.length;
        loading = false;
      });
    }
  }

  Future<void> _logout() async {
    bool success = await AuthService.logout();

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
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
          "BENGKEL APP",
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: _logout,
          ),

          const SizedBox(width: 10),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _loadDashboardData,

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Halo, $userName!",
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                "Selamat datang di Sistem Manajemen Bengkel",
                style: TextStyle(
                  color: Colors.grey[400],
                ),
              ),

              const SizedBox(height: 25),

              // Statistik
              _buildServiceStatusCard(),

              const SizedBox(height: 30),

              Text(
                "Layanan Utama",
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 15),

              // Menu Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),

                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.1,

                children: [
                  _buildMenuCard(
                    "Produk",
                    FontAwesomeIcons.boxesStacked,
                    Colors.orange,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ProductListPage(),
                        ),
                      );
                    },
                  ),

                  _buildMenuCard(
                    "Layanan",
                    FontAwesomeIcons.screwdriverWrench,
                    Colors.blue,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ServiceListPage(),
                        ),
                      );
                    },
                  ),

                  _buildMenuCard(
                    "Pelanggan",
                    FontAwesomeIcons.users,
                    Colors.green,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const CustomerListPage(),
                        ),
                      );
                    },
                  ),

                  _buildMenuCard(
                    "Transaksi",
                    FontAwesomeIcons.fileInvoiceDollar,
                    Colors.purple,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const OrderPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Promo Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF8C00),
                      Color(0xFFFF4500),
                    ],
                  ),

                  borderRadius: BorderRadius.circular(15),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "PROMO BULAN INI!",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      "Diskon 20% untuk ganti oli dan filter udara.",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 15),

                    ElevatedButton(
                      onPressed: () {},

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.orange,

                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                      ),

                      child: const Text(
                        "KLAIM SEKARANG",
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1E1E1E),

        selectedItemColor: const Color(0xFFFF8C00),
        unselectedItemColor: Colors.grey,

        type: BottomNavigationBarType.fixed,

        currentIndex: _selectedIndex,

        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Beranda",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: "Kendaraan",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "Riwayat",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profil",
          ),
        ],
      ),
    );
  }

  Widget _buildServiceStatusCard() {
    return Row(
      children: [
        _buildStatCard(
          "Produk",
          productCount.toString(),
          Icons.inventory_2,
          Colors.orange,
        ),

        const SizedBox(width: 10),

        _buildStatCard(
          "Layanan",
          serviceCount.toString(),
          Icons.build,
          Colors.blue,
        ),

        const SizedBox(width: 10),

        _buildStatCard(
          "Pelanggan",
          customerCount.toString(),
          Icons.people,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 15,
        ),

        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),

          borderRadius: BorderRadius.circular(15),

          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),

        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),

            const SizedBox(height: 8),

            Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            Text(
              title,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),

        borderRadius: BorderRadius.circular(15),
      ),

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          onTap: onTap,

          borderRadius: BorderRadius.circular(15),

          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [
              Icon(
                icon,
                size: 30,
                color: color,
              ),

              const SizedBox(height: 10),

              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}