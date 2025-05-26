import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simpan_pinjam/models/transaksi.dart';
import 'package:simpan_pinjam/services/supabase_service.dart';

final transaksiListProvider = FutureProvider<List<Transaksi>>((ref) async {
  final service = SupabaseService();
  return service.getTransaksiList();
});
