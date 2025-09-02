import 'dart:convert';
import 'package:back_base_assignment/core/error/exceptions.dart';
import 'package:back_base_assignment/data/models/book_model.dart';
import 'package:http/http.dart' as http;

abstract class BookRemoteDataSource {
  Future<BooksResponse> searchBooks(String query, int page, int limit);
}

class BookRemoteDataSourceImpl implements BookRemoteDataSource {
  final http.Client client;

  BookRemoteDataSourceImpl({required this.client});

  @override
  Future<BooksResponse> searchBooks(String query, int page, int limit) async {
    final uri = Uri.parse(
      'https://openlibrary.org/search.json?q=$query&page=$page&limit=$limit',
    );
    try {
      final response = await client.get(uri);
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return BooksResponse.fromJson(result);
      } else {
        throw ServerException(
          message: 'HTTP ${response.statusCode} when calling OpenLibrary',
          statusCode: response.statusCode,
          uri: uri,
        );
      }
    } catch (e, st) {
      throw ServerException(
        message: 'Network error: $e',
        uri: uri,
        cause: e,
        stackTrace: st,
      );
    }
  }
}
