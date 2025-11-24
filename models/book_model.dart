class Book {
  final String id;
  final String title;
  final List<String> authors;
  final String description;
  final String thumbnail;
  final int pageCount;
  final String publishedDate;
  final double averageRating;
  final List<String> categories;

  Book({
    required this.id,
    required this.title,
    required this.authors,
    required this.description,
    required this.thumbnail,
    required this.pageCount,
    required this.publishedDate,
    required this.averageRating,
    required this.categories,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? '',
      title: json['volumeInfo']['title'] ?? 'No Title',
      authors: List<String>.from(json['volumeInfo']['authors'] ?? ['Unknown Author']),
      description: json['volumeInfo']['description'] ?? 'No description available',
      thumbnail: json['volumeInfo']['imageLinks']?['thumbnail'] ?? '',
      pageCount: json['volumeInfo']['pageCount'] ?? 0,
      publishedDate: json['volumeInfo']['publishedDate'] ?? '',
      averageRating: (json['volumeInfo']['averageRating'] ?? 0.0).toDouble(),
      categories: List<String>.from(json['volumeInfo']['categories'] ?? ['General']),
    );
  }
}

class BookReview {
  final String id;
  final String userId;
  final String userName;
  final String bookId;
  final double rating;
  final String comment;
  final DateTime timestamp;

  BookReview({
    required this.id,
    required this.userId,
    required this.userName,
    required this.bookId,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'bookId': bookId,
      'rating': rating,
      'comment': comment,
      'timestamp': timestamp,
    };
  }

  factory BookReview.fromMap(Map<String, dynamic> map, String id) {
    return BookReview(
      id: id,
      userId: map['userId'],
      userName: map['userName'],
      bookId: map['bookId'],
      rating: map['rating'].toDouble(),
      comment: map['comment'],
      timestamp: map['timestamp'].toDate(),
    );
  }
}
