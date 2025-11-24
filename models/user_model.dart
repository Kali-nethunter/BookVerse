class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String photoURL;
  final int readingGoal;
  final List<String> favoriteGenres;
  final Map<String, int> readingProgress; // bookId -> current page
  final int totalBooksRead;
  final int currentStreak;

  AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoURL,
    this.readingGoal = 10,
    this.favoriteGenres = const [],
    this.readingProgress = const {},
    this.totalBooksRead = 0,
    this.currentStreak = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'readingGoal': readingGoal,
      'favoriteGenres': favoriteGenres,
      'readingProgress': readingProgress,
      'totalBooksRead': totalBooksRead,
      'currentStreak': currentStreak,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'],
      email: map['email'],
      displayName: map['displayName'],
      photoURL: map['photoURL'],
      readingGoal: map['readingGoal'],
      favoriteGenres: List<String>.from(map['favoriteGenres']),
      readingProgress: Map<String, int>.from(map['readingProgress']),
      totalBooksRead: map['totalBooksRead'],
      currentStreak: map['currentStreak'],
    );
  }
}
