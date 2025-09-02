import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:back_base_assignment/core/error/failures.dart';
import 'package:back_base_assignment/domain/entities/book.dart';
import 'package:back_base_assignment/domain/repositories/book_repository.dart';
import 'package:back_base_assignment/domain/usecases/delete_book.dart';

class FakeRepo implements BookRepository {
  Either<Unit, Failure> result;
  String? deletedId;
  FakeRepo(this.result);

  @override
  Future<Either<Unit, Failure>> deleteBook(String id) async {
    deletedId = id;
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
  Future<Either<Unit, Failure>> saveBook(Book book) =>
      throw UnimplementedError();
}

void main() {
  test('succeeds and passes id to repo', () async {
    final repo = FakeRepo(const Left(unit));
    final usecase = DeleteBook(repo);

    final result = await usecase('42');

    expect(result, isA<Left<Unit, Failure>>());
    expect(repo.deletedId, equals('42'));
  });

  test('returns failure on error', () async {
    final repo = FakeRepo(Right(CacheFailure('fail')));
    final usecase = DeleteBook(repo);

    final result = await usecase('1');

    expect(result, isA<Right<Unit, Failure>>());
  });
}

class Sample {
  String call() {
    return "Hello";
  }
}
