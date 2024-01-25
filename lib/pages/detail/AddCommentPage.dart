import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lapor_book/components/styles.dart';
import 'package:lapor_book/models/akun.dart';
import 'package:lapor_book/models/laporan.dart';

class AddCommentPage extends StatefulWidget {

  const AddCommentPage({super.key});

  @override
  State<StatefulWidget> createState() => _AddCommentPageState();
}

class _AddCommentPageState extends State<AddCommentPage> {
  final _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final arguments =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    Laporan laporan = arguments['laporan'];
    Akun akun = arguments['akun'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Komentar'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(),
        ) : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: _commentController,
                      decoration: InputDecoration(labelText: 'Isi Komentar'),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16.0),
                    Container(
                      width: double.infinity,
                      child: FilledButton(
                        style: buttonStyle,
                        onPressed: () => {
                          if (_commentController.text.isEmpty) {
                            const SnackBar(
                                content: Text(
                                    'Isi komentar tidak boleh kosong'
                                )),
                          } else {
                            _tambahKomentar(laporan.docId, akun.nama, _commentController.text),
                          }
                        },
                        child: Text('Tambah Komentar'),
                      ),
                    )
                  ],
          ),
        ),
      ),
    );
  }

  void _tambahKomentar(String docId, String nama, String komentar) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _firestore.collection('laporan').doc(docId).update({
        'komentar': FieldValue.arrayUnion([
          {
            'nama': nama,
            'isi': komentar,
          }
        ]),
      }).catchError((e) {
        throw e;
      });
      Navigator.pop(context);
    } catch (e) {
      final snackbar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}