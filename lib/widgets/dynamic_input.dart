import 'package:flutter/material.dart';

class DynamicInput extends StatefulWidget {
  final String hintText;
  final String tagType;
  final ValueChanged<List<String>>? onTagsChanged;

  const DynamicInput({
    super.key,
    this.hintText = 'Enter a value...',
    this.onTagsChanged,
    required this.tagType,
  });

  @override
  State<DynamicInput> createState() => _DynamicInputState();
}

class _DynamicInputState extends State<DynamicInput> {
  final TextEditingController _textController = TextEditingController();
  final List<String> _tags = [];

  void _addTag() {
    final text = _textController.text.trim();
    if (text.isNotEmpty && !_tags.contains(text)) {
      setState(() {
        _tags.add(text);
        _textController.clear();
      });
      widget.onTagsChanged?.call(_tags);
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
    widget.onTagsChanged?.call(_tags);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Input Container with TextField and Square Plus Button
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4,
                        spreadRadius: 2,
                        color: const Color(0xFF000000).withValues(alpha: 0.25),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Center(
                      child: TextField(
                        controller: _textController,
                        onSubmitted: (_) => _addTag(),
                        style: const TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 15,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: widget.hintText,
                          hintStyle: TextStyle(
                            fontFamily: 'RobotoMono',
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _addTag,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4,
                        spreadRadius: 2,
                        color: const Color(0xFF000000).withValues(alpha: 0.25),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
        ),

        // Display Added Tags below
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Center(
              child: Text(
                "${widget.tagType}: ${_tags.length}",
                style: TextStyle(fontFamily: 'RobotoMono', fontSize: 14),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tags.map((tag) => _buildTagTile(tag)).toList(),
            ),
          ),
        ],
      ],
    );
  }

  // Styled Removable Tag Tile
  Widget _buildTagTile(String tag) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 10, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: const TextStyle(
              fontFamily: 'RobotoMono',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _removeTag(tag),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
