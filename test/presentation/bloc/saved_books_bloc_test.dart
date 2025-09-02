import 'package:back_base_assignment/presentation/bloc/saved_books/saved_books_event.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:back_base_assignment/core/error/failures.dart';
import 'package:back_base_assignment/domain/entities/book.dart';
import 'package:back_base_assignment/domain/repositories/book_repository.dart';
import 'package:back_base_assignment/domain/usecases/delete_book.dart';
import 'package:back_base_assignment/domain/usecases/get_saved_books.dart';
import 'package:back_base_assignment/domain/usecases/save_book.dart';
import 'package:back_base_assignment/presentation/bloc/saved_books/saved_books_bloc.dart';
import 'package:back_base_assignment/presentation/bloc/saved_books/saved_books_state.dart';

class _MockRepo implements BookRepository {
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

class _MockGetSavedBooks extends GetSavedBooks {
  final List<Either<List<Book>, Failure>> results;
  int _idx = 0;

  _MockGetSavedBooks(this.results) : super(_MockRepo());

  @override
  Future<Either<List<Book>, Failure>> call() async {
    if (results.isEmpty) return const Left([]);
    final i = _idx < results.length ? _idx : results.length - 1;
    _idx++;
    return results[i];
  }
}

class _MockSaveBook extends SaveBook {
  final List<Either<void, Failure>> results;
  int _idx = 0;

  _MockSaveBook(this.results) : super(_MockRepo());

  @override
  Future<Either<Unit, Failure>> call(Book book) async {
    if (results.isEmpty) return const Left(unit);
    final i = _idx < results.length ? _idx : results.length - 1;
    _idx++;
    final r = results[i];
    return r.fold((_) => const Left(unit), (f) => Right(f));
  }
}

class _MockDeleteBook extends DeleteBook {
  final List<Either<void, Failure>> results;
  int _idx = 0;

  _MockDeleteBook(this.results) : super(_MockRepo());

  @override
  Future<Either<Unit, Failure>> call(String id) async {
    if (results.isEmpty) return const Left(unit);
    final i = _idx < results.length ? _idx : results.length - 1;
    _idx++;
    final r = results[i];
    return r.fold((_) => const Left(unit), (f) => Right(f));
  }
}

void main() {
  Book b(int i) => Book(id: '$i', title: 'T$i', author: 'A$i', coverUrl: '');

  group('SavedBooksBloc', () {
    blocTest<SavedBooksBloc, SavedBooksState>(
      'loadSavedBooks emits [Loading, Loaded] on success',
      build: () {
        final getSaved = _MockGetSavedBooks([
          Left([b(1), b(2)]),
        ]);
        return SavedBooksBloc(
          getSavedBooks: getSaved,
          saveBook: _MockSaveBook(const []),
          deleteBook: _MockDeleteBook(const []),
        );
      },
      act: (bloc) => bloc.add(LoadSavedBooks()),
      expect: () => [
        isA<SavedBooksLoading>(),
        isA<SavedBooksLoaded>().having(
          (s) => s.books.length,
          'books length',
          2,
        ),
      ],
    );

    blocTest<SavedBooksBloc, SavedBooksState>(
      'loadSavedBooks emits [Loading, Error] on failure',
      build: () {
        final getSaved = _MockGetSavedBooks([Right(CacheFailure('db fail'))]);
        return SavedBooksBloc(
          getSavedBooks: getSaved,
          saveBook: _MockSaveBook(const []),
          deleteBook: _MockDeleteBook(const []),
        );
      },
      act: (bloc) => bloc.add(LoadSavedBooks()),
      expect: () => [
        isA<SavedBooksLoading>(),
        isA<SavedBooksError>().having((e) => e.message, 'message', 'db fail'),
      ],
    );

    blocTest<SavedBooksBloc, SavedBooksState>(
      'addBook emits Loaded from refreshed list on success',
      build: () {
        final getSaved = _MockGetSavedBooks([
          Left([b(1)]),
        ]);
        final save = _MockSaveBook([const Left(null)]);
        return SavedBooksBloc(
          getSavedBooks: getSaved,
          saveBook: save,
          deleteBook: _MockDeleteBook(const []),
        );
      },
      act: (bloc) => bloc.add(AddBookRequested(b(1))),
      expect: () => [
        isA<SavedBooksLoaded>().having(
          (s) => s.books.map((e) => e.id).toList(),
          'ids',
          ['1'],
        ),
      ],
    );

    blocTest<SavedBooksBloc, SavedBooksState>(
      'addBook emits Error when save fails',
      build: () {
        final save = _MockSaveBook([Right(CacheFailure('save fail'))]);
        return SavedBooksBloc(
          getSavedBooks: _MockGetSavedBooks(const []),
          saveBook: save,
          deleteBook: _MockDeleteBook(const []),
        );
      },
      act: (bloc) => bloc.add(AddBookRequested(b(1))),
      expect: () => [
        isA<SavedBooksError>().having((e) => e.message, 'message', 'save fail'),
      ],
    );

    blocTest<SavedBooksBloc, SavedBooksState>(
      'removeBook emits Loaded from refreshed list on success',
      build: () {
        final getSaved = _MockGetSavedBooks([
          Left([b(2)]),
        ]);
        final delete = _MockDeleteBook([const Left(null)]);
        return SavedBooksBloc(
          getSavedBooks: getSaved,
          saveBook: _MockSaveBook(const []),
          deleteBook: delete,
        );
      },
      act: (bloc) => bloc.add(RemoveBookRequested('2')),
      expect: () => [
        isA<SavedBooksLoaded>().having(
          (s) => s.books.map((e) => e.id).toList(),
          'ids',
          ['2'],
        ),
      ],
    );

    blocTest<SavedBooksBloc, SavedBooksState>(
      'removeBook emits Error when delete fails',
      build: () {
        final delete = _MockDeleteBook([Right(CacheFailure('delete fail'))]);
        return SavedBooksBloc(
          getSavedBooks: _MockGetSavedBooks(const []),
          saveBook: _MockSaveBook(const []),
          deleteBook: delete,
        );
      },
      act: (bloc) => bloc.add(RemoveBookRequested('2')),
      expect: () => [
        isA<SavedBooksError>().having(
          (e) => e.message,
          'message',
          'delete fail',
        ),
      ],
    );
  });
}
