class Member {
  final String id;
  final String name;
  final int? rating;
  final bool isOfficer;

  Member({
    required this.id,
    required this.name,
    this.rating,
    this.isOfficer = false,
  });

  factory Member.fromFirestore(Map<String, dynamic> data, String id) {
    return Member(
      id: id,
      name: data['name'] ?? '',
      rating: data['rating'],
      isOfficer: data['isOfficer'] ?? false,
    );
  }
}
