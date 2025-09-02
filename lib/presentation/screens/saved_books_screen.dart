import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:back_base_assignment/presentation/bloc/saved_books/saved_books_bloc.dart';
import 'package:back_base_assignment/presentation/bloc/saved_books/saved_books_state.dart';
import 'package:back_base_assignment/presentation/bloc/saved_books/saved_books_event.dart';
import 'package:back_base_assignment/presentation/widgets/book_list_item.dart';
import 'package:back_base_assignment/presentation/widgets/shimmer_list.dart';

class SavedBooksScreen extends StatelessWidget {
  const SavedBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Books')),
      body: BlocBuilder<SavedBooksBloc, SavedBooksState>(
        builder: (context, state) {
          if (state is SavedBooksLoading) {
            return const ShimmerList();
          }
          if (state is SavedBooksError) {
            return Center(
              child: Text(
                'Error: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (state is SavedBooksLoaded) {
            if (state.books.isEmpty) {
              return const Center(child: Text('No saved books yet.'));
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<SavedBooksBloc>().add(const LoadSavedBooks());
              },
              child: ListView.builder(
                itemCount: state.books.length,
                itemBuilder: (context, index) {
                  return BookListItem(book: state.books[index]);
                },
              ),
            );
          }
          // Initial state: try to load
          context.read<SavedBooksBloc>().add(const LoadSavedBooks());
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
