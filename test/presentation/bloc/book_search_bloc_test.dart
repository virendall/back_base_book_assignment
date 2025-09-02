import 'package:back_base_assignment/presentation/bloc/book_search/book_search_event.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:back_base_assignment/core/error/failures.dart';
import 'package:back_base_assignment/domain/entities/book.dart';
import 'package:back_base_assignment/domain/repositories/book_repository.dart';
import 'package:back_base_assignment/domain/usecases/search_books.dart';
import 'package:back_base_assignment/presentation/bloc/book_search/book_search_bloc.dart';
import 'package:back_base_assignment/presentation/bloc/book_search/book_search_state.dart';

class _DummyRepo implements BookRepository {
  @override
  Future<Either<BooksDomainResponse, Failure>> searchBooks(
    String query,
    int page,
    int limit,
  ) => throw UnimplementedError();

  @override
  Future<Either<List<Book>, Failure>> getSavedBooks() =>
      throw UnimplementedError();

  @override
  Future<Either<Unit, Failure>> saveBook(Book book) =>
      throw UnimplementedError();

  @override
  Future<Either<Unit, Failure>> deleteBook(String id) =>
      throw UnimplementedError();
}

class FakeSearchBooks extends SearchBooks {
  final List<Either<BooksDomainResponse, Failure>> results;
  int _idx = 0;

  FakeSearchBooks(this.results) : super(_DummyRepo());

  @override
  Future<Either<BooksDomainResponse, Failure>> call(Params params) async {
    final i = _idx < results.length ? _idx : results.length - 1;
    _idx++;
    return results[i];
  }
}

void main() {
  BooksDomainResponse resp(List<Book> books, {int? numFound, int start = 0}) =>
      BooksDomainResponse(
        books: books,
        numFound: numFound ?? books.length,
        start: start,
      );

  Book b(int i) => Book(id: '$i', title: 'T$i', author: 'A$i', coverUrl: '');

  group('BookSearchBloc', () {
    blocTest<BookSearchBloc, BookSearchState>(
      'emits [Loading, Loaded] on successful search',
      build: () {
        final usecase = FakeSearchBooks([
          Left(resp([b(1), b(2)], numFound: 2)),
        ]);
        return BookSearchBloc(searchBooks: usecase);
      },
      expect: () => [
        isA<BookSearchLoading>(),
        isA<BookSearchLoaded>()
            .having((s) => s.books.length, 'books length', 2)
            .having((s) => s.hasReachedMax, 'hasReachedMax', true)
            .having((s) => s.currentPage, 'currentPage', 1)
            .having((s) => s.isLoadingMore, 'isLoadingMore', false),
      ],
      act: (bloc) => bloc.add(BookSearchQueryChanged("query")),
    );

    blocTest<BookSearchBloc, BookSearchState>(
      'emits [Loading, Error] on failure',
      build: () {
        final usecase = FakeSearchBooks([Right(ServerFailure('Server down'))]);
        return BookSearchBloc(searchBooks: usecase);
      },
      act: (bloc) => bloc.add(BookSearchQueryChanged("query")),
      expect: () => [
        isA<BookSearchLoading>(),
        isA<BookSearchError>().having(
          (e) => e.message,
          'message',
          'Server down',
        ),
      ],
    );

    blocTest<BookSearchBloc, BookSearchState>(
      'loadMore emits loadingMore then appended Loaded on success',
      build: () {
        final usecase = FakeSearchBooks([
          Left(resp([b(1), b(2)], numFound: 4)),
          Left(resp([b(3), b(4)], numFound: 4, start: 2)),
        ]);
        return BookSearchBloc(searchBooks: usecase);
      },
      act: (bloc) async {
        bloc.add(BookSearchQueryChanged("query"));
        await Future.delayed(Duration.zero);
        bloc.add(BookSearchLoadMore());
        await Future.delayed(Duration.zero);
      },
      expect: () => [
        isA<BookSearchLoading>(),
        isA<BookSearchLoaded>().having(
          (s) => s.books.map((e) => e.id).toList(),
          'ids',
          ['1', '2'],
        ),
        isA<BookSearchLoaded>().having(
          (s) => s.isLoadingMore,
          'loading more',
          true,
        ),
        isA<BookSearchLoaded>()
            .having((s) => s.books.map((e) => e.id).toList(), 'ids', [
              '1',
              '2',
              '3',
              '4',
            ])
            .having((s) => s.currentPage, 'page', 2)
            .having((s) => s.hasReachedMax, 'max', true)
            .having((s) => s.isLoadingMore, 'loading more', false),
      ],
    );

    blocTest<BookSearchBloc, BookSearchState>(
      'loadMore emits loadingMore then Error on failure',
      build: () {
        final usecase = FakeSearchBooks([
          Left(resp([b(1), b(2)], numFound: 4)),
          Right(ServerFailure('Network fail')),
        ]);
        return BookSearchBloc(searchBooks: usecase);
      },
      act: (bloc) async {
        bloc.add(BookSearchQueryChanged("query"));
        await Future.delayed(Duration.zero);
        bloc.add(BookSearchLoadMore());
        await Future.delayed(Duration.zero);
      },
      expect: () => [
        isA<BookSearchLoading>(),
        isA<BookSearchLoaded>(),
        isA<BookSearchLoaded>().having(
          (s) => s.isLoadingMore,
          'loading more',
          true,
        ),
        isA<BookSearchError>().having(
          (e) => e.message,
          'message',
          'Network fail',
        ),
      ],
    );
  });
}
