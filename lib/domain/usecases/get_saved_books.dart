import 'package:dartz/dartz.dart';
import 'package:back_base_assignment/core/error/failures.dart';
import 'package:back_base_assignment/domain/entities/book.dart';
import 'package:back_base_assignment/domain/repositories/book_repository.dart';

class GetSavedBooks {
  final BookRepository repository;

  GetSavedBooks(this.repository);

  Future<Either<List<Book>, Failure>> call() async {
    return await repository.getSavedBooks();
  }
}
