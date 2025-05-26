class Anggota {
  final int? idAnggota;
  final String nama;
  final String alamat;
  final String telepon;
  final String email;
  final DateTime tanggalMasuk;

  Anggota({
    this.idAnggota,
    required this.nama,
    required this.alamat,
    required this.telepon,
    required this.email,
    required this.tanggalMasuk,
  });

  factory Anggota.fromJson(Map<String, dynamic> json) {
    return Anggota(
      idAnggota: json['id_anggota'],
      nama: json['nama'],
      alamat: json['alamat'],
      telepon: json['telepon'],
      email: json['email'],
      tanggalMasuk: DateTime.parse(json['tanggal_masuk']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idAnggota != null) 'id_anggota': idAnggota,
      'nama': nama,
      'alamat': alamat,
      'telepon': telepon,
      'email': email,
      'tanggal_masuk': tanggalMasuk.toIso8601String(),
    };
  }
}
