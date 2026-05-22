import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = true;
  bool _notificationsEnabled = true;
  bool _orderNotif = true;
  bool _promoNotif = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? true;
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _orderNotif = prefs.getBool('orderNotif') ?? true;
      _promoNotif = prefs.getBool('promoNotif') ?? false;
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
    setState(() => _isDarkMode = value);
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
    setState(() {
      _notificationsEnabled = value;
      if (!value) {
        _orderNotif = false;
        _promoNotif = false;
        prefs.setBool('orderNotif', false);
        prefs.setBool('promoNotif', false);
      }
    });
  }

  Future<void> _toggleOrderNotif(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('orderNotif', value);
    setState(() => _orderNotif = value);
  }

  Future<void> _togglePromoNotif(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('promoNotif', value);
    setState(() => _promoNotif = value);
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF8C00), Color(0xFFEA4335)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF8C00).withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.build_rounded, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 20),
                Text(
                  "Bengkel App",
                  style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  "Versi 1.0.0",
                  style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    "Aplikasi manajemen bengkel terbaik untuk membantu Anda mengelola pesanan, pelanggan, layanan, dan laporan dengan mudah.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(fontSize: 13, height: 1.6, color: Colors.grey.shade600),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "© 2024 Bengkel App. All rights reserved.",
                  style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8C00),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text("Tutup", style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("SETTINGS", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TAMPILAN
            _buildSectionTitle("Tampilan"),
            const SizedBox(height: 12),
            _buildSettingsCard(isDark, [
              _buildSwitchTile(
                icon: Icons.dark_mode_rounded,
                iconColor: const Color(0xFF6C63FF),
                title: "Mode Gelap",
                subtitle: _isDarkMode ? "Aktif" : "Nonaktif",
                value: _isDarkMode,
                onChanged: _toggleDarkMode,
                isDark: isDark,
              ),
            ]),

            const SizedBox(height: 28),

            // NOTIFIKASI
            _buildSectionTitle("Notifikasi"),
            const SizedBox(height: 12),
            _buildSettingsCard(isDark, [
              _buildSwitchTile(
                icon: Icons.notifications_rounded,
                iconColor: const Color(0xFFFF8C00),
                title: "Notifikasi",
                subtitle: _notificationsEnabled ? "Semua notifikasi aktif" : "Nonaktif",
                value: _notificationsEnabled,
                onChanged: _toggleNotifications,
                isDark: isDark,
              ),
              if (_notificationsEnabled) ...[
                Divider(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100, height: 1),
                _buildSwitchTile(
                  icon: Icons.shopping_bag_rounded,
                  iconColor: const Color(0xFF4CAF50),
                  title: "Notifikasi Pesanan",
                  subtitle: "Update status pesanan",
                  value: _orderNotif,
                  onChanged: _toggleOrderNotif,
                  isDark: isDark,
                  compact: true,
                ),
                Divider(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100, height: 1),
                _buildSwitchTile(
                  icon: Icons.local_offer_rounded,
                  iconColor: const Color(0xFFE91E63),
                  title: "Notifikasi Promo",
                  subtitle: "Penawaran & diskon",
                  value: _promoNotif,
                  onChanged: _togglePromoNotif,
                  isDark: isDark,
                  compact: true,
                ),
              ],
            ]),

            const SizedBox(height: 28),

            // LAINNYA
            _buildSectionTitle("Lainnya"),
            const SizedBox(height: 12),
            _buildSettingsCard(isDark, [
              _buildTapTile(
                icon: Icons.language_rounded,
                iconColor: const Color(0xFF2196F3),
                title: "Bahasa",
                trailing: Text("Indonesia", style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13)),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Saat ini hanya tersedia Bahasa Indonesia", style: GoogleFonts.outfit()),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                isDark: isDark,
              ),
              Divider(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100, height: 1),
              _buildTapTile(
                icon: Icons.info_outline_rounded,
                iconColor: const Color(0xFF9C27B0),
                title: "Tentang Aplikasi",
                trailing: Text("v1.0.0", style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13)),
                onTap: _showAboutDialog,
                isDark: isDark,
              ),
            ]),

            const SizedBox(height: 28),

            // CACHE
            _buildSettingsCard(isDark, [
              _buildTapTile(
                icon: Icons.cleaning_services_rounded,
                iconColor: const Color(0xFFFF5722),
                title: "Bersihkan Cache",
                trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                onTap: () async {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: Text("Bersihkan Cache?", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                      content: Text(
                        "Data cache akan dihapus. Ini tidak akan menghapus data akun Anda.",
                        style: GoogleFonts.outfit(),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text("Batal", style: GoogleFonts.outfit(color: Colors.grey)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: Colors.white),
                                    const SizedBox(width: 10),
                                    Text("Cache berhasil dibersihkan!", style: GoogleFonts.outfit()),
                                  ],
                                ),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF8C00),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text("Bersihkan", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                },
                isDark: isDark,
              ),
            ]),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFFF8C00),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(bool isDark, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
    bool compact = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: compact ? 10 : 14),
      child: Row(
        children: [
          Container(
            width: compact ? 36 : 42,
            height: compact ? 36 : 42,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: compact ? 18 : 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: compact ? 14 : 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFFF8C00),
          ),
        ],
      ),
    );
  }

  Widget _buildTapTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget trailing,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
