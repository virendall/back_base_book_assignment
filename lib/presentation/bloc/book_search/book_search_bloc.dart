import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:back_base_assignment/domain/usecases/search_books.dart';
import 'package:back_base_assignment/presentation/bloc/book_search/book_search_state.dart';
import 'package:back_base_assignment/presentation/bloc/book_search/book_search_event.dart';
import 'package:back_base_assignment/domain/entities/book.dart';

class BookSearchBloc extends Bloc<BookSearchEvent, BookSearchState> {
  final SearchBooks searchBooks;

  BookSearchBloc({required this.searchBooks}) : super(BookSearchInitial()) {
    on<BookSearchQueryChanged>(_onQueryChanged);
    on<BookSearchLoadMore>(_onLoadMore);
  }

  Future<void> _performSearch({
    required String query,
    required int page,
    required List<Book> previousBooks,
    required Emitter<BookSearchState> emit,
  }) async {
    final result = await searchBooks(
      Params(query: query, page: page, limit: 20),
    );
    result.fold((response) {
      final updatedBooks = List<Book>.from(previousBooks)
        ..addAll(response.books);
      final totalFound = response.numFound;
      final reachedMax =
          updatedBooks.length >= totalFound || response.books.isEmpty;
      emit(
        BookSearchLoaded(
          books: updatedBooks,
          hasReachedMax: reachedMax,
          currentPage: page,
          isLoadingMore: false,
          query: query,
          numFound: totalFound,
        ),
      );
    }, (failure) => emit(BookSearchError(failure.message)));
  }

  Future<void> _onQueryChanged(
    BookSearchQueryChanged event,
    Emitter<BookSearchState> emit,
  ) async {
    final String q = event.query.trim();
    if (q.isEmpty) {
      emit(BookSearchInitial());
      return;
    }
    emit(BookSearchLoading(query: q, currentPage: 1));
    await _performSearch(
      query: q,
      page: 1,
      previousBooks: const [],
      emit: emit,
    );
  }

  Future<void> _onLoadMore(
    BookSearchLoadMore event,
    Emitter<BookSearchState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BookSearchLoaded) return;
    if (currentState.hasReachedMax || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;
    await _performSearch(
      query: currentState.query,
      page: nextPage,
      previousBooks: currentState.books,
      emit: emit,
    );
  }
}
