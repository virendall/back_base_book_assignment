import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:back_base_assignment/core/error/failures.dart';
import 'package:back_base_assignment/domain/entities/book.dart';
import 'package:back_base_assignment/domain/repositories/book_repository.dart';
import 'package:back_base_assignment/domain/usecases/save_book.dart';

class FakeRepo implements BookRepository {
  Either<Unit, Failure> result;
  Book? saved;
  FakeRepo(this.result);

  @override
  Future<Either<Unit, Failure>> saveBook(Book book) async {
    saved = book;
    return result;
  }

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
  Future<Either<Unit, Failure>> deleteBook(String id) =>
      throw UnimplementedError();
}

void main() {
  const book = Book(id: '1', title: 'A', author: 'B', coverUrl: '');

  test('succeeds and passes book to repo', () async {
    final repo = FakeRepo(const Left(unit));
    final usecase = SaveBook(repo);

    final result = await usecase(book);

    expect(result, isA<Left<Unit, Failure>>());
    expect(repo.saved, equals(book));
  });

  test('returns failure on error', () async {
    final repo = FakeRepo(Right(CacheFailure('fail')));
    final usecase = SaveBook(repo);

    final result = await usecase(book);

    expect(result, isA<Right<Unit, Failure>>());
  });
}
