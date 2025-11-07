class Discount {
  final String title;
  final double percent;

  Discount({
    required this.title,
    required this.percent,
  });

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      title: json['title'] ?? '',
      percent: (json['percent'] ?? 0) as double,
    );
  }
}
