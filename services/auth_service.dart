import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book_model.dart';

class ApiService {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';
  
  Future<List<Book>> searchBooks(String query) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl?q=$query&maxResults=20'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Book> books = [];
        
        for (var item in data['items']) {
          books.add(Book.fromJson(item));
        }
        
        return books;
      } else {
        throw Exception('Failed to load books');
      }
    } catch (e) {
      throw Exception('Error searching books: $e');
    }
  }

  Future<Book> getBookDetails(String bookId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$bookId'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Book.fromJson(data);
      } else {
        throw Exception('Failed to load book details');
      }
    } catch (e) {
      throw Exception('Error getting book details: $e');
    }
  }

  Future<List<Book>> getFeaturedBooks() async {
    const List<String> featuredQueries = [
      'fiction',
      'technology',
      'science',
      'history',
      'biography'
    ];
    
    List<Book> allBooks = [];
    
    for (String query in featuredQueries) {
      try {
        final books = await searchBooks(query);
        if (books.isNotEmpty) {
          allBooks.addAll(books.take(4));
        }
      } catch (e) {
        print('Error fetching featured books for $query: $e');
      }
    }
    
    return allBooks..shuffle();
  }
}
