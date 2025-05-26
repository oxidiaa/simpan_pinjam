import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pinjaman.dart';
import '../models/anggota.dart';
import '../services/supabase_service.dart';
import 'package:go_router/go_router.dart';

final pinjamanListProvider = FutureProvider<List<Pinjaman>>((ref) async {
  final service = SupabaseService();
  return service.getPinjamanList();
});

final anggotaListProvider = FutureProvider<List<Anggota>>((ref) async {
  final service = SupabaseService();
  return service.getAnggotaList();
});

class PinjamanScreen extends ConsumerWidget {
  const PinjamanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinjamanListAsync = ref.watch(pinjamanListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Pinjaman'),
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
            onPressed: () => _showAddPinjamanDialog(context, ref),
          ),
        ],
      ),
      body: pinjamanListAsync.when(
        data: (pinjamanList) {
          if (pinjamanList.isEmpty) {
            return const Center(
              child: Text('Belum ada data pinjaman'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pinjamanList.length,
            itemBuilder: (context, index) {
              final pinjaman = pinjamanList[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: const Icon(Icons.money, color: Colors.white),
                  ),
                  title: FutureBuilder<Anggota?>(
                    future: _getAnggota(pinjaman.idAnggota),
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
                      Text('Jumlah: Rp ${pinjaman.jumlah.toStringAsFixed(2)}'),
                      Text('Bunga: ${pinjaman.bunga}%'),
                      Text('Jangka Waktu: ${pinjaman.jangkaWaktu} bulan'),
                      Text('Tanggal: ${_formatDate(pinjaman.tanggalPinjam)}'),
                      Text('Status: ${pinjaman.status}'),
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
                        _showEditPinjamanDialog(context, ref, pinjaman);
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(context, ref, pinjaman);
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

  Future<void> _showAddPinjamanDialog(
      BuildContext context, WidgetRef ref) async {
    final formKey = GlobalKey<FormState>();
    final jumlahController = TextEditingController();
    final bungaController = TextEditingController();
    final jangkaWaktuController = TextEditingController();
    Anggota? selectedAnggota;

    final anggotaList = await ref.read(anggotaListProvider.future);

    if (context.mounted) {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Tambah Pinjaman'),
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
                    decoration:
                        const InputDecoration(labelText: 'Jumlah Pinjaman'),
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
                    controller: bungaController,
                    decoration: const InputDecoration(labelText: 'Bunga (%)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Bunga tidak boleh kosong';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Masukkan angka yang valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: jangkaWaktuController,
                    decoration: const InputDecoration(
                        labelText: 'Jangka Waktu (bulan)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Jangka waktu tidak boleh kosong';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Masukkan angka yang valid';
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
                  final pinjaman = Pinjaman(
                    idAnggota: selectedAnggota!.idAnggota!,
                    tanggalPinjam: DateTime.now(),
                    jumlah: double.parse(jumlahController.text),
                    bunga: double.parse(bungaController.text),
                    jangkaWaktu: int.parse(jangkaWaktuController.text),
                    status: 'Belum Lunas',
                  );
                  await service.createPinjaman(pinjaman);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ref.refresh(pinjamanListProvider);
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

  Future<void> _showEditPinjamanDialog(
    BuildContext context,
    WidgetRef ref,
    Pinjaman pinjaman,
  ) async {
    final formKey = GlobalKey<FormState>();
    final jumlahController =
        TextEditingController(text: pinjaman.jumlah.toString());
    final bungaController =
        TextEditingController(text: pinjaman.bunga.toString());
    final jangkaWaktuController =
        TextEditingController(text: pinjaman.jangkaWaktu.toString());
    Anggota? selectedAnggota;

    final anggotaList = await ref.read(anggotaListProvider.future);
    selectedAnggota =
        anggotaList.firstWhere((a) => a.idAnggota == pinjaman.idAnggota);

    if (context.mounted) {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Edit Pinjaman'),
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
                    decoration:
                        const InputDecoration(labelText: 'Jumlah Pinjaman'),
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
                    controller: bungaController,
                    decoration: const InputDecoration(labelText: 'Bunga (%)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Bunga tidak boleh kosong';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Masukkan angka yang valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: jangkaWaktuController,
                    decoration: const InputDecoration(
                        labelText: 'Jangka Waktu (bulan)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Jangka waktu tidak boleh kosong';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Masukkan angka yang valid';
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
                  final updatedPinjaman = Pinjaman(
                    idPinjaman: pinjaman.idPinjaman,
                    idAnggota: selectedAnggota!.idAnggota!,
                    tanggalPinjam: pinjaman.tanggalPinjam,
                    jumlah: double.parse(jumlahController.text),
                    bunga: double.parse(bungaController.text),
                    jangkaWaktu: int.parse(jangkaWaktuController.text),
                    status: pinjaman.status,
                  );
                  await service.updatePinjaman(updatedPinjaman);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ref.refresh(pinjamanListProvider);
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
    Pinjaman pinjaman,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content:
            const Text('Apakah Anda yakin ingin menghapus data pinjaman ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (pinjaman.idPinjaman != null) {
                final service = SupabaseService();
                await service.deletePinjaman(pinjaman.idPinjaman!);
                if (context.mounted) {
                  Navigator.pop(context);
                  ref.refresh(pinjamanListProvider);
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
