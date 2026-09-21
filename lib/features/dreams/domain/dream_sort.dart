enum DreamSortOrder {
  newestFirst,
  oldestFirst;

  String get label => switch (this) {
    DreamSortOrder.newestFirst => 'Newest first',
    DreamSortOrder.oldestFirst => 'Oldest first',
  };
}

extension DreamSortOrderParsing on DreamSortOrder {
  static DreamSortOrder fromName(String? value) {
    return DreamSortOrder.values.firstWhere(
      (order) => order.name == value,
      orElse: () => DreamSortOrder.newestFirst,
    );
  }
}
