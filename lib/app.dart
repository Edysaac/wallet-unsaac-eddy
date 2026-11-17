import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_unsaac/core/config/firebase_status.dart';
import 'package:wallet_unsaac/core/theme/app_theme.dart';
import 'package:wallet_unsaac/core/theme/theme_cubit.dart';
import 'package:wallet_unsaac/core/theme/theme_preferences.dart';
import 'package:wallet_unsaac/core/theme/theme_state.dart';
import 'package:wallet_unsaac/features/wallet/data/repositories/in_memory_wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/presentation/pages/wallet_home_page.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubit/privacy_cubit.dart';

/// Raíz de la aplicación.
///
/// Aquí se inyectan las dependencias que el resto del árbol necesita:
/// - `RepositoryProvider<WalletRepository>`: capa de datos disponible para
///   cualquier pantalla o bloc.
/// - `BlocProvider<ThemeCubit>`: estado global del tema.
///
/// `BlocBuilder` escucha el `ThemeCubit` y reconstruye `MaterialApp` cuando
/// cambia el modo claro/oscuro. Es el primer flujo evento → estado → interfaz
/// del curso.
class WalletApp extends StatelessWidget {
  const WalletApp({
    super.key,
    required this.firebaseStatus,
    required this.themePreferences,
    this.initialMode = ThemeMode.system,
  });

  final FirebaseStatus firebaseStatus;
  final ThemePreferences themePreferences;
  final ThemeMode initialMode;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<WalletRepository>(
          create: (_) => InMemoryWalletRepository(),
        ),
      ],
      child: BlocProvider(
        create: (_) =>
            ThemeCubit(preferences: themePreferences, initialMode: initialMode),
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return MaterialApp(
              title: 'Wallet UNSAAC',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: themeState.mode,
              home: BlocProvider(
                create: (_) => PrivacyCubit(),
                child: WalletHomePage(firebaseStatus: firebaseStatus),
              ),
            );
          },
        ),
      ),
    );
  }
}
