
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lapor_book/components/list_comment.dart';
import 'package:lapor_book/components/status_dialog.dart';
import 'package:lapor_book/components/styles.dart';
import 'package:lapor_book/models/akun.dart';
import 'package:lapor_book/models/laporan.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});
  @override
  State<StatefulWidget> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  List<Like> listLike = [];

  String? status;
  bool isLiked = false;

  Future launch(String uri) async {
    if (uri == '') return;
    if (!await launchUrl(Uri.parse(uri))) {
      throw Exception('Tidak dapat memanggil : $uri');
    }
  }

  void statusDialog(Laporan laporan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatusDialog(
          laporan: laporan,
        );
      },
    );
  }

  void addTransaksiLike(Akun akun, String docId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      CollectionReference likeCollection = _firestore
          .collection('laporan')
          .doc(docId)
          .collection('like');

      // Convert DateTime to Firestore Timestamp
      Timestamp timestamp = Timestamp.fromDate(DateTime.now());
      final likeId = likeCollection.doc().id;

      await likeCollection.doc(likeId).set({
        'uid': _auth.currentUser!.uid,
        'docId': docId,
        'nama': akun.nama,
        'tanggal': timestamp,
      }).catchError((e) {
        throw e;
      });
      Navigator.popAndPushNamed(context, '/dashboard');
    } catch (e) {
      final snackbar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    } finally {
      setState(() {
        _isLoading = false;
      });
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
        if (listLike.isEmpty) {
          setState(() {
            isLiked = false;
          });
        } else {
          setState(() {
            isLiked = true;
          });
        }
      });
      
    }  catch (e) {
      final snackbar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    Laporan laporan = arguments['laporan'];
    Akun akun = arguments['akun'];

    checkLikeStatus(akun, laporan.docId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title:
        Text('Detail Laporan', style: headerStyle(level: 3, dark: false)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(),
        ) : SingleChildScrollView(
          child: Container(
            margin:
            const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  laporan.judul,
                  style: headerStyle(level:3),
                ),
                const SizedBox(height: 15),
                laporan.gambar != ''
                    ? Image.network(laporan.gambar!)
                    : Image.asset('images/placeholder.png'),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    laporan.status == 'Posted'
                        ? textStatus(
                        'Posted', Colors.yellow, Colors.black)
                        : laporan.status == 'Process'
                        ? textStatus(
                        'Process', Colors.green, Colors.white)
                        : textStatus(
                        'Done', Colors.blue, Colors.white),
                    textStatus(
                        laporan.instansi, Colors.white, Colors.black),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    textStatus(
                            (listLike.length ?? 0).toString(),
                            Colors.white,
                            Colors.black,
                          ),
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          if (!isLiked) {
                            addTransaksiLike(akun, laporan.docId);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("Sudah Pernah Like"),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            );
                          }
                        });
                      },
                    ),
                        ],
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Icon(Icons.person),
                  title: const Center(child: Text('Nama Pelapor')),
                  subtitle: Center(
                    child: Text(laporan.nama),
                  ),
                  trailing: SizedBox(width: 45),
                ),
                ListTile(
                  leading: Icon(Icons.date_range),
                  title: Center(child: Text('Tanggal Laporan')),
                  subtitle: Center(
                      child: Text(DateFormat('dd MMMM yyyy')
                          .format(laporan.tanggal))),
                  trailing: IconButton(
                    icon: Icon(Icons.location_on),
                    onPressed: () {
                      launch(laporan.maps);
                    },
                  ),
                ),
                const SizedBox(height: 50),
                Text(
                  'Deskripsi Laporan',
                  style: headerStyle(level:3),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(laporan.deskripsi ?? ''),
                ),
                const SizedBox(height: 20),
                if (akun.role == 'admin')
                  Container(
                    width: 250,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          status = laporan.status;
                        });
                        statusDialog(laporan);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('Ubah Status'),
                    ),
                  ),
                const SizedBox(height: 20),
                Container(
                    width: double.infinity,
                  child: FilledButton(
                    style: buttonStyle,
                    onPressed: () {
                      Navigator.pushNamed(context, '/add_comment', arguments: {
                        'laporan': laporan,
                        'akun': akun,
                      });
                    },
                    child: Text('Tambah Komentar'),
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Deskripsi Laporan',
                      style: headerStyle(level: 3),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(laporan.deskripsi ?? ''),
                    ),
                    const SizedBox(height: 20),
                    // Menampilkan list komentar dengan menggunakan ListComment
                    ListComment(komentarList: laporan.komentar),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container textStatus(String text, var bgcolor, var textcolor) {
    return Container(
      width: 150,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: bgcolor,
          border: Border.all(width: 1, color: primaryColor),
          borderRadius: BorderRadius.circular(25)),
      child: Text(
        text,
        style: TextStyle(color: textcolor),
      ),
    );
  }

}