import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:back_base_assignment/presentation/screens/search_screen.dart';
import 'package:back_base_assignment/presentation/screens/details_screen.dart';
import 'package:back_base_assignment/presentation/screens/saved_books_screen.dart';
import 'package:back_base_assignment/domain/entities/book.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'search',
      builder: (BuildContext context, GoRouterState state) =>
          const SearchScreen(),
    ),
    GoRoute(
      path: '/saved',
      name: 'saved',
      builder: (BuildContext context, GoRouterState state) =>
          const SavedBooksScreen(),
    ),
    GoRoute(
      path: '/details',
      name: 'details',
      builder: (BuildContext context, GoRouterState state) {
        final extra = state.extra;
        if (extra is! Book) {
          throw FlutterError('Expected Book in state.extra for /details route');
        }
        return DetailsScreen(book: extra);
      },
    ),
  ],
);
