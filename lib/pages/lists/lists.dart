import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:listica/pages/lists/detail_page.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  final TextEditingController listTitleController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;

  late CollectionReference shoppingLists;
  String? pairId;

  @override
  void initState() {
    super.initState();
    _initializePair();
  }

  Future<void> _initializePair() async {
    final pairSnapshot = await FirebaseFirestore.instance
        .collection('pairing')
        .doc(user.uid)
        .get();
    if (pairSnapshot.exists) {
      final pairedWith = pairSnapshot['pairedWith'];
      if (pairedWith != null) {
        final sorted = [user.uid, pairedWith]..sort();
        pairId = '${sorted[0]}_${sorted[1]}';
        setState(() {
          shoppingLists = FirebaseFirestore.instance
              .collection('family')
              .doc(pairId)
              .collection('lists');
        });
      } else {
        setState(() {
          pairId = null;
        });
      }
    } else {
      setState(() {
        pairId = null;
      });
    }
  }

  void _createList() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yangi roʻyxat nomi'),
        content: TextField(
          controller: listTitleController,
          decoration: const InputDecoration(
            hintText: 'Masalan: Haftalik xaridlar',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = listTitleController.text.trim();
              if (title.isNotEmpty) {
                shoppingLists.add({
                  'title': title,
                  'createdAt': FieldValue.serverTimestamp(),
                });
                listTitleController.clear();
              }
              Navigator.pop(context);
            },
            child: const Text('Qoʻshish'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(DocumentSnapshot listDoc) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ishonchingiz komilmi?'),
        content: const Text('Bu roʻyxat o‘chiriladi.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () async {
              await listDoc.reference.delete();
              Navigator.pop(context);
            },
            child: const Text('Ha, o‘chirish'),
          ),
        ],
      ),
    );
  }

  Future<int> _getItemCount(String listId) async {
    final snapshot = await shoppingLists.doc(listId).collection('items').get();
    return snapshot.size;
  }

  @override
  Widget build(BuildContext context) {
    if (pairId == null) {
      return const Center(
        child: Text(
          'Iltimos, birinchi navbatda juftlik yarating, shunda roʻyxat almashish mumkin bo‘ladi.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _createList,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: shoppingLists
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final lists = snapshot.data!.docs;

          return ListView.builder(
            itemCount: lists.length,
            itemBuilder: (context, index) {
              final listDoc = lists[index];
              final title = listDoc['title'];
              final listId = listDoc.id;

              return FutureBuilder<int>(
                future: _getItemCount(listId),
                builder: (context, countSnapshot) {
                  final count = countSnapshot.data ?? 0;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      title: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Mahsulotlar: $count'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _confirmDelete(listDoc),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailPage(
                            listId: listId,
                            title: title,
                            shoppingLists: shoppingLists,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
