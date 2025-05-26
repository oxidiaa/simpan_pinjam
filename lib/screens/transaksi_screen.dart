import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simpan_pinjam/models/anggota.dart';
import 'package:simpan_pinjam/models/transaksi.dart';
import 'package:simpan_pinjam/services/supabase_service.dart';
import 'package:simpan_pinjam/providers/anggota_list_provider.dart';
import 'package:simpan_pinjam/providers/transaksi_list_provider.dart';
import 'package:go_router/go_router.dart';

class TransaksiScreen extends ConsumerStatefulWidget {
  const TransaksiScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TransaksiScreen> createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends ConsumerState<TransaksiScreen> {
  Future<void> _showAddTransaksiDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final jumlahController = TextEditingController();
    final keteranganController = TextEditingController();
    String selectedJenis = 'Setoran';
    Anggota? selectedAnggota;

    final anggotaList = await ref.read(anggotaListProvider.future);

    if (context.mounted) {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Tambah Transaksi'),
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
                  DropdownButtonFormField<String>(
                    decoration:
                        const InputDecoration(labelText: 'Jenis Transaksi'),
                    value: selectedJenis,
                    items: const [
                      DropdownMenuItem(
                        value: 'Setoran',
                        child: Text('Setoran'),
                      ),
                      DropdownMenuItem(
                        value: 'Penarikan',
                        child: Text('Penarikan'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        selectedJenis = value;
                      }
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
                    controller: keteranganController,
                    decoration: const InputDecoration(labelText: 'Keterangan'),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Keterangan tidak boleh kosong';
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
                  final newTransaksi = Transaksi(
                    idAnggota: selectedAnggota!.idAnggota!,
                    tanggalTransaksi: DateTime.now(),
                    jenis: selectedJenis,
                    jumlah: double.parse(jumlahController.text),
                    keterangan: keteranganController.text,
                  );
                  await service.addTransaksi(newTransaksi);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ref.refresh(transaksiListProvider);
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

  Future<void> _showEditTransaksiDialog(
    BuildContext context,
    Transaksi transaksi,
  ) async {
    final formKey = GlobalKey<FormState>();
    final jumlahController =
        TextEditingController(text: transaksi.jumlah.toString());
    final keteranganController =
        TextEditingController(text: transaksi.keterangan);
    String selectedJenis = transaksi.jenis;
    Anggota? selectedAnggota;

    final anggotaList = await ref.read(anggotaListProvider.future);
    selectedAnggota =
        anggotaList.firstWhere((a) => a.idAnggota == transaksi.idAnggota);

    if (context.mounted) {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Edit Transaksi'),
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
                  DropdownButtonFormField<String>(
                    decoration:
                        const InputDecoration(labelText: 'Jenis Transaksi'),
                    value: selectedJenis,
                    items: const [
                      DropdownMenuItem(
                        value: 'Setoran',
                        child: Text('Setoran'),
                      ),
                      DropdownMenuItem(
                        value: 'Penarikan',
                        child: Text('Penarikan'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        selectedJenis = value;
                      }
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
                    controller: keteranganController,
                    decoration: const InputDecoration(labelText: 'Keterangan'),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Keterangan tidak boleh kosong';
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
                  final updatedTransaksi = Transaksi(
                    idTransaksi: transaksi.idTransaksi,
                    idAnggota: selectedAnggota!.idAnggota!,
                    tanggalTransaksi: transaksi.tanggalTransaksi,
                    jenis: selectedJenis,
                    jumlah: double.parse(jumlahController.text),
                    keterangan: keteranganController.text,
                  );
                  await service.updateTransaksi(updatedTransaksi);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ref.refresh(transaksiListProvider);
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
    Transaksi transaksi,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content:
            const Text('Apakah Anda yakin ingin menghapus data transaksi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (transaksi.idTransaksi != null) {
                final service = SupabaseService();
                await service.deleteTransaksi(transaksi.idTransaksi!);
                if (context.mounted) {
                  Navigator.pop(context);
                  ref.refresh(transaksiListProvider);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Transaksi'),
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
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final transaksiListAsync = ref.watch(transaksiListProvider);

          return transaksiListAsync.when(
            data: (transaksiList) {
              if (transaksiList.isEmpty) {
                return const Center(
                  child: Text('Belum ada data transaksi'),
                );
              }

              return ListView.builder(
                itemCount: transaksiList.length,
                itemBuilder: (context, index) {
                  final transaksi = transaksiList[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(transaksi.jenis),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Jumlah: Rp ${transaksi.jumlah}'),
                          Text(
                              'Tanggal: ${transaksi.tanggalTransaksi.toString().split('.')[0]}'),
                          Text('Keterangan: ${transaksi.keterangan}'),
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
                            _showEditTransaksiDialog(context, transaksi);
                          } else if (value == 'delete') {
                            _showDeleteConfirmation(context, transaksi);
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stackTrace) => Center(
              child: Text('Error: $error'),
            ),
          );
        },
      ),
    );
  }
}
