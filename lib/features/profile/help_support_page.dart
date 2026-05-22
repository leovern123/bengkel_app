import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  final List<_FaqItem> _faqItems = [
    _FaqItem(
      question: "Bagaimana cara membuat pesanan baru?",
      answer: "Buka halaman 'Pesanan', lalu tap tombol '+' di pojok kanan bawah. "
          "Isi formulir dengan data pelanggan, pilih layanan yang diinginkan, "
          "dan tap 'Simpan' untuk membuat pesanan baru.",
    ),
    _FaqItem(
      question: "Bagaimana cara mengubah status pesanan?",
      answer: "Pada halaman detail pesanan, Anda dapat mengubah status pesanan "
          "dari 'Pending' menjadi 'Dikerjakan' atau 'Selesai' dengan mengetap "
          "tombol status yang tersedia.",
    ),
    _FaqItem(
      question: "Bagaimana cara menambah layanan baru?",
      answer: "Buka halaman 'Layanan', tap tombol '+' untuk menambahkan layanan baru. "
          "Masukkan nama layanan dan harga, lalu simpan.",
    ),
    _FaqItem(
      question: "Bagaimana cara mengubah foto profil?",
      answer: "Buka halaman 'Profil', tap ikon kamera di foto profil Anda. "
          "Pilih foto dari galeri dan tunggu proses upload selesai.",
    ),
    _FaqItem(
      question: "Bagaimana cara melihat laporan?",
      answer: "Buka halaman 'Laporan' untuk melihat ringkasan pendapatan, "
          "jumlah pesanan, dan data statistik lainnya. Anda juga dapat "
          "mengekspor laporan ke format PDF.",
    ),
    _FaqItem(
      question: "Apakah data saya aman?",
      answer: "Ya, data Anda disimpan secara aman di server kami. Kami menggunakan "
          "enkripsi dan autentikasi token untuk melindungi semua data Anda.",
    ),
    _FaqItem(
      question: "Bagaimana cara mengganti password?",
      answer: "Buka halaman 'Profil', lalu tap menu 'Ubah Password'. "
          "Masukkan password lama, password baru, dan konfirmasi password baru.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("HELP & SUPPORT", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            _buildHeaderCard(isDark),
            const SizedBox(height: 28),

            // Contact section
            _buildSectionTitle("Hubungi Kami"),
            const SizedBox(height: 12),
            _buildContactCards(isDark),
            const SizedBox(height: 28),

            // FAQ
            _buildSectionTitle("Pertanyaan Umum (FAQ)"),
            const SizedBox(height: 12),
            _buildFaqSection(isDark),
            const SizedBox(height: 28),

            // Quick actions
            _buildSectionTitle("Aksi Cepat"),
            const SizedBox(height: 12),
            _buildQuickActions(isDark),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8C00), Color(0xFFEA4335)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8C00).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            "Ada yang bisa kami bantu?",
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tim kami siap membantu Anda kapan saja.\nJangan ragu untuk menghubungi kami!",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCards(bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildContactCard(
                icon: Icons.email_rounded,
                iconColor: const Color(0xFF4CAF50),
                title: "Email",
                subtitle: "support@bengkelapp.com",
                isDark: isDark,
                onTap: () => _showContactInfo("Email", "support@bengkelapp.com"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildContactCard(
                icon: Icons.phone_rounded,
                iconColor: const Color(0xFF2196F3),
                title: "Telepon",
                subtitle: "+62 812-3456-7890",
                isDark: isDark,
                onTap: () => _showContactInfo("Telepon", "+62 812-3456-7890"),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildContactCard(
                icon: Icons.chat_rounded,
                iconColor: const Color(0xFF25D366),
                title: "WhatsApp",
                subtitle: "+62 812-3456-7890",
                isDark: isDark,
                onTap: () => _showContactInfo("WhatsApp", "+62 812-3456-7890"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildContactCard(
                icon: Icons.access_time_rounded,
                iconColor: const Color(0xFFFF8C00),
                title: "Jam Kerja",
                subtitle: "Sen-Sab, 08-17",
                isDark: isDark,
                onTap: () => _showContactInfo("Jam Operasional", "Senin - Sabtu\n08:00 - 17:00 WIB"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqSection(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ExpansionPanelList.radio(
          elevation: 0,
          expandedHeaderPadding: EdgeInsets.zero,
          dividerColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
          children: _faqItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return ExpansionPanelRadio(
              value: index,
              backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              canTapOnHeader: true,
              headerBuilder: (context, isExpanded) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isExpanded
                              ? const Color(0xFFFF8C00).withValues(alpha: 0.12)
                              : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            "${index + 1}",
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isExpanded ? const Color(0xFFFF8C00) : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.question,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              body: Padding(
                padding: const EdgeInsets.fromLTRB(60, 0, 20, 16),
                child: Text(
                  item.answer,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.6,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
        ),
      ),
      child: Column(
        children: [
          _buildActionTile(
            icon: Icons.bug_report_rounded,
            iconColor: const Color(0xFFF44336),
            title: "Laporkan Masalah",
            subtitle: "Kirim laporan bug atau error",
            isDark: isDark,
            onTap: () => _showReportDialog(),
          ),
          Divider(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
            height: 1,
          ),
          _buildActionTile(
            icon: Icons.lightbulb_rounded,
            iconColor: const Color(0xFFFFEB3B),
            title: "Kirim Saran",
            subtitle: "Bantu kami meningkatkan aplikasi",
            isDark: isDark,
            onTap: () => _showSuggestionDialog(),
          ),
          Divider(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
            height: 1,
          ),
          _buildActionTile(
            icon: Icons.star_rounded,
            iconColor: const Color(0xFFFF8C00),
            title: "Beri Rating",
            subtitle: "Beri penilaian di Play Store",
            isDark: isDark,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber),
                      const SizedBox(width: 10),
                      Text("Terima kasih atas minat Anda!", style: GoogleFonts.outfit()),
                    ],
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
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

  void _showContactInfo(String title, String info) {
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    info,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
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

  void _showReportDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.bug_report_rounded, color: Colors.red, size: 28),
                ),
                const SizedBox(height: 16),
                Text("Laporkan Masalah", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Jelaskan masalah yang Anda alami...",
                    hintStyle: GoogleFonts.outfit(color: Colors.grey),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: GoogleFonts.outfit(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: Text("Batal", style: GoogleFonts.outfit(color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.white),
                                  const SizedBox(width: 10),
                                  Text("Laporan berhasil dikirim!", style: GoogleFonts.outfit()),
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
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text("Kirim", style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSuggestionDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.lightbulb_rounded, color: Colors.amber, size: 28),
                ),
                const SizedBox(height: 16),
                Text("Kirim Saran", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Tulis saran atau ide Anda...",
                    hintStyle: GoogleFonts.outfit(color: Colors.grey),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: GoogleFonts.outfit(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: Text("Batal", style: GoogleFonts.outfit(color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.white),
                                  const SizedBox(width: 10),
                                  Text("Saran berhasil dikirim. Terima kasih!", style: GoogleFonts.outfit()),
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
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text("Kirim", style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;

  _FaqItem({required this.question, required this.answer});
}
