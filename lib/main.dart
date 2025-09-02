import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:back_base_assignment/core/theme/app_theme.dart';
import 'package:back_base_assignment/injection_container.dart';
import 'package:back_base_assignment/presentation/bloc/saved_books/saved_books_bloc.dart';
import 'package:back_base_assignment/presentation/bloc/saved_books/saved_books_event.dart';
import 'package:back_base_assignment/presentation/bloc/book_search/book_search_bloc.dart';
import 'package:back_base_assignment/core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServiceLocator.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ServiceLocator.savedBooksBloc.add(const LoadSavedBooks());
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SavedBooksBloc>(
          create: (context) => ServiceLocator.savedBooksBloc,
        ),
        BlocProvider<BookSearchBloc>(
          create: (context) => ServiceLocator.bookSearchBloc,
        ),
      ],
      child: MaterialApp.router(
        title: 'Book Finder',
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
