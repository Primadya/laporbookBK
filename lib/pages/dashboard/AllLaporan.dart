import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lapor_book/components/list_item.dart';
import 'package:lapor_book/models/akun.dart';
import 'package:lapor_book/models/laporan.dart';

class AllLaporan extends StatefulWidget {
  final Akun akun;
  AllLaporan({super.key, required this.akun});

  @override
  State<AllLaporan> createState() => _AllLaporanState();
}

class _AllLaporanState extends State<AllLaporan> {
  final _firestore = FirebaseFirestore.instance;

  List<Laporan> listLaporan = [];

  @override
  Widget build(BuildContext context) {
    getTransaksi();
    return SafeArea(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1 / 1.234,
            ),
            itemCount: 1,
            itemBuilder: (context, index) {
              return ListItem(
                laporan: listLaporan[index],
                akun: widget.akun,
                isLaporanku: false,
              );
            }),
      ),
    );
  }

  void getTransaksi() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await _firestore.collection('laporan').get();

      setState(() {
        listLaporan.clear();
        for (var documents in querySnapshot.docs) {

          List<dynamic>? komentarData = documents.data()['komentar'];

          List<Komentar>? listKomentar = komentarData?.map((map) {
            return Komentar(
              nama: map['nama'],
              isi: map['isi'],
            );
          }).toList();

          print("Nama: ${listKomentar?[0].nama}, Isi: ${listKomentar?[0].isi}");

          List<dynamic>? likeData = documents.data()['like'];

          List<Like>? listLike = likeData?.map((map) {
            return Like(
              docId: map['docId'],
              uid: map['uid'],
              nama: map['nama'],
              tanggal: map['tanggal'].toDate(),

            );
          }).toList();

          listLaporan.add(
            Laporan(
              uid: documents.data()['uid'],
              docId: documents.data()['docId'],
              judul: documents.data()['judul'],
              instansi: documents.data()['instansi'],
              deskripsi: documents.data()['deskripsi'],
              nama: documents.data()['nama'],
              status: documents.data()['status'],
              gambar: documents.data()['gambar'],
              tanggal: documents['tanggal'].toDate(),
              maps: documents.data()['maps'],
              komentar: listKomentar,
              like: listLike,
            ),
          );
        }
      });
    } catch (e) {
      final snackbar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      print(e);
    }
  }

}