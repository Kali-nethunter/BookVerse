import 'package:flutter/material.dart';
import 'package:bookverse/services/firebase_service.dart';
import 'package:bookverse/widgets/reading_progress.dart';
import '../models/book_model.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;

  const BookDetailScreen({Key? key, required this.book}) : super(key: key);

  @override
  _BookDetailScreenState createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isFavorite = false;
  int _currentPage = 0;
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 0.0;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
    _loadReadingProgress();
  }

  void _checkIfFavorite() async {
    final user = _firebaseService.currentUser;
    if (user != null) {
      final isFav = await _firebaseService.isBookFavorite(user.uid, widget.book.id);
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  void _loadReadingProgress() async {
    final user = _firebaseService.currentUser;
    if (user != null) {
      final userData = await _firebaseService.getUser(user.uid);
      if (userData != null) {
        setState(() {
          _currentPage = userData.readingProgress[widget.book.id] ?? 0;
        });
      }
    }
  }

  void _toggleFavorite() async {
    final user = _firebaseService.currentUser;
    if (user != null) {
      if (_isFavorite) {
        await _firebaseService.removeFromFavorites(user.uid, widget.book.id);
      } else {
        await _firebaseService.addToFavorites(user.uid, widget.book.id);
      }
      setState(() {
        _isFavorite = !_isFavorite;
      });
    }
  }

  void _updateReadingProgress(int page) async {
    final user = _firebaseService.currentUser;
    if (user != null) {
      await _firebaseService.updateReadingProgress(user.uid, widget.book.id, page);
      setState(() {
        _currentPage = page;
      });
    }
  }

  void _submitReview() async {
    if (_rating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a rating')),
      );
      return;
    }

    final user = _firebaseService.currentUser;
    if (user != null) {
      final review = BookReview(
        id: '',
        userId: user.uid,
        userName: user.displayName ?? 'Anonymous',
        bookId: widget.book.id,
        rating: _rating,
        comment: _reviewController.text,
        timestamp: DateTime.now(),
      );

      await _firebaseService.addReview(review);
      _reviewController.clear();
      setState(() {
        _rating = 0.0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Review submitted successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            flexibleSpace: FlexibleSpaceBar(
              background: widget.book.thumbnail.isNotEmpty
                  ? Image.network(
                      widget.book.thumbnail,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.book, size: 100, color: Colors.grey[400]),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.book.title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3047),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite ? Color(0xFFE84855) : Colors.grey,
                        ),
                        onPressed: _toggleFavorite,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'by ${widget.book.authors.join(', ')}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: 16),
                  ReadingProgress(
                    currentPage: _currentPage,
                    totalPages: widget.book.pageCount,
                    onProgressChanged: _updateReadingProgress,
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3047),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.book.description,
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  SizedBox(height: 24),
                  _buildReviewSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Review',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3047),
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < _rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
              onPressed: () {
                setState(() {
                  _rating = (index + 1).toDouble();
                });
              },
            );
          }),
        ),
        TextField(
          controller: _reviewController,
          decoration: InputDecoration(
            hintText: 'Write your review...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        SizedBox(height: 12),
        ElevatedButton(
          onPressed: _submitReview,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF2D3047),
          ),
          child: Text('Submit Review'),
        ),
        SizedBox(height: 24),
        Text(
          'Reviews',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3047),
          ),
        ),
        SizedBox(height: 12),
        StreamBuilder<List<BookReview>>(
          stream: _firebaseService.getBookReviews(widget.book.id),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return Column(
                children: snapshot.data!
                    .map((review) => _buildReviewItem(review))
                    .toList(),
              );
            }
            return Text('No reviews yet');
          },
        ),
      ],
    );
  }

  Widget _buildReviewItem(BookReview review) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(review.userName[0]),
        ),
        title: Row(
          children: [
            Text(review.userName),
            Spacer(),
            ...List.generate(5, (index) {
              return Icon(
                Icons.star,
                size: 16,
                color: index < review.rating ? Colors.amber : Colors.grey[300],
              );
            }),
          ],
        ),
        subtitle: Text(review.comment),
      ),
    );
  }
}
