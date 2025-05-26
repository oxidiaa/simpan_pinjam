class Pinjaman {
  final int? idPinjaman;
  final int idAnggota;
  final DateTime tanggalPinjam;
  final double jumlah;
  final double bunga;
  final int jangkaWaktu;
  final String status;

  Pinjaman({
    this.idPinjaman,
    required this.idAnggota,
    required this.tanggalPinjam,
    required this.jumlah,
    required this.bunga,
    required this.jangkaWaktu,
    required this.status,
  });

  factory Pinjaman.fromJson(Map<String, dynamic> json) {
    return Pinjaman(
      idPinjaman: json['id_pinjaman'],
      idAnggota: json['id_anggota'],
      tanggalPinjam: DateTime.parse(json['tanggal_pinjam']),
      jumlah: json['jumlah'].toDouble(),
      bunga: json['bunga'].toDouble(),
      jangkaWaktu: json['jangka_waktu'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pinjaman': idPinjaman,
      'id_anggota': idAnggota,
      'tanggal_pinjam': tanggalPinjam.toIso8601String(),
      'jumlah': jumlah,
      'bunga': bunga,
      'jangka_waktu': jangkaWaktu,
      'status': status,
    };
  }
}
