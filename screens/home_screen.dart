import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:bookverse/services/api_service.dart';
import 'package:bookverse/services/firebase_service.dart';
import 'package:bookverse/widgets/animated_book_card.dart';
import 'package:bookverse/widgets/book_shelf.dart';
import 'package:bookverse/widgets/shimmer_effect.dart';
import '../models/book_model.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final FirebaseService _firebaseService = FirebaseService();
  late AnimationController _animationController;
  List<Book> _featuredBooks = [];
  List<Book> _recommendedBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _loadData();
    _animationController.forward();
  }

  Future<void> _loadData() async {
    try {
      final featured = await _apiService.getFeaturedBooks();
      final recommended = await _apiService.searchBooks('best sellers');
      
      setState(() {
        _featuredBooks = featured;
        _recommendedBooks = recommended;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      body: _isLoading ? _buildShimmerLoading() : _buildContent(),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView(
      children: [
        ShimmerEffect(height: 200, width: double.infinity),
        SizedBox(height: 20),
        ShimmerEffect(height: 150, width: double.infinity),
        SizedBox(height: 20),
        ShimmerEffect(height: 150, width: double.infinity),
      ],
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 120,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'BookVerse',
              style: TextStyle(
                color: Color(0xFF2D3047),
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2D3047), Color(0xFFE84855)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchScreen()),
              ),
            ),
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              ),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: _buildFeaturedSection(),
        ),
        SliverToBoxAdapter(
          child: _buildRecommendedSection(),
        ),
        SliverToBoxAdapter(
          child: _buildBookshelfSection(),
        ),
      ],
    );
  }

  Widget _buildFeaturedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Featured Books',
            style: Theme.of(context).textTheme.headline4,
          ),
        ),
        CarouselSlider.builder(
          options: CarouselOptions(
            height: 300,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.6,
          ),
          itemCount: _featuredBooks.length,
          itemBuilder: (context, index, realIndex) {
            return AnimatedBookCard(
              book: _featuredBooks[index],
              animationController: _animationController,
              animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Interval((index * 0.1), 1.0, curve: Curves.easeOut),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecommendedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Recommended For You',
            style: Theme.of(context).textTheme.headline4,
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: _recommendedBooks.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: 12),
                child: BookShelf(book: _recommendedBooks[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBookshelfSection() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Bookshelf',
            style: Theme.of(context).textTheme.headline4,
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.library_books, color: Color(0xFF2D3047)),
                  title: Text('Books in Progress'),
                  trailing: Chip(label: Text('3')),
                ),
                ListTile(
                  leading: Icon(Icons.favorite, color: Color(0xFFE84855)),
                  title: Text('Favorites'),
                  trailing: Chip(label: Text('12')),
                ),
                ListTile(
                  leading: Icon(Icons.emoji_events, color: Colors.amber),
                  title: Text('Reading Streak'),
                  trailing: Chip(label: Text('7 days')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
