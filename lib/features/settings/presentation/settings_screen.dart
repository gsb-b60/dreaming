import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dreams/application/dream_store.dart';
import '../../export/data/dream_exporter.dart';
import '../../export/data/export_share_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dreams = context.watch<DreamStore>().dreams;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Local storage',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${dreams.length} dreams stored on this device. No account, backend, cloud database, or analytics are used.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.data_object_rounded),
                  title: const Text('Export JSON'),
                  subtitle: const Text(
                    'Human-readable structured backup for future import support.',
                  ),
                  onTap: dreams.isEmpty ? null : () => _export(context, 'json'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.table_chart_rounded),
                  title: const Text('Export CSV'),
                  subtitle: const Text(
                    'Spreadsheet-friendly table with escaped fields.',
                  ),
                  onTap: dreams.isEmpty ? null : () => _export(context, 'csv'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About Dreaming',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Dreaming is a private dream-memory journal. Data schema version: 1. Future imports should read exported JSON by schemaVersion and migrate records before saving.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _export(BuildContext context, String format) async {
    final dreams = context.read<DreamStore>().dreams;
    try {
      if (format == 'json') {
        await ExportShareService.shareTextFile(
          fileName: 'dreaming-export.json',
          mimeType: 'application/json',
          contents: DreamExporter.toJson(dreams),
        );
      } else {
        await ExportShareService.shareTextFile(
          fileName: 'dreaming-export.csv',
          mimeType: 'text/csv',
          contents: DreamExporter.toCsv(dreams),
        );
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exported ${format.toUpperCase()}.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not export ${format.toUpperCase()} right now.',
            ),
          ),
        );
      }
    }
  }
}
