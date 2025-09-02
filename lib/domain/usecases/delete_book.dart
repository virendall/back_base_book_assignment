import 'package:dartz/dartz.dart';
import 'package:back_base_assignment/core/error/failures.dart';
import 'package:back_base_assignment/domain/repositories/book_repository.dart';

class DeleteBook {
  final BookRepository repository;

  DeleteBook(this.repository);

  Future<Either<Unit, Failure>> call(String id) async {
    return await repository.deleteBook(id);
  }
}
