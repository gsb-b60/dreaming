import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/dreams/application/dream_store.dart';
import '../features/dreams/data/local_dream_repository.dart';
import '../features/dreams/presentation/home_shell.dart';
import 'theme/app_theme.dart';

class DreamingApp extends StatelessWidget {
  const DreamingApp({super.key, required this.preferences});

  final SharedPreferences preferences;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          DreamStore(LocalDreamRepository(preferences))..initialize(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Dreaming',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        home: const HomeShell(),
      ),
    );
  }
}
