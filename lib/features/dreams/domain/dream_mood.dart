import 'package:flutter/material.dart';

class DreamMood {
  final String key;
  final String emoji;
  final String label;

  const DreamMood({
    required this.key,
    required this.emoji,
    required this.label,
  });

  String get displayName => '$emoji $label';

  Map<String, dynamic> toJson() => {'key': key, 'emoji': emoji, 'label': label};

  factory DreamMood.fromJson(Map<String, dynamic> json) {
    final key = json['key'] as String?;
    return DreamMoods.byKey(key) ??
        DreamMood(
          key: key ?? 'neutral',
          emoji: json['emoji'] as String? ?? '😐',
          label: json['label'] as String? ?? 'Neutral',
        );
  }

  static Color colorFor(BuildContext context, DreamMood mood) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return switch (mood.key) {
      'happy' => dark ? const Color(0xFF9BE38D) : const Color(0xFF3D8D3D),
      'peaceful' => dark ? const Color(0xFF8ED9E3) : const Color(0xFF2C7A83),
      'scary' => dark ? const Color(0xFFCE9BE8) : const Color(0xFF75518D),
      'sad' => dark ? const Color(0xFF9AB3E8) : const Color(0xFF4E679D),
      'exciting' => dark ? const Color(0xFFFFC76E) : const Color(0xFF94661A),
      'strange' => dark ? const Color(0xFFE0CF86) : const Color(0xFF746A26),
      'emotional' => dark ? const Color(0xFFFFA4B8) : const Color(0xFF9A4056),
      _ => dark ? const Color(0xFFB8C0D9) : const Color(0xFF68708A),
    };
  }

  @override
  bool operator ==(Object other) => other is DreamMood && other.key == key;

  @override
  int get hashCode => key.hashCode;
}

class DreamMoods {
  static const happy = DreamMood(key: 'happy', emoji: '😊', label: 'Happy');
  static const peaceful = DreamMood(
    key: 'peaceful',
    emoji: '😌',
    label: 'Peaceful',
  );
  static const scary = DreamMood(key: 'scary', emoji: '😨', label: 'Scary');
  static const sad = DreamMood(key: 'sad', emoji: '😢', label: 'Sad');
  static const exciting = DreamMood(
    key: 'exciting',
    emoji: '🤩',
    label: 'Exciting',
  );
  static const strange = DreamMood(
    key: 'strange',
    emoji: '😕',
    label: 'Strange',
  );
  static const neutral = DreamMood(
    key: 'neutral',
    emoji: '😐',
    label: 'Neutral',
  );
  static const emotional = DreamMood(
    key: 'emotional',
    emoji: '❤️',
    label: 'Emotional',
  );

  static const all = <DreamMood>[
    happy,
    peaceful,
    scary,
    sad,
    exciting,
    strange,
    neutral,
    emotional,
  ];

  static DreamMood? byKey(String? key) {
    if (key == null) return null;
    for (final mood in all) {
      if (mood.key == key) return mood;
    }
    return null;
  }
}
