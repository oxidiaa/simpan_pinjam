import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/anggota.dart';
import '../models/simpanan.dart';
import '../models/pinjaman.dart';
import '../models/transaksi.dart';

class SupabaseService {
  final _supabase = Supabase.instance.client;

  // Anggota CRUD
  Future<List<Anggota>> getAnggotaList() async {
    final response = await _supabase.from('anggota').select();
    return (response as List).map((json) => Anggota.fromJson(json)).toList();
  }

  Future<void> createAnggota(Anggota anggota) async {
    try {
      final response = await _supabase.from('anggota').insert({
        'nama': anggota.nama,
        'alamat': anggota.alamat,
        'telepon': anggota.telepon,
        'email': anggota.email,
        'tanggal_masuk': anggota.tanggalMasuk.toIso8601String(),
      }).select();

      if (response == null || response.isEmpty) {
        throw Exception('Failed to create anggota');
      }
    } catch (e) {
      throw Exception('Error creating anggota: $e');
    }
  }

  Future<void> updateAnggota(Anggota anggota) async {
    if (anggota.idAnggota == null) return;
    await _supabase
        .from('anggota')
        .update(anggota.toJson())
        .eq('id_anggota', anggota.idAnggota!);
  }

  Future<void> deleteAnggota(int idAnggota) async {
    await _supabase.from('anggota').delete().eq('id_anggota', idAnggota);
  }

  // Simpanan CRUD
  Future<List<Simpanan>> getSimpananList() async {
    final response = await _supabase.from('simpanan').select();
    return (response as List).map((json) => Simpanan.fromJson(json)).toList();
  }

  Future<void> createSimpanan(Simpanan simpanan) async {
    await _supabase.from('simpanan').insert(simpanan.toJson());
  }

  Future<void> updateSimpanan(Simpanan simpanan) async {
    if (simpanan.idSimpanan == null) return;
    await _supabase
        .from('simpanan')
        .update(simpanan.toJson())
        .eq('id_simpanan', simpanan.idSimpanan!);
  }

  Future<void> deleteSimpanan(int idSimpanan) async {
    await _supabase.from('simpanan').delete().eq('id_simpanan', idSimpanan);
  }

  // Pinjaman CRUD
  Future<List<Pinjaman>> getPinjamanList() async {
    final response = await _supabase.from('pinjaman').select();
    return (response as List).map((json) => Pinjaman.fromJson(json)).toList();
  }

  Future<void> createPinjaman(Pinjaman pinjaman) async {
    await _supabase.from('pinjaman').insert(pinjaman.toJson());
  }

  Future<void> updatePinjaman(Pinjaman pinjaman) async {
    if (pinjaman.idPinjaman == null) return;
    await _supabase
        .from('pinjaman')
        .update(pinjaman.toJson())
        .eq('id_pinjaman', pinjaman.idPinjaman!);
  }

  Future<void> deletePinjaman(int idPinjaman) async {
    await _supabase.from('pinjaman').delete().eq('id_pinjaman', idPinjaman);
  }

  // Transaksi CRUD
  Future<List<Transaksi>> getTransaksiList() async {
    final response = await _supabase.from('transaksi').select();
    return (response as List).map((json) => Transaksi.fromJson(json)).toList();
  }

  Future<void> createTransaksi(Transaksi transaksi) async {
    await _supabase.from('transaksi').insert(transaksi.toJson());
  }

  Future<void> updateTransaksi(Transaksi transaksi) async {
    if (transaksi.idTransaksi == null) return;
    await _supabase
        .from('transaksi')
        .update(transaksi.toJson())
        .eq('id_transaksi', transaksi.idTransaksi!);
  }

  Future<void> deleteTransaksi(int idTransaksi) async {
    await _supabase.from('transaksi').delete().eq('id_transaksi', idTransaksi);
  }

  Future<void> addTransaksi(Transaksi transaksi) async {
    await _supabase.from('transaksi').insert({
      'id_anggota': transaksi.idAnggota,
      'tanggal_transaksi': transaksi.tanggalTransaksi.toIso8601String(),
      'jenis': transaksi.jenis,
      'jumlah': transaksi.jumlah,
      'keterangan': transaksi.keterangan,
    });
  }

  // Test connection
  Future<bool> testConnection() async {
    try {
      await _supabase.from('anggota').select().limit(1);
      return true;
    } catch (e) {
      return false;
    }
  }
}
