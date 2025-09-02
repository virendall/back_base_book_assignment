import 'package:equatable/equatable.dart';

class BooksDomainResponse {
  final int numFound;
  final int start;
  final List<Book> books;

  BooksDomainResponse({
    required this.numFound,
    required this.start,
    required this.books,
  });

  factory BooksDomainResponse.empty() {
    return BooksDomainResponse(numFound: 0, start: 0, books: []);
  }
}

class Book extends Equatable {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final int? firstPublishYear;
  final int? numberOfPages;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    this.firstPublishYear,
    this.numberOfPages,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    author,
    coverUrl,
    firstPublishYear,
    numberOfPages,
  ];
}
