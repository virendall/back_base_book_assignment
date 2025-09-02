import 'package:equatable/equatable.dart';

abstract class BookSearchEvent extends Equatable {
  const BookSearchEvent();

  @override
  List<Object?> get props => [];
}

class BookSearchQueryChanged extends BookSearchEvent {
  final String query;

  const BookSearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class BookSearchLoadMore extends BookSearchEvent {
  const BookSearchLoadMore();
}
