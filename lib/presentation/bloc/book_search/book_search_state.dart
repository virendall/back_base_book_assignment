import 'package:back_base_assignment/domain/entities/book.dart';
import 'package:equatable/equatable.dart';

abstract class BookSearchState extends Equatable {
  const BookSearchState();

  @override
  List<Object> get props => [];
}

class BookSearchInitial extends BookSearchState {}

class BookSearchLoading extends BookSearchState {
  final String query;
  final int currentPage;

  const BookSearchLoading({required this.query, required this.currentPage});

  @override
  List<Object> get props => [query, currentPage];
}

class BookSearchLoaded extends BookSearchState {
  final List<Book> books;
  final bool hasReachedMax;
  final int currentPage;
  final bool isLoadingMore;
  final String query;
  final int numFound;

  const BookSearchLoaded({
    required this.books,
    required this.hasReachedMax,
    required this.currentPage,
    required this.query,
    required this.numFound,
    this.isLoadingMore = false,
  });

  @override
  List<Object> get props => [
    books,
    hasReachedMax,
    isLoadingMore,
    currentPage,
    query,
    numFound,
  ];

  BookSearchLoaded copyWith({
    List<Book>? books,
    bool? hasReachedMax,
    int? currentPage,
    bool? isLoadingMore,
    String? query,
    int? numFound,
  }) {
    return BookSearchLoaded(
      books: books ?? this.books,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      query: query ?? this.query,
      numFound: numFound ?? this.numFound,
    );
  }
}

class BookSearchError extends BookSearchState {
  final String message;

  const BookSearchError(this.message);

  @override
  List<Object> get props => [message];
}
