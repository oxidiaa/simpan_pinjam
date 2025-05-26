import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/simpanan.dart';
import '../models/anggota.dart';
import '../services/supabase_service.dart';
import 'package:go_router/go_router.dart';

final simpananListProvider = FutureProvider<List<Simpanan>>((ref) async {
  final service = SupabaseService();
  return service.getSimpananList();
});

final anggotaListProvider = FutureProvider<List<Anggota>>((ref) async {
  final service = SupabaseService();
  return service.getAnggotaList();
});

class SimpananScreen extends ConsumerWidget {
  const SimpananScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final simpananListAsync = ref.watch(simpananListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Simpanan'),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 16),
          ),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddSimpananDialog(context, ref),
          ),
        ],
      ),
      body: simpananListAsync.when(
        data: (simpananList) {
          if (simpananList.isEmpty) {
            return const Center(
              child: Text('Belum ada data simpanan'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: simpananList.length,
            itemBuilder: (context, index) {
              final simpanan = simpananList[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green,
                    child: const Icon(Icons.account_balance_wallet,
                        color: Colors.white),
                  ),
                  title: FutureBuilder<Anggota?>(
                    future: _getAnggota(simpanan.idAnggota),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(snapshot.data!.nama);
                      }
                      return const Text('Loading...');
                    },
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Jumlah: Rp ${simpanan.jumlah.toStringAsFixed(2)}'),
                      Text('Jenis: ${simpanan.jenis}'),
                      Text('Tanggal: ${_formatDate(simpanan.tanggalSimpan)}'),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Hapus'),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditSimpananDialog(context, ref, simpanan);
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(context, ref, simpanan);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Future<Anggota?> _getAnggota(int idAnggota) async {
    final service = SupabaseService();
    final anggotaList = await service.getAnggotaList();
    return anggotaList.firstWhere((a) => a.idAnggota == idAnggota);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _showAddSimpananDialog(
      BuildContext context, WidgetRef ref) async {
    final formKey = GlobalKey<FormState>();
    final jumlahController = TextEditingController();
    final jenisController = TextEditingController();
    Anggota? selectedAnggota;

    final anggotaList = await ref.read(anggotaListProvider.future);

    if (context.mounted) {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Tambah Simpanan'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Anggota>(
                    decoration: const InputDecoration(labelText: 'Anggota'),
                    items: anggotaList.map((anggota) {
                      return DropdownMenuItem(
                        value: anggota,
                        child: Text(anggota.nama),
                      );
                    }).toList(),
                    onChanged: (value) {
                      selectedAnggota = value;
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Pilih anggota';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: jumlahController,
                    decoration: const InputDecoration(labelText: 'Jumlah'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Jumlah tidak boleh kosong';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Masukkan angka yang valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: jenisController,
                    decoration:
                        const InputDecoration(labelText: 'Jenis Simpanan'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Jenis simpanan tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate() &&
                    selectedAnggota != null) {
                  final service = SupabaseService();
                  final simpanan = Simpanan(
                    idAnggota: selectedAnggota!.idAnggota!,
                    tanggalSimpan: DateTime.now(),
                    jumlah: double.parse(jumlahController.text),
                    jenis: jenisController.text,
                  );
                  await service.createSimpanan(simpanan);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ref.refresh(simpananListProvider);
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _showEditSimpananDialog(
    BuildContext context,
    WidgetRef ref,
    Simpanan simpanan,
  ) async {
    final formKey = GlobalKey<FormState>();
    final jumlahController =
        TextEditingController(text: simpanan.jumlah.toString());
    final jenisController = TextEditingController(text: simpanan.jenis);
    Anggota? selectedAnggota;

    final anggotaList = await ref.read(anggotaListProvider.future);
    selectedAnggota =
        anggotaList.firstWhere((a) => a.idAnggota == simpanan.idAnggota);

    if (context.mounted) {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Edit Simpanan'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Anggota>(
                    decoration: const InputDecoration(labelText: 'Anggota'),
                    value: selectedAnggota,
                    items: anggotaList.map((anggota) {
                      return DropdownMenuItem(
                        value: anggota,
                        child: Text(anggota.nama),
                      );
                    }).toList(),
                    onChanged: (value) {
                      selectedAnggota = value;
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Pilih anggota';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: jumlahController,
                    decoration: const InputDecoration(labelText: 'Jumlah'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Jumlah tidak boleh kosong';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Masukkan angka yang valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: jenisController,
                    decoration:
                        const InputDecoration(labelText: 'Jenis Simpanan'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Jenis simpanan tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate() &&
                    selectedAnggota != null) {
                  final service = SupabaseService();
                  final updatedSimpanan = Simpanan(
                    idSimpanan: simpanan.idSimpanan,
                    idAnggota: selectedAnggota!.idAnggota!,
                    tanggalSimpan: simpanan.tanggalSimpan,
                    jumlah: double.parse(jumlahController.text),
                    jenis: jenisController.text,
                  );
                  await service.updateSimpanan(updatedSimpanan);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ref.refresh(simpananListProvider);
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Simpanan simpanan,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content:
            const Text('Apakah Anda yakin ingin menghapus data simpanan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (simpanan.idSimpanan != null) {
                final service = SupabaseService();
                await service.deleteSimpanan(simpanan.idSimpanan!);
                if (context.mounted) {
                  Navigator.pop(context);
                  ref.refresh(simpananListProvider);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
