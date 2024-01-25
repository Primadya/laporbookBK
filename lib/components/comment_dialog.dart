
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lapor_book/models/laporan.dart';

class CommentDialog extends StatefulWidget {
  final Laporan laporan;
  const CommentDialog({super.key, required this.laporan});

  @override
  State<CommentDialog> createState() => _CommentDialogState();
}

class _CommentDialogState extends State<CommentDialog> {

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  late String laporanId;
  late String nama;
  String? isi;

  void insertKomentar() async {
    CollectionReference transaksiCollection = _firestore
        .collection('laporan')
        .doc(laporanId)
        .collection('komentar');
    try {
      await transaksiCollection.doc(transaksiCollection.doc().id).set({
        'nama': _auth.currentUser!.displayName,
        'isi': isi,
      });
      Navigator.popAndPushNamed(context, '/dashboard');
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    laporanId = widget.laporan.docId;
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _commentController = TextEditingController();

    return AlertDialog(
      title: const Text('Kirim Komentar'),
      content: TextField(
        controller: _commentController,
        decoration: const InputDecoration(hintText: 'Komentar'),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Tutup dialog
          },
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () {
            insertKomentar();
            isi = _commentController.text;
            print(isi);
            Navigator.of(context).pop(); // Tutup dialog
          },
          child: const Text('Kirim'),
        ),
      ],
    );
  }

}