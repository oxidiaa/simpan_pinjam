class Transaksi {
  final int? idTransaksi;
  final int idAnggota;
  final DateTime tanggalTransaksi;
  final String jenis;
  final double jumlah;
  final String keterangan;

  Transaksi({
    this.idTransaksi,
    required this.idAnggota,
    required this.tanggalTransaksi,
    required this.jenis,
    required this.jumlah,
    required this.keterangan,
  });

  factory Transaksi.fromJson(Map<String, dynamic> json) {
    return Transaksi(
      idTransaksi: json['id_transaksi'],
      idAnggota: json['id_anggota'],
      tanggalTransaksi: DateTime.parse(json['tanggal_transaksi']),
      jenis: json['jenis'],
      jumlah: json['jumlah'].toDouble(),
      keterangan: json['keterangan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_transaksi': idTransaksi,
      'id_anggota': idAnggota,
      'tanggal_transaksi': tanggalTransaksi.toIso8601String(),
      'jenis': jenis,
      'jumlah': jumlah,
      'keterangan': keterangan,
    };
  }
}
