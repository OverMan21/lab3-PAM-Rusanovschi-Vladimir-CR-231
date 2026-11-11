import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme.dart';
import 'data/repositories/store_repository.dart';
import 'logic/favorites/favorites_cubit.dart';
import 'logic/home/home_cubit.dart';
import 'presentation/screens/home_screen.dart';

void main() => runApp(const GemStoreApp());

class GemStoreApp extends StatelessWidget {
  const GemStoreApp({super.key});

  @override
  Widget build(BuildContext context) {

    return RepositoryProvider(
      create: (_) => StoreRepository(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (c) => HomeCubit(c.read<StoreRepository>())..load(),
          ),
          BlocProvider(
            create: (c) => FavoritesCubit(c.read<StoreRepository>())..load(),
          ),
        ],
        child: MaterialApp(
          title: 'GemStore',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
