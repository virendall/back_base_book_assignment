import 'package:equatable/equatable.dart';
import 'package:back_base_assignment/domain/entities/book.dart';

abstract class SavedBooksEvent extends Equatable {
  const SavedBooksEvent();

  @override
  List<Object?> get props => [];
}

class LoadSavedBooks extends SavedBooksEvent {
  const LoadSavedBooks();
}

class AddBookRequested extends SavedBooksEvent {
  final Book book;
  const AddBookRequested(this.book);

  @override
  List<Object?> get props => [book];
}

class RemoveBookRequested extends SavedBooksEvent {
  final String id;
  const RemoveBookRequested(this.id);

  @override
  List<Object?> get props => [id];
}
