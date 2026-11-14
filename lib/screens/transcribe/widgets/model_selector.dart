import 'package:flutter/material.dart';

import '../../../models/whisper_options.dart';

class ModelSelector extends StatelessWidget {
  const ModelSelector({
    super.key,
    required this.selected,
    required this.enabled,
    required this.onChanged,
  });

  final WhisperModel selected;
  final bool enabled;
  final ValueChanged<WhisperModel> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<WhisperModel>(
      segments: WhisperModel.values
          .map((m) => ButtonSegment(
                value: m,
                label: Text('${m.label}\n${m.size}', textAlign: TextAlign.center),
              ))
          .toList(),
      selected: {selected},
      onSelectionChanged: enabled
          ? (sel) {
              final m = sel.first;
              if (m != selected) onChanged(m);
            }
          : null,
    );
  }
}
