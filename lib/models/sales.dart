class Sales {
  final String product;
  final double price;

  Sales({required this.product, required this.price});

  factory Sales.fromJson(Map<String, dynamic> json) {
    return Sales(
      product: json['product'] ?? '',
      price: (json['price'] ?? 0) as double,
    );
  }
}
