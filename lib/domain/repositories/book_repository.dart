import 'package:dartz/dartz.dart';
import 'package:back_base_assignment/core/error/failures.dart';
import 'package:back_base_assignment/domain/entities/book.dart';

abstract class BookRepository {
  Future<Either<BooksDomainResponse, Failure>> searchBooks(
    String query,
    int page,
    int limit,
  );
  Future<Either<List<Book>, Failure>> getSavedBooks();
  Future<Either<Unit, Failure>> saveBook(Book book);
  Future<Either<Unit, Failure>> deleteBook(String id);
}
