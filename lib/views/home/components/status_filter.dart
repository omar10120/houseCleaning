import 'package:flutter/material.dart';

class StatusFilter extends StatelessWidget {
  final int selectedStatus;
  final Function(int) onStatusChanged;

  const StatusFilter({
    Key? key,
    required this.selectedStatus,
    required this.onStatusChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FilterChip(
            label: const Text('All'),
            selected: selectedStatus == -1,
            onSelected: (_) => onStatusChanged(-1),
          ),
          FilterChip(
            label: const Text('Available'),
            selected: selectedStatus == 0,
            onSelected: (_) => onStatusChanged(0),
          ),
          FilterChip(
            label: const Text('Occupied'),
            selected: selectedStatus == 1,
            onSelected: (_) => onStatusChanged(1),
          ),
          FilterChip(
            label: const Text('Cleaning'),
            selected: selectedStatus == 2,
            onSelected: (_) => onStatusChanged(2),
          ),
        ],
      ),
    );
  }
}
