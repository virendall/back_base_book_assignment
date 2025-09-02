import 'package:http/http.dart' as http;
import 'package:back_base_assignment/data/datasources/book_local_data_source.dart';
import 'package:back_base_assignment/data/datasources/book_remote_data_source.dart';
import 'package:back_base_assignment/data/repositories/book_repository_impl.dart';
import 'package:back_base_assignment/domain/repositories/book_repository.dart';
import 'package:back_base_assignment/domain/usecases/delete_book.dart';
import 'package:back_base_assignment/domain/usecases/get_saved_books.dart';
import 'package:back_base_assignment/domain/usecases/save_book.dart';
import 'package:back_base_assignment/domain/usecases/search_books.dart';
import 'package:back_base_assignment/presentation/bloc/book_search/book_search_bloc.dart';
import 'package:back_base_assignment/presentation/bloc/saved_books/saved_books_bloc.dart';

class ServiceLocator {
  static late http.Client _httpClient;
  static late BookLocalDataSource _bookLocalDataSource;
  static late BookRemoteDataSource _bookRemoteDataSource;
  static late BookRepository _bookRepository;
  static late SearchBooks _searchBooksUseCase;
  static late GetSavedBooks _getSavedBooksUseCase;
  static late SaveBook _saveBookUseCase;
  static late DeleteBook _deleteBookUseCase;
  static late BookSearchBloc _bookSearchBloc;
  static late SavedBooksBloc _savedBooksBloc;

  static Future<void> init() async {
    // External
    _httpClient = http.Client();

    // Data sources
    _bookLocalDataSource = BookLocalDataSourceImpl();
    _bookRemoteDataSource = BookRemoteDataSourceImpl(client: _httpClient);

    // Repository
    _bookRepository = BookRepositoryImpl(
      remoteDataSource: _bookRemoteDataSource,
      localDataSource: _bookLocalDataSource,
    );

    // Use cases
    _searchBooksUseCase = SearchBooks(_bookRepository);
    _getSavedBooksUseCase = GetSavedBooks(_bookRepository);
    _saveBookUseCase = SaveBook(_bookRepository);
    _deleteBookUseCase = DeleteBook(_bookRepository);

    // Blocs
    _bookSearchBloc = BookSearchBloc(searchBooks: _searchBooksUseCase);
    _savedBooksBloc = SavedBooksBloc(
      getSavedBooks: _getSavedBooksUseCase,
      saveBook: _saveBookUseCase,
      deleteBook: _deleteBookUseCase,
    );
  }

  static http.Client get httpClient => _httpClient;
  static BookLocalDataSource get bookLocalDataSource => _bookLocalDataSource;
  static BookRemoteDataSource get bookRemoteDataSource => _bookRemoteDataSource;
  static BookRepository get bookRepository => _bookRepository;
  static SearchBooks get searchBooksUseCase => _searchBooksUseCase;
  static GetSavedBooks get getSavedBooksUseCase => _getSavedBooksUseCase;
  static SaveBook get saveBookUseCase => _saveBookUseCase;
  static DeleteBook get deleteBookUseCase => _deleteBookUseCase;
  static BookSearchBloc get bookSearchBloc => _bookSearchBloc;
  static SavedBooksBloc get savedBooksBloc => _savedBooksBloc;
}
