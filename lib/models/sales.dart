class Sales {
  final String product;
  final double price;

  Sales({required this.product, required this.price});

  factory Sales.fromJson(Map<String, dynamic> json) {
    return Sales(
      product: json['product'] ?? '',
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : (json['price'] ?? 0.0) as double,
    );
  }
}
