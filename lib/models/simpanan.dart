class Simpanan {
  final int? idSimpanan;
  final int idAnggota;
  final DateTime tanggalSimpan;
  final double jumlah;
  final String jenis;

  Simpanan({
    this.idSimpanan,
    required this.idAnggota,
    required this.tanggalSimpan,
    required this.jumlah,
    required this.jenis,
  });

  factory Simpanan.fromJson(Map<String, dynamic> json) {
    return Simpanan(
      idSimpanan: json['id_simpanan'],
      idAnggota: json['id_anggota'],
      tanggalSimpan: DateTime.parse(json['tanggal_simpan']),
      jumlah: json['jumlah'].toDouble(),
      jenis: json['jenis'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_simpanan': idSimpanan,
      'id_anggota': idAnggota,
      'tanggal_simpan': tanggalSimpan.toIso8601String(),
      'jumlah': jumlah,
      'jenis': jenis,
    };
  }
}
