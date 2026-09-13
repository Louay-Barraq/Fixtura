import 'package:flutter/material.dart';

class DropdownTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final String initialValue;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const DropdownTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.initialValue,
    required this.options,
    required this.onChanged,
  });

  @override
  State<DropdownTile> createState() => _SettingsDropdownTileState();
}

class _SettingsDropdownTileState extends State<DropdownTile> {
  late String selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 2,
            color: Color(0xFF000000).withValues(alpha: 0.25),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Label
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                Text(
                  widget.subtitle,
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 10,
                    color: Color(0xFF000000).withValues(alpha: 0.6),
                  ),
                  overflow: TextOverflow.clip,
                  maxLines: 2,
                ),
              ],
            ),
          ),

          // Right Black Dropdown Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedValue,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                dropdownColor: Colors.black,
                style: const TextStyle(
                  fontFamily: 'BebasNeue',
                  fontSize: 14,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedValue = newValue;
                    });
                    widget.onChanged(newValue);
                  }
                },
                items: widget.options.map<DropdownMenuItem<String>>((
                  String value,
                ) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
