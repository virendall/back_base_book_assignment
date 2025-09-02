import 'package:back_base_assignment/domain/entities/book.dart';

class BooksResponse {
  final int numFound;
  final int start;
  final bool numFoundExact;
  final List<BookModel> docs;

  BooksResponse({
    required this.numFound,
    required this.start,
    required this.numFoundExact,
    required this.docs,
  });

  factory BooksResponse.fromJson(Map<String, dynamic> json) {
    return BooksResponse(
      numFound: json['numFound'] ?? 0,
      start: json['start'] ?? 0,
      numFoundExact: json['numFoundExact'] ?? false,
      docs: json['docs'] != null
          ? (json['docs'] as List)
                .map((doc) => BookModel.fromJson(doc))
                .toList()
          : [],
    );
  }
}

class BookModel extends Book {
  const BookModel({
    required super.id,
    required super.title,
    required super.author,
    required super.coverUrl,
    super.firstPublishYear,
    super.numberOfPages,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['key'].split('/').last,
      title: json['title'],
      author: json['author_name']?.join(', ') ?? 'Unknown Author',
      coverUrl: json['cover_i'] != null
          ? 'https://covers.openlibrary.org/b/id/${json['cover_i']}-L.jpg'
          : '',
      firstPublishYear: json['first_publish_year'],
      numberOfPages: json['number_of_pages_median'],
    );
  }

  factory BookModel.fromDb(Map<String, dynamic> map) {
    return BookModel(
      id: map['id'],
      title: map['title'],
      author: map['author'],
      coverUrl: map['coverUrl'],
      firstPublishYear: map['firstPublishYear'],
      numberOfPages: map['numberOfPages'],
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'coverUrl': coverUrl,
      'firstPublishYear': firstPublishYear,
      'numberOfPages': numberOfPages,
    };
  }
}
