import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:lapor_book/components/styles.dart';
import 'package:lapor_book/models/akun.dart';
import 'package:lapor_book/models/laporan.dart';

class ListItem extends StatefulWidget {
  final Laporan laporan;
  final Akun akun;
  final bool isLaporanku;
  ListItem(
      {super.key,
        required this.laporan,
        required this.akun,
        required this.isLaporanku});

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  List<Like> listLike = [];

  void deleteLaporan() async {
    try {
      await _firestore.collection('laporan').doc(widget.laporan.docId).delete();

      if (widget.laporan.gambar != '') {
        await _storage.refFromURL(widget.laporan.gambar!).delete();
      }
      Navigator.popAndPushNamed(context, '/dashboard');
    } catch (e) {
      print(e);
    }
  }

  void checkLikeStatus(Akun akun, String docId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await _firestore
          .collection('laporan')
          .doc(docId)
          .collection('like')
          .where('uid', isEqualTo: akun.uid)
          .get();

      setState(() {
        listLike.clear();
        for (var documents in querySnapshot.docs) {
          if (documents!=null) {
            listLike.add(
              Like(
                docId: documents.data()['docId'],
                uid: documents.data()['uid'],
                nama: documents.data()['nama'],
                tanggal: documents['tanggal'].toDate(),
              ),
            );
          }
        }
      });

    }  catch (e) {
      final snackbar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  @override
  Widget build(BuildContext context) {
    checkLikeStatus(widget.akun, widget.laporan.docId);

    return Container(
      decoration: BoxDecoration(
          border: Border.all(width: 2),
          borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
         Navigator.pushNamed(context, '/detail', arguments: {
           'laporan': widget.laporan,
           'akun': widget.akun,
         });
        },
        onLongPress: () {
            if (widget.isLaporanku) {
              showDialog(
                  context: context,
                  builder: (BuildContext) {
                    return AlertDialog(
                      title: Text('Delete ${widget.laporan.judul}?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () {
                            deleteLaporan();
                            Navigator.pop(context);
                          },
                          child: Text('Hapus'),
                        ),
                      ],
                    );
                  });
            }
          },
          child: Column(
            children: [
              widget.laporan.gambar != ''
                  ? Image.network(
                      widget.laporan.gambar!,
                      width: 130,
                      height: 130,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'images/placeholder.png',
                      width: 130,
                      height: 130,
                    ),
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: const BoxDecoration(
                    border: Border.symmetric(horizontal: BorderSide(width: 2))),
                child: Text(
                  widget.laporan.judul,
                  style: headerStyle(level: 4),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                          color: warningColor,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(5),
                          ),
                          border: const Border.symmetric(
                              vertical: BorderSide(width: 1))),
                      alignment: Alignment.center,
                      child: Text(
                        widget.laporan.status,
                        style: headerStyle(level: 5, dark: false),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(5)),
                          border: const Border.symmetric(
                              vertical: BorderSide(width: 1))),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text((listLike.length ?? 0).toString(),
                        style: headerStyle(level: 5, dark: false),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ));
  }
}