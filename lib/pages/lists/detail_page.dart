import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:uuid/uuid.dart';

class DetailPage extends StatefulWidget {
  final String listId;
  final String title;
  final CollectionReference shoppingLists;

  const DetailPage({
    super.key,
    required this.listId,
    required this.title,
    required this.shoppingLists,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  List<DocumentSnapshot> items = [];

  void _addItem(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yangi mahsulot nomi'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Masalan: Molo ko 2L'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newItem = {
                'id': const Uuid().v4(),
                'title': controller.text.trim(),
                'done': false,
                'color': Colors.grey.value,
                'createdAt': FieldValue.serverTimestamp(),
                'order': items.length,
              };
              await widget.shoppingLists
                  .doc(widget.listId)
                  .collection('items')
                  .add(newItem);
              controller.clear();
              Navigator.pop(context);
            },
            child: const Text('Qo‘shish'),
          ),
        ],
      ),
    );
  }

  void _changeColor(DocumentSnapshot itemDoc) {
    Color selectedColor = Color(itemDoc['color'] ?? Colors.grey.value);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rangni tanlang'),
        content: BlockPicker(
          pickerColor: selectedColor,
          onColorChanged: (color) {
            itemDoc.reference.update({'color': color.value});
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _confirmDelete(DocumentSnapshot itemDoc) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ishonchingiz komilmi?'),
        content: const Text('Bu element o‘chiriladi.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () async {
              await itemDoc.reference.delete();
              Navigator.pop(context);
            },
            child: const Text('Ha, o‘chirish'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addItem(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: widget.shoppingLists
            .doc(widget.listId)
            .collection('items')
            .orderBy('order')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          items = snapshot.data!.docs;

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final itemDoc = items[index];
              final item = itemDoc.data() as Map<String, dynamic>;
              final title = item['title'] ?? '';
              final done = item['done'] ?? false;
              final color = Color(item['color'] ?? Colors.grey.value);

              return Container(
                key: ValueKey(itemDoc.id),
                color: color.withOpacity(0.2),
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          decoration: done ? TextDecoration.lineThrough : null,
                          color: done ? Colors.grey : Colors.black,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.color_lens, size: 20),
                      onPressed: () => _changeColor(itemDoc),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () => _confirmDelete(itemDoc),
                    ),
                    Checkbox(
                      value: done,
                      onChanged: (val) =>
                          itemDoc.reference.update({'done': val}),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
