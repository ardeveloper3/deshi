class BannerItem {
  const BannerItem({
    required this.id,
    required this.imageUrl,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.weight,
  });

  final String id;
  final String imageUrl;
  final String productName;
  final int quantity;
  final String price;
  final String weight;
}
