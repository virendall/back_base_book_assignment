import 'package:dartz/dartz.dart';
import 'package:back_base_assignment/core/error/failures.dart';
import 'package:back_base_assignment/domain/entities/book.dart';
import 'package:back_base_assignment/domain/repositories/book_repository.dart';

class SaveBook {
  final BookRepository repository;

  SaveBook(this.repository);

  Future<Either<Unit, Failure>> call(Book book) async {
    return await repository.saveBook(book);
  }
}
