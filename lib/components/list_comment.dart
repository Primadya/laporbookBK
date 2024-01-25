

import 'package:flutter/material.dart';
import 'package:lapor_book/models/laporan.dart';

class ListComment extends StatefulWidget {
  final List<Komentar>? komentarList;

  const ListComment({Key? key, this.komentarList}) : super(key: key);

  @override
  State<ListComment> createState() => _ListCommentState();
}

class _ListCommentState extends State<ListComment> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Komentar',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        _buildKomentarList(),
      ],
    );
  }

  Widget _buildKomentarList() {
    if (widget.komentarList == null || widget.komentarList!.isEmpty) {
      return Text('Belum ada komentar.');
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.komentarList!.map((komentar) {
          return ListTile(
            title: Text(komentar.nama),
            subtitle: Text(komentar.isi),
          );
        }).toList(),
      );
    }
  }
}
