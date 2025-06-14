import 'package:listica/services/style/app_colors.dart';
import 'package:listica/services/style/app_style.dart';
import 'package:flutter/material.dart';

class CustomSelectionBottomSheet<T> extends StatefulWidget {
  final List<T> items;
  final T? selectedItem;
  final String Function(T) displayText;
  final String title;
  final Function(T) onItemSelected;
  final bool showAddAddressButton;

  const CustomSelectionBottomSheet({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.displayText,
    required this.title,
    required this.onItemSelected,
    this.showAddAddressButton = false,
  });

  @override
  State<CustomSelectionBottomSheet<T>> createState() =>
      _CustomSelectionBottomSheetState<T>();
}

class _CustomSelectionBottomSheetState<T>
    extends State<CustomSelectionBottomSheet<T>> {
  T? _tempSelectedItem;

  @override
  void initState() {
    super.initState();
    _tempSelectedItem = widget.selectedItem;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 60,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.iconColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            widget.title,
            style: AppStyle.fontStyle.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                return RadioListTile<T>(
                  value: item,
                  groupValue: _tempSelectedItem,
                  onChanged: (value) {
                    setState(() {
                      _tempSelectedItem = value;
                    });
                    // Call the onItemSelected callback and close the bottom sheet
                    widget.onItemSelected(value as T);
                    Navigator.pop(context);
                  },
                  title: Text(widget.displayText(item)),
                  activeColor: AppColors.iconColor,
                );
              },
            ),
          ),
          if (widget.showAddAddressButton) ...[
            Center(
              child: TextButton(
                onPressed: () {
                  // context.push(Routes.addAdressPage).then((result) {
                  //   if (result != null && result is Map<String, dynamic>) {

                  //     Navigator.pop(context, result);
                  //   }
                  // });
                },
                child: Text(
                  'Manzil qo\'shish',
                  style: AppStyle.fontStyle.copyWith(
                    color: AppColors.iconColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
