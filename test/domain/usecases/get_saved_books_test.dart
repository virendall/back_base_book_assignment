import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:back_base_assignment/core/error/failures.dart';
import 'package:back_base_assignment/domain/entities/book.dart';
import 'package:back_base_assignment/domain/repositories/book_repository.dart';
import 'package:back_base_assignment/domain/usecases/get_saved_books.dart';

class FakeRepo implements BookRepository {
  Either<List<Book>, Failure> result;
  FakeRepo(this.result);

  @override
  Future<Either<List<Book>, Failure>> getSavedBooks() async => result;

  @override
  Future<Either<BooksDomainResponse, Failure>> searchBooks(
    String query,
    int page,
    int limit,
  ) => throw UnimplementedError();

  @override
  Future<Either<Unit, Failure>> saveBook(Book book) =>
      throw UnimplementedError();

  @override
  Future<Either<Unit, Failure>> deleteBook(String id) =>
      throw UnimplementedError();
}

void main() {
  Book b(int i) => Book(id: '$i', title: 'T$i', author: 'A$i', coverUrl: '');

  test('returns saved books on success', () async {
    final repo = FakeRepo(Left([b(1), b(2)]));
    final usecase = GetSavedBooks(repo);

    final result = await usecase();

    expect(result, isA<Left<List<Book>, Failure>>());
  });

  test('returns failure on error', () async {
    final repo = FakeRepo(Right(CacheFailure('oops')));
    final usecase = GetSavedBooks(repo);

    final result = await usecase();

    expect(result, isA<Right<List<Book>, Failure>>());
  });
}
