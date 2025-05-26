import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simpan_pinjam/models/anggota.dart';
import 'package:simpan_pinjam/services/supabase_service.dart';

final anggotaListProvider = FutureProvider<List<Anggota>>((ref) async {
  final service = SupabaseService();
  return service.getAnggotaList();
});
