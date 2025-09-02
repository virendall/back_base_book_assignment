import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:back_base_assignment/presentation/bloc/saved_books/saved_books_state.dart';
import 'package:back_base_assignment/presentation/bloc/saved_books/saved_books_event.dart';

import 'package:back_base_assignment/domain/usecases/get_saved_books.dart';
import 'package:back_base_assignment/domain/usecases/save_book.dart';
import 'package:back_base_assignment/domain/usecases/delete_book.dart';

class SavedBooksBloc extends Bloc<SavedBooksEvent, SavedBooksState> {
  final GetSavedBooks getSavedBooks;
  final SaveBook saveBook;
  final DeleteBook deleteBook;

  SavedBooksBloc({
    required this.getSavedBooks,
    required this.saveBook,
    required this.deleteBook,
  }) : super(SavedBooksInitial()) {
    on<LoadSavedBooks>(_onLoadSavedBooks);
    on<AddBookRequested>(_onAddBook);
    on<RemoveBookRequested>(_onRemoveBook);
  }

  Future<void> _onLoadSavedBooks(
    LoadSavedBooks event,
    Emitter<SavedBooksState> emit,
  ) async {
    emit(SavedBooksLoading());
    final result = await getSavedBooks.call();
    result.fold(
      (books) => emit(SavedBooksLoaded(books)),
      (failure) => emit(SavedBooksError(failure.message)),
    );
  }

  Future<void> _onAddBook(
    AddBookRequested event,
    Emitter<SavedBooksState> emit,
  ) async {
    final result = await saveBook(event.book);
    await result.fold((_) async {
      final refreshed = await getSavedBooks();
      refreshed.fold(
        (books) => emit(SavedBooksLoaded(books)),
        (failure) => emit(SavedBooksError(failure.message)),
      );
    }, (failure) async => emit(SavedBooksError(failure.message)));
  }

  Future<void> _onRemoveBook(
    RemoveBookRequested event,
    Emitter<SavedBooksState> emit,
  ) async {
    final result = await deleteBook(event.id);
    await result.fold((_) async {
      final refreshed = await getSavedBooks();
      refreshed.fold(
        (books) => emit(SavedBooksLoaded(books)),
        (failure) => emit(SavedBooksError(failure.message)),
      );
    }, (failure) async => emit(SavedBooksError(failure.message)));
  }
}
