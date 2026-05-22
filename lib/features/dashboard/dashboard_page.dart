import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';

import '../auth/auth_service.dart';
import '../auth/login_page.dart';

import '../../core/api/data_service.dart';
import '../orders/history_page.dart';
import '../products/product_list_page.dart';
import '../services/service_list_page.dart';
import '../customers/customer_list_page.dart';
import '../orders/order_page.dart';
import '../../main.dart'; // Import global themeNotifier

import '../reports/report_page.dart';
import '../profile/profile_page.dart';
import '../notifications/notification_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  late PageController _pageController;

  String userName = "Loading...";
  int productCount = 0;
  int serviceCount = 0;
  int customerCount = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Widget> pages = [
      _buildHome(theme, isDark),
      const ReportPage(),
      const HistoryPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: loading
          ? _buildDashboardShimmer(theme, isDark)
          : PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _selectedIndex = index);
              },
              children: pages,
            ),
      bottomNavigationBar: _buildBottomNav(theme),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderPage())).then((_) => _loadDashboardData());
        },
        backgroundColor: const Color(0xFFFF8C00),
        child: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHome(ThemeData theme, bool isDark) {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      color: const Color(0xFFFF8C00),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
        _buildSliverAppBar(isDark),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                _buildStatCards(theme),
                const SizedBox(height: 35),
                _buildSectionHeader(theme, "Layanan Utama", Icons.grid_view_rounded),
                const SizedBox(height: 15),
                _buildMenuGrid(theme),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
      ),
    );
  }

  Widget _buildSliverAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 220,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF8C00), Color(0xFFE65100)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(35),
              bottomRight: Radius.circular(35),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF8C00).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Dekorasi Background
              Positioned(
                right: -40,
                top: 0,
                child: Icon(
                  Icons.two_wheeler_rounded,
                  size: 200,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
              Positioned(
                left: -20,
                bottom: -20,
                child: Icon(
                  Icons.build_rounded,
                  size: 120,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              // Greeting Content
              Positioned(
                bottom: 30,
                left: 25,
                right: 25,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Text(
                        "Bengkel App",
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Halo, $userName! 👋",
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Siap mengelola bengkel hari ini?",
                      style: GoogleFonts.outfit(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
          },
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationPage()));
              },
            ),
            Positioned(
              right: 12,
              top: 14,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFF8C00), width: 1.5),
                ),
                constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
              ),
            )
          ],
        ),
        Container(
          margin: const EdgeInsets.only(right: 15, top: 8, bottom: 8, left: 5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
            onPressed: _logout,
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardShimmer(ThemeData theme, bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.white10 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.white24 : Colors.grey.shade100,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 220,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: Container(height: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)))),
                      const SizedBox(width: 12),
                      Expanded(child: Container(height: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)))),
                      const SizedBox(width: 12),
                      Expanded(child: Container(height: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)))),
                    ],
                  ),
                  const SizedBox(height: 35),
                  Container(height: 25, width: 150, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                  const SizedBox(height: 15),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.3,
                    children: List.generate(4, (index) => Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // (Greeting has been moved to the App Bar)

  Widget _buildStatCards(ThemeData theme) {
    return Row(
      children: [
        _buildStatItem(theme, "Produk", productCount.toString(), Icons.inventory_2_rounded, const Color(0xFFFF8C00)),
        const SizedBox(width: 12),
        _buildStatItem(theme, "Layanan", serviceCount.toString(), Icons.handyman_rounded, const Color(0xFF4285F4)),
        const SizedBox(width: 12),
        _buildStatItem(theme, "Pelanggan", customerCount.toString(), Icons.people_alt_rounded, const Color(0xFF34A853)),
      ],
    );
  }

  Widget _buildStatItem(ThemeData theme, String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFF8C00), size: 20),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuGrid(ThemeData theme) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.3,
      children: [
        _buildMenuButton(theme, "Management Produk", FontAwesomeIcons.cubes, const Color(0xFFFF8C00), () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductListPage())).then((_) => _loadDashboardData());
        }),
        _buildMenuButton(theme, "Daftar Layanan", FontAwesomeIcons.screwdriverWrench, const Color(0xFF4285F4), () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ServiceListPage())).then((_) => _loadDashboardData());
        }),
        _buildMenuButton(theme, "Data Pelanggan", FontAwesomeIcons.userGroup, const Color(0xFF34A853), () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomerListPage())).then((_) => _loadDashboardData());
        }),
        _buildMenuButton(theme, "Riwayat Order", FontAwesomeIcons.fileInvoiceDollar, const Color(0xFFEA4335), () {
          _onItemTapped(2);
        }),
      ],
    );
  }

  Widget _buildMenuButton(ThemeData theme, String title, IconData icon, Color color, VoidCallback onTap) {
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: isDark ? Colors.transparent : Colors.black.withOpacity(0.05)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned(
                right: -10,
                bottom: -10,
                child: Icon(icon, size: 80, color: color.withOpacity(0.05)),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: color, size: 28),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        color: theme.textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildBottomNav(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      color: Colors.transparent,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.5 : 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: isDark ? Colors.transparent : Colors.black.withOpacity(0.05)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(theme, 0, Icons.grid_view_rounded, "Home", () => _onItemTapped(0)),
            _buildNavItem(theme, 1, Icons.analytics_rounded, "Rekap", () => _onItemTapped(1)),
            const SizedBox(width: 40),
            _buildNavItem(theme, 2, Icons.history_rounded, "History", () => _onItemTapped(2)),
            _buildNavItem(theme, 3, Icons.person_rounded, "Profile", () => _onItemTapped(3)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(ThemeData theme, int index, IconData icon, String label, VoidCallback onTap) {
    bool isSelected = _selectedIndex == index;
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFFFF8C00) : (isDark ? Colors.white24 : Colors.black26),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: isSelected ? const Color(0xFFFF8C00) : (isDark ? Colors.white24 : Colors.black26),
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}