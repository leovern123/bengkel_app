import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/api/data_service.dart';
import '../../core/models/order_model.dart';
import '../../core/utils/receipt_service.dart';
import '../../core/widgets/empty_state_widget.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  List<OrderModel> orders = [];
  List<OrderModel> filteredOrders = [];
  bool loading = true;
  String filterType = 'Daily'; // Daily, Monthly, Yearly
  DateTime selectedDate = DateTime.now();
  int _currentPage = 0;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => loading = true);
    final data = await DataService.getOrders();
    if (mounted) {
      setState(() {
        orders = data;
        _applyFilter();
        loading = false;
      });
    }
  }

  void _applyFilter() {
    setState(() {
      filteredOrders = orders.where((order) {
        if (filterType == 'Daily') {
          return order.tanggal.year == selectedDate.year &&
              order.tanggal.month == selectedDate.month &&
              order.tanggal.day == selectedDate.day;
        } else if (filterType == 'Monthly') {
          return order.tanggal.year == selectedDate.year &&
              order.tanggal.month == selectedDate.month;
        } else {
          return order.tanggal.year == selectedDate.year;
        }
      }).toList()
        ..sort((a, b) => b.tanggal.compareTo(a.tanggal)); // Terbaru di atas
      _currentPage = 0;
    });
  }

  double get totalIncome => filteredOrders.fold(0, (sum, item) => sum + item.total);

  String get filterLabel {
    if (filterType == 'Daily') return DateFormat('dd MMMM yyyy').format(selectedDate);
    if (filterType == 'Monthly') return DateFormat('MMMM yyyy').format(selectedDate);
    return DateFormat('yyyy').format(selectedDate);
  }

  Future<void> _selectDate() async {
    if (filterType == 'Daily') {
      final picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      );
      if (picked != null) {
        setState(() {
          selectedDate = picked;
          _applyFilter();
        });
      }
    } else if (filterType == 'Monthly') {
      // Simple month picker using a dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Pilih Bulan"),
          content: SizedBox(
            width: 300,
            height: 300,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemCount: 12,
              itemBuilder: (context, index) {
                return TextButton(
                  onPressed: () {
                    setState(() {
                      selectedDate = DateTime(selectedDate.year, index + 1);
                      _applyFilter();
                    });
                    Navigator.pop(context);
                  },
                  child: Text(DateFormat('MMM').format(DateTime(2024, index + 1))),
                );
              },
            ),
          ),
        ),
      );
    } else {
      // Year picker
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Pilih Tahun"),
          content: SizedBox(
            width: 300,
            height: 300,
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                final year = DateTime.now().year - index;
                return ListTile(
                  title: Text(year.toString()),
                  onTap: () {
                    setState(() {
                      selectedDate = DateTime(year);
                      _applyFilter();
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ),
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
        title: Text("REKAP TRANSAKSI", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_rounded),
            onPressed: () async {
              await ReceiptService.printReport(
                title: filterType,
                dateLabel: filterLabel,
                orders: filteredOrders,
                totalIncome: totalIncome,
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          _buildFilterTabs(theme, isDark),
          _buildSummaryCard(theme, isDark),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      _buildChart(theme, isDark),
                      Expanded(child: _buildOrderList(theme, isDark)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: ['Daily', 'Monthly', 'Yearly'].map((type) {
          bool isSelected = filterType == type;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  filterType = type;
                  _applyFilter();
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFF8C00) : (isDark ? Colors.white10 : Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    type == 'Daily' ? 'Harian' : (type == 'Monthly' ? 'Bulanan' : 'Tahunan'),
                    style: GoogleFonts.outfit(
                      color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme, bool isDark) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8C00), Color(0xFFEA4335)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8C00).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total Pendapatan", style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(currencyFormat.format(totalIncome), style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.calendar_month_rounded, color: Colors.white),
                ),
              )
            ],
          ),
          const Divider(color: Colors.white24, height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(filterLabel, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600)),
              Text("${filteredOrders.length} Transaksi", style: GoogleFonts.outfit(color: Colors.white70)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildOrderList(ThemeData theme, bool isDark) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    if (filteredOrders.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchOrders,
        color: const Color(0xFFFF8C00),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: const EmptyStateWidget(
                icon: Icons.receipt_long_outlined,
                title: "Tidak Ada Transaksi",
                subtitle: "Belum ada transaksi pada periode ini.",
              ),
            ),
          ],
        ),
      );
    }

    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, filteredOrders.length);
    final pageOrders = filteredOrders.sublist(startIndex, endIndex);

    return RefreshIndicator(
      onRefresh: _fetchOrders,
      color: const Color(0xFFFF8C00),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: pageOrders.length,
              itemBuilder: (context, index) {
                final order = pageOrders[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Transaksi #${order.id}", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                            Text(DateFormat('dd MMM yyyy, HH:mm').format(order.tanggal), style: GoogleFonts.outfit(fontSize: 12, color: theme.hintColor)),
                          ],
                        ),
                      ),
                      Text(currencyFormat.format(order.total), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFFFF8C00))),
                    ],
                  ),
                );
              },
            ),
          ),
          _buildPaginationControls(theme, isDark),
        ],
      ),
    );
  }

  Widget _buildPaginationControls(ThemeData theme, bool isDark) {
    final totalPages = (filteredOrders.length / _itemsPerPage).ceil();
    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: _currentPage > 0
                ? () {
                    setState(() {
                      _currentPage--;
                    });
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8C00),
              foregroundColor: Colors.white,
              disabledBackgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
              disabledForegroundColor: isDark ? Colors.white30 : Colors.grey.shade400,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Prev"),
          ),
          Text(
            "${_currentPage + 1} / $totalPages",
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          ElevatedButton(
            onPressed: (_currentPage + 1) * _itemsPerPage < filteredOrders.length
                ? () {
                    setState(() {
                      _currentPage++;
                    });
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8C00),
              foregroundColor: Colors.white,
              disabledBackgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
              disabledForegroundColor: isDark ? Colors.white30 : Colors.grey.shade400,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Next"),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(ThemeData theme, bool isDark) {
    if (filteredOrders.isEmpty) return const SizedBox.shrink();

    List<BarChartGroupData> barGroups = [];
    double maxY = 0;

    if (filterType == 'Yearly') {
      Map<int, double> monthlyData = {};
      for (var order in filteredOrders) {
        monthlyData[order.tanggal.month] = (monthlyData[order.tanggal.month] ?? 0) + order.total;
      }
      for (int i = 1; i <= 12; i++) {
        double val = monthlyData[i] ?? 0;
        if (val > maxY) maxY = val;
        barGroups.add(BarChartGroupData(
          x: i,
          barRods: [BarChartRodData(toY: val, color: const Color(0xFFFF8C00), width: 12, borderRadius: BorderRadius.circular(4))],
        ));
      }
    } else if (filterType == 'Monthly') {
      Map<int, double> dailyData = {};
      int daysInMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
      for (var order in filteredOrders) {
        dailyData[order.tanggal.day] = (dailyData[order.tanggal.day] ?? 0) + order.total;
      }
      for (int i = 1; i <= daysInMonth; i++) {
        double val = dailyData[i] ?? 0;
        if (val > maxY) maxY = val;
        barGroups.add(BarChartGroupData(
          x: i,
          barRods: [BarChartRodData(toY: val, color: const Color(0xFFFF8C00), width: 6, borderRadius: BorderRadius.circular(2))],
        ));
      }
    } else {
      Map<int, double> hourlyData = {};
      for (var order in filteredOrders) {
        hourlyData[order.tanggal.hour] = (hourlyData[order.tanggal.hour] ?? 0) + order.total;
      }
      for (int i = 6; i <= 22; i++) {
        double val = hourlyData[i] ?? 0;
        if (val > maxY) maxY = val;
        barGroups.add(BarChartGroupData(
          x: i,
          barRods: [BarChartRodData(toY: val, color: const Color(0xFFFF8C00), width: 12, borderRadius: BorderRadius.circular(4))],
        ));
      }
    }

    maxY = maxY * 1.2;
    if (maxY == 0) maxY = 100;

    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Grafik Pendapatan", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: theme.textTheme.bodyLarge?.color)),
          const SizedBox(height: 20),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (filterType == 'Yearly') {
                          final months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
                          if (value.toInt() >= 1 && value.toInt() <= 12) {
                            return Text(months[value.toInt() - 1], style: const TextStyle(fontSize: 10));
                          }
                        } else if (filterType == 'Monthly') {
                          if (value.toInt() % 5 == 0 || value.toInt() == 1) {
                            return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
                          }
                        } else {
                          if (value.toInt() % 3 == 0) {
                            return Text("${value.toInt()}:00", style: const TextStyle(fontSize: 10));
                          }
                        }
                        return const Text('');
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4 == 0 ? 1 : maxY / 4,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: barGroups,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
