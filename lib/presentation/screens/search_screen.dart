import 'dart:async'; // Import for Timer
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:back_base_assignment/presentation/bloc/book_search/book_search_bloc.dart';
import 'package:back_base_assignment/presentation/bloc/book_search/book_search_state.dart';
import 'package:back_base_assignment/presentation/bloc/book_search/book_search_event.dart';
import 'package:back_base_assignment/presentation/widgets/book_list_item.dart';
import 'package:back_base_assignment/presentation/widgets/shimmer_list.dart';
import 'package:back_base_assignment/presentation/widgets/search_placeholder.dart';
import 'package:go_router/go_router.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounce; // Debounce timer

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Finder'),
        actions: [
          IconButton(
            tooltip: 'Saved Books',
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              if (!mounted) return;
              context.push('/saved');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CupertinoSearchTextField(
              controller: _searchController,
              placeholder: 'Search for books...',
              style: TextStyle(color: Colors.white),
              onChanged: (query) {
                // Add onChanged for debouncing
                if (_debounce?.isActive ?? false) _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  if (!mounted) return;
                  // Use latest text to avoid stale query
                  final latest = _searchController.text.trim();
                  final state = context.read<BookSearchBloc>().state;
                  // Avoid triggering if the same query is already loading
                  if (state is BookSearchLoading && state.query == latest) {
                    return;
                  }
                  context.read<BookSearchBloc>().add(
                    BookSearchQueryChanged(latest),
                  );
                });
              },
              onSubmitted: (query) {
                // Avoid triggering a new search if the same query is already loading
                if (_debounce?.isActive ?? false) _debounce?.cancel();
                final trimmed = query.trim();
                final state = context.read<BookSearchBloc>().state;
                if (state is BookSearchLoading && state.query == trimmed) {
                  return; // already loading same query
                }
                context.read<BookSearchBloc>().add(
                  BookSearchQueryChanged(trimmed),
                );
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<BookSearchBloc, BookSearchState>(
              builder: (context, bookSearchState) {
                if (bookSearchState is BookSearchInitial) {
                  return const SearchPlaceholder();
                }
                if (bookSearchState is BookSearchLoading) {
                  return const ShimmerList();
                }
                if (bookSearchState is BookSearchLoaded) {
                  if (bookSearchState.books.isEmpty) {
                    return const Center(
                      child: Text('No books found. Try another query.'),
                    );
                  }
                  int totalBooks = bookSearchState.books.length;
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<BookSearchBloc>().add(
                        BookSearchQueryChanged(_searchController.text),
                      );
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: bookSearchState.isLoadingMore
                          ? totalBooks + 1
                          : totalBooks,
                      itemBuilder: (context, index) {
                        return index >= totalBooks
                            ? const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : BookListItem(book: bookSearchState.books[index]);
                      },
                    ),
                  );
                }
                if (bookSearchState is BookSearchError) {
                  return Center(
                    child: Text(
                      'Error: ${bookSearchState.message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                return Container();
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel(); // Cancel debounce timer
    super.dispose();
  }

  void _onScroll() {
    if (!_isBottom) return;
    final state = context.read<BookSearchBloc>().state;
    if (state is BookSearchLoaded &&
        !state.hasReachedMax &&
        !state.isLoadingMore) {
      context.read<BookSearchBloc>().add(const BookSearchLoadMore());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }
}
