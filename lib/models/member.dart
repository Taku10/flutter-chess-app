class Member {
  final String id;
  final String name;
  final String? email;
  final int? rating;
  final String? yearInSchool;
  final String? major;
  final String? chessComUsername;
  final int? chessComRapidRating;
  final bool isOfficer;

  Member({
    required this.id,
    required this.name,
    this.email,
    this.rating,
    this.yearInSchool,
    this.major,
    this.chessComUsername,
    this.chessComRapidRating,
    this.isOfficer = false,
  });

  factory Member.fromFirestore(Map<String, dynamic> data, String id) {
    return Member(
      id: id,
      name: data['name'] ?? '',
      email: data['email'],
      rating: data['rating'],
      yearInSchool: data['yearInSchool'],
      major: data['major'],
      chessComUsername: data['chessComUsername'],
      chessComRapidRating: data['chessComRapidRating'],
      isOfficer: data['isOfficer'] ?? false,
    );
  }
}
