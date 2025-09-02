import 'package:back_base_assignment/core/error/exceptions.dart';
import 'package:back_base_assignment/core/error/failures.dart';
import 'package:back_base_assignment/data/datasources/book_local_data_source.dart';
import 'package:back_base_assignment/data/datasources/book_remote_data_source.dart';
import 'package:back_base_assignment/data/models/book_model.dart';
import 'package:back_base_assignment/domain/entities/book.dart';
import 'package:back_base_assignment/domain/repositories/book_repository.dart';
import 'package:dartz/dartz.dart';

class BookRepositoryImpl implements BookRepository {
  final BookRemoteDataSource remoteDataSource;
  final BookLocalDataSource localDataSource;

  BookRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<BooksDomainResponse, Failure>> searchBooks(
    String query,
    int page,
    int limit,
  ) async {
    try {
      final remoteBooks = await remoteDataSource.searchBooks(
        query,
        page,
        limit,
      );
      // final savedBookIds = await localDataSource.getSavedBookIds();
      final response = BooksDomainResponse(
        numFound: remoteBooks.numFound,
        start: remoteBooks.start,
        books: remoteBooks.docs.map((book) {
          return Book(
            id: book.id,
            title: book.title,
            author: book.author,
            coverUrl: book.coverUrl,
            firstPublishYear: book.firstPublishYear,
            numberOfPages: book.numberOfPages,
          );
        }).toList(),
      );
      return Left(response);
    } on ServerException catch (e) {
      return Right(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Right(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<List<Book>, Failure>> getSavedBooks() async {
    try {
      final localBooks = await localDataSource.getSavedBooks();
      return Left(localBooks);
    } on CacheException catch (e) {
      return Right(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Unit, Failure>> saveBook(Book book) async {
    try {
      final bookModel = BookModel(
        id: book.id,
        title: book.title,
        author: book.author,
        coverUrl: book.coverUrl,
        firstPublishYear: book.firstPublishYear,
        numberOfPages: book.numberOfPages,
      );
      await localDataSource.saveBook(bookModel);
      return const Left(unit);
    } on CacheException catch (e) {
      return Right(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Unit, Failure>> deleteBook(String id) async {
    try {
      await localDataSource.deleteBook(id);
      return const Left(unit);
    } on CacheException catch (e) {
      return Right(CacheFailure(e.message));
    }
  }
}
