class Item {
  final String name;
  final String category;
  final String type;
  final String payment;
  final double price;
  final DateTime date;

  const Item({
    required this.name,
    required this.category,
    required this.price,
    required this.date,
    required this.type,
    required this.payment,
  });

  factory Item.fromMap(Map<String, dynamic> map) {
    final properties = map['properties'] as Map<String, dynamic>;
    final dateStr = properties['Date']?['date']?['start'];

    return Item(
      name: properties['Name']?['title']?[0]?['plain_text'] ?? '?',
      category: properties['Category']?['select']?['name'] ?? 'Any',
      price: (properties['Price']?['number'] ?? 0).toDouble(),
      date: dateStr != null ? DateTime.parse(dateStr) : DateTime.now(),
      type: properties['Type']?['select']?['name'] ?? 'Any',
      payment: properties['Payment']?['select']?['name'] ?? 'Any',
    );
  }
}
