import 'package:back_base_assignment/domain/entities/book.dart';
import 'package:equatable/equatable.dart';

abstract class SavedBooksState extends Equatable {
  const SavedBooksState();

  @override
  List<Object> get props => [];
}

class SavedBooksInitial extends SavedBooksState {}

class SavedBooksLoading extends SavedBooksState {}

class SavedBooksLoaded extends SavedBooksState {
  final List<Book> books;

  const SavedBooksLoaded(this.books);

  @override
  List<Object> get props => [books];
}

class SavedBooksError extends SavedBooksState {
  final String message;

  const SavedBooksError(this.message);

  @override
  List<Object> get props => [message];
}
