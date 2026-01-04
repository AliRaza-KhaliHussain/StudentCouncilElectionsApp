import 'package:flutter/material.dart';

class RatingBarWidget extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onChanged;

  const RatingBarWidget({super.key, required this.rating, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        final selected = index < rating;
        return IconButton(
          icon: Icon(
            selected ? Icons.star : Icons.star_border,
            color: selected ? Colors.amber : Colors.grey,
          ),
          onPressed: () => onChanged(index + 1),
        );
      }),
    );
  }
}
