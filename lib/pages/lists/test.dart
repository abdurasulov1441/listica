// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Reorderable List Demo',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: const MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key});

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   // Список элементов
//   final List<String> _items = List.generate(
//     10,
//     (index) => 'Элемент ${index + 1}',
//   );

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Перетаскиваемый список')),
//       body: ReorderableListView(
//         padding: const EdgeInsets.all(8.0),
//         // Обработка перетаскивания
//         onReorder: (int oldIndex, int newIndex) {
//           setState(() {
//             if (newIndex > oldIndex) {
//               newIndex -= 1;
//             }
//             final String item = _items.removeAt(oldIndex);
//             _items.insert(newIndex, item);
//           });
//         },
//         // Визуальная обратная связь при перетаскивании
//         proxyDecorator: (Widget child, int index, Animation<double> animation) {
//           return Material(
//             elevation: 4.0,
//             color: Colors.transparent,
//             child: ScaleTransition(scale: animation, child: child),
//           );
//         },
//         children: _items.asMap().entries.map((entry) {
//           final index = entry.key;
//           final item = entry.value;
//           return Card(
//             key: ValueKey(item), // Уникальный ключ для каждого элемента
//             margin: const EdgeInsets.symmetric(vertical: 4.0),
//             elevation: 2.0,
//             child: ListTile(
//               leading: const Icon(Icons.drag_handle, color: Colors.grey),
//               title: Text(item),
//               subtitle: Text('Позиция: ${index + 1}'),
//               trailing: const Icon(Icons.arrow_forward_ios, size: 16.0),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
// }
