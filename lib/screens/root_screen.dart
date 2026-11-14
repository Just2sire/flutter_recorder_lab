import 'package:flutter/material.dart';

import 'scan/scan_screen.dart';
import 'transcribe/transcribe_screen.dart';

/// Bottom-navigation shell hosting the two features of the app:
/// audio transcription and document scan + OCR. Each tab keeps its own
/// state alive via [IndexedStack] when switching back and forth.
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});
  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _index = 0;

  static const _screens = [TranscribeScreen(), ScanScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.mic_none_outlined),
            selectedIcon: Icon(Icons.mic),
            label: 'Transcription',
          ),
          NavigationDestination(
            icon: Icon(Icons.document_scanner_outlined),
            selectedIcon: Icon(Icons.document_scanner),
            label: 'Scanner',
          ),
        ],
      ),
    );
  }
}
