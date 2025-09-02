import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:back_base_assignment/domain/entities/book.dart';

import 'package:back_base_assignment/presentation/bloc/saved_books/saved_books_bloc.dart';
import 'package:back_base_assignment/presentation/bloc/saved_books/saved_books_state.dart';
import 'package:back_base_assignment/presentation/bloc/saved_books/saved_books_event.dart';

class DetailsScreen extends StatefulWidget {
  final Book book;

  const DetailsScreen({super.key, required this.book});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _backGroundContainer(),
          if (widget.book.coverUrl.isNotEmpty)
            _backGroundCoverGradient(context),
          _bookInformation(context),
        ],
      ),
    );
  }

  SingleChildScrollView _bookInformation(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            Hero(
              tag: 'book-cover-${widget.book.id}',
              child: _buildAnimatedCover(),
            ),
            Text(
              widget.book.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.black,
                    offset: Offset(2.0, 2.0),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              widget.book.author,
              style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: Colors.grey[300],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(),
            const SizedBox(height: 16),
            BlocBuilder<SavedBooksBloc, SavedBooksState>(
              builder: (context, savedBooksState) {
                return _buildSaveButton(context, savedBooksState);
              },
            ),
          ],
        ),
      ),
    );
  }

  Container _backGroundContainer() {
    return Container(
      decoration: _boxDecoration(
        colors: [
          Colors.blueGrey[900]!,
          Colors.blueGrey[800]!,
          Colors.blueGrey[700]!,
        ],
      ),
    );
  }

  Container _backGroundCoverGradient(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: CachedNetworkImageProvider(widget.book.coverUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: _boxDecoration(
          colors: [
            Colors.blueGrey[900]!.withAlpha((255 * 0.2).round()),
            Colors.blueGrey[800]!.withAlpha((255 * 1.0).round()),
          ],
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration({required List<Color> colors}) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: colors,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );
  }

  Widget _buildAnimatedCover() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(_animationController.value * 2 * pi),
          child: child,
        );
      },
      child: Card(
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CachedNetworkImage(
            imageUrl: widget.book.coverUrl,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) =>
                const Icon(Icons.error, size: 50),
            width: 200,
            height: 300,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (widget.book.firstPublishYear != null)
          _buildInfoItem('Published', widget.book.firstPublishYear.toString()),
        if (widget.book.numberOfPages != null)
          _buildInfoItem('Pages', widget.book.numberOfPages.toString()),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[400])),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    SavedBooksState savedBooksState,
  ) {
    if (savedBooksState is SavedBooksLoaded) {
      final isSaved = savedBooksState.books.any(
        (book) => book.id == widget.book.id,
      );
      return ElevatedButton.icon(
        onPressed: () {
          if (isSaved) {
            context.read<SavedBooksBloc>().add(
              RemoveBookRequested(widget.book.id),
            );
          } else {
            context.read<SavedBooksBloc>().add(AddBookRequested(widget.book));
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isSaved ? 'Book removed from saved' : 'Book saved for later',
              ),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
        label: Text(isSaved ? 'Remove from Saved' : 'Save for Later'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    }
    return const CircularProgressIndicator();
  }
}
