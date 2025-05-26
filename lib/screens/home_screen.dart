import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/supabase_service.dart';
import '../models/anggota.dart';
import '../models/simpanan.dart';
import '../models/pinjaman.dart';
import '../models/transaksi.dart';

final summaryProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = SupabaseService();
  final anggotaList = await service.getAnggotaList();
  final simpananList = await service.getSimpananList();
  final pinjamanList = await service.getPinjamanList();
  final transaksiList = await service.getTransaksiList();

  // Calculate total savings
  final totalSimpanan = simpananList.fold<double>(
    0,
    (sum, simpanan) => sum + simpanan.jumlah,
  );

  // Calculate total loans
  final totalPinjaman = pinjamanList.fold<double>(
    0,
    (sum, pinjaman) => sum + pinjaman.jumlah,
  );

  // Calculate total interest
  final totalBunga = pinjamanList.fold<double>(
    0,
    (sum, pinjaman) => sum + (pinjaman.jumlah * pinjaman.bunga / 100),
  );

  // Get recent transactions
  final recentTransaksi = transaksiList
    ..sort((a, b) => b.tanggalTransaksi.compareTo(a.tanggalTransaksi));
  final latestTransaksi = recentTransaksi.take(5).toList();

  return {
    'totalAnggota': anggotaList.length,
    'totalSimpanan': totalSimpanan,
    'totalPinjaman': totalPinjaman,
    'totalBunga': totalBunga,
    'latestTransaksi': latestTransaksi,
  };
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(summaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: summaryAsync.when(
        data: (summary) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              _buildSummaryCards(context, summary),
              const SizedBox(height: 24),
              _buildQuickActions(context),
              const SizedBox(height: 24),
              _buildRecentTransactions(context, summary['latestTransaksi']),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue,
            child: Icon(
              Icons.account_balance,
              size: 30,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selamat Datang',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kelola data simpan pinjam Anda',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(
      BuildContext context, Map<String, dynamic> summary) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildSummaryCard(
          context,
          'Total Anggota',
          summary['totalAnggota'].toString(),
          Icons.people,
          Colors.blue,
        ),
        _buildSummaryCard(
          context,
          'Total Simpanan',
          'Rp ${summary['totalSimpanan'].toStringAsFixed(2)}',
          Icons.account_balance_wallet,
          Colors.green,
        ),
        _buildSummaryCard(
          context,
          'Total Pinjaman',
          'Rp ${summary['totalPinjaman'].toStringAsFixed(2)}',
          Icons.money,
          Colors.orange,
        ),
        _buildSummaryCard(
          context,
          'Total Bunga',
          'Rp ${summary['totalBunga'].toStringAsFixed(2)}',
          Icons.percent,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Menu Cepat',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2.5,
          children: [
            _buildMenuButton(
              context,
              'Anggota',
              Icons.people,
              Colors.blue,
              () => context.go('/anggota'),
            ),
            _buildMenuButton(
              context,
              'Simpanan',
              Icons.account_balance_wallet,
              Colors.green,
              () => context.go('/simpanan'),
            ),
            _buildMenuButton(
              context,
              'Pinjaman',
              Icons.money,
              Colors.orange,
              () => context.go('/pinjaman'),
            ),
            _buildMenuButton(
              context,
              'Transaksi',
              Icons.swap_horiz,
              Colors.purple,
              () => context.go('/transaksi'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(
      BuildContext context, List<Transaksi> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Transaksi Terbaru',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final transaksi = transactions[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: transaksi.jenis == 'Setoran'
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  child: Icon(
                    transaksi.jenis == 'Setoran'
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    color: transaksi.jenis == 'Setoran'
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                title: Text(
                  transaksi.jenis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Rp ${transaksi.jumlah.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: transaksi.jenis == 'Setoran'
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                trailing: Text(
                  _formatDate(transaksi.tanggalTransaksi),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
