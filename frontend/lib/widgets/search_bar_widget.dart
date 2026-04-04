import 'package:flutter/material.dart';
import '../services/nepal_places_data.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _suggestions = [];


  void _onChanged(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    final query = trimmed.toLowerCase();
    setState(() {
      _suggestions = nepalPlaces
          .where((place) => place.toLowerCase().startsWith(query))
          .take(6)
          .toList();
    });
  }

  void _selectSuggestion(String place) {
    _controller.text = place;
    _focusNode.unfocus();
    setState(() => _suggestions = []);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Search Box ─────────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: _onChanged,
            decoration: InputDecoration(
              hintText: 'Search Nepal locations...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_controller.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _controller.clear();
                        setState(() => _suggestions = []);
                      },
                      child: const Icon(Icons.close,
                          color: Colors.grey, size: 18),
                    ),
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.filter_list,
                        color: Colors.white, size: 20),
                  ),
                ],
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),

        // ── Suggestions Dropdown ───────────────────────────────────────
        if (_suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _suggestions.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, indent: 48),
              itemBuilder: (context, index) {
                final place = _suggestions[index];
                return ListTile(
                  leading: const Icon(Icons.location_on_outlined,
                      color: Colors.blueAccent, size: 20),
                  title: Text(place,
                      style: const TextStyle(fontSize: 14)),
                  subtitle: const Text('Nepal',
                      style: TextStyle(fontSize: 11, color: Colors.grey)),
                  dense: true,
                  onTap: () => _selectSuggestion(place),
                );
              },
            ),
          ),
      ],
    );
  }
}
