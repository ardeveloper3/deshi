class CustomerProfile {
  const CustomerProfile({
    required this.userId,
    required this.name,
    required this.phone,
    required this.address,
    required this.email,
    required this.isAnonymous,
  });

  final String userId;
  final String name;
  final String phone;
  final String address;
  final String email;
  final bool isAnonymous;
}
