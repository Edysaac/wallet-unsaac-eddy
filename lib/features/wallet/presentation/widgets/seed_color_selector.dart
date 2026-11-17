import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_unsaac/core/theme/app_theme.dart';
import 'package:wallet_unsaac/core/theme/theme_cubit.dart';
import 'package:wallet_unsaac/core/theme/theme_state.dart';

class SeedColorSelector extends StatelessWidget {
  const SeedColorSelector({super.key});

  static const colors = <(String, Color)>[
    ('Granate', AppTheme.seed),
    ('Azul', Color(0xFF1565C0)),
    ('Verde', Color(0xFF2E7D32)),
    ('Violeta', Color(0xFF7B1FA2)),
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Color de la aplicación'),
      content: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final (name, color) in colors)
            BlocSelector<ThemeCubit, ThemeState, bool>(
              selector: (state) => state.seedColor == color,
              builder: (context, selected) => Tooltip(
                message: name,
                child: Semantics(
                  label: name,
                  selected: selected,
                  button: true,
                  child: InkWell(
                    onTap: () => context.read<ThemeCubit>().setSeedColor(color),
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected
                              ? Theme.of(context).colorScheme.onSurface
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: selected
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}
