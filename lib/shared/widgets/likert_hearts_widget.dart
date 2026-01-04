import 'package:flutter/material.dart';

class LikertHeartsWidget extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const LikertHeartsWidget({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        final selected = index < value;
        return IconButton(
          icon: Icon(
            selected ? Icons.favorite : Icons.favorite_border,
            color: selected ? Colors.red : Colors.grey,
          ),
          onPressed: () => onChanged(index + 1),
        );
      }),
    );
  }
}
