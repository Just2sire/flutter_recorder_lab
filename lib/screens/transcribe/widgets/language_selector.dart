import 'package:flutter/material.dart';

import '../../../models/whisper_options.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key, required this.selected, required this.onChanged});

  final TranscribeLanguage selected;
  final ValueChanged<TranscribeLanguage> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TranscribeLanguage>(
      segments: TranscribeLanguage.values
          .map((l) => ButtonSegment(value: l, label: Text(l.label)))
          .toList(),
      selected: {selected},
      onSelectionChanged: (sel) => onChanged(sel.first),
    );
  }
}
