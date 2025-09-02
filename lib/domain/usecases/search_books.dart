import 'package:dartz/dartz.dart';
import 'package:back_base_assignment/core/error/failures.dart';
import 'package:back_base_assignment/domain/entities/book.dart';
import 'package:back_base_assignment/domain/repositories/book_repository.dart';
import 'package:equatable/equatable.dart';

class SearchBooks {
  final BookRepository repository;

  SearchBooks(this.repository);

  Future<Either<BooksDomainResponse, Failure>> call(Params params) async {
    return await repository.searchBooks(
      params.query,
      params.page,
      params.limit,
    );
  }
}

class Params extends Equatable {
  final String query;
  final int page;
  final int limit;

  const Params({required this.query, required this.page, this.limit = 20});

  @override
  List<Object?> get props => [query, page, limit];
}
