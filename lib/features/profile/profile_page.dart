import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../auth/auth_service.dart';
import '../auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userProfile;
  bool loading = true;
  File? _image;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Foto profil diperbarui!")),
      );
    }
  }

  Future<void> _loadProfile() async {
    final profile = await AuthService.profile();
    if (mounted) {
      setState(() {
        userProfile = profile;
        loading = false;
      });
    }
  }

  Future<void> _logout() async {
    bool success = await AuthService.logout();
    if (success && mounted) {
      Navigator.of(context, rootNavigator: true).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("MANAGEMENT PROFILE", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  _buildProfileHeader(theme, isDark),
                  const SizedBox(height: 35),
                  _buildProfileInfo(theme, isDark),
                  const SizedBox(height: 35),
                  _buildActionButtons(theme, isDark),
                ],
              ),
            ),
    );
  }

  void _showChangePasswordDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Ubah Password", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password Lama",
                labelStyle: GoogleFonts.outfit(),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password Baru",
                labelStyle: GoogleFonts.outfit(),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Konfirmasi Password",
                labelStyle: GoogleFonts.outfit(),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal", style: GoogleFonts.outfit(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Fitur Ubah Password akan segera tersedia")),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8C00),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text("Simpan", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme, bool isDark) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF8C00), Color(0xFFEA4335)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF8C00).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: ClipOval(
                child: _image != null
                    ? Image.file(_image!, fit: BoxFit.cover)
                    : const Center(
                        child: Icon(Icons.person_rounded, size: 60, color: Colors.white),
                      ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 20),
        Text(
          userProfile?['name'] ?? "User",
          style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          userProfile?['email'] ?? "email@example.com",
          style: GoogleFonts.outfit(color: theme.hintColor),
        ),
      ],
    );
  }

  Widget _buildProfileInfo(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.person_outline_rounded, "Username", userProfile?['name'] ?? "-", theme),
          const Divider(height: 30),
          _buildInfoRow(Icons.email_outlined, "Email", userProfile?['email'] ?? "-", theme),
          const Divider(height: 30),
          _buildInfoRow(Icons.calendar_today_outlined, "Member Since", "May 2024", theme),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFF8C00), size: 20),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.outfit(fontSize: 12, color: theme.hintColor)),
            Text(value, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600)),
          ],
        )
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme, bool isDark) {
    return Column(
      children: [
        _buildMenuAction(Icons.lock_outline_rounded, "Ubah Password", theme, isDark, onTap: _showChangePasswordDialog),
        const SizedBox(height: 12),
        _buildMenuAction(Icons.settings_outlined, "Settings", theme, isDark),
        const SizedBox(height: 12),
        _buildMenuAction(Icons.help_outline_rounded, "Help & Support", theme, isDark),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _logout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.1),
              foregroundColor: Colors.red,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: Text("LOGOUT", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
        )
      ],
    );
  }

  Widget _buildMenuAction(IconData icon, String title, ThemeData theme, bool isDark, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.hintColor, size: 20),
            const SizedBox(width: 15),
            Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: theme.hintColor),
          ],
        ),
      ),
    );
  }
}
