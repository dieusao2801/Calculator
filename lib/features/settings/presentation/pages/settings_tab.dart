import 'package:flutter/material.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ThemeSelectorSection(),
            // TODO: thêm section khác (About, Version, Privacy…) khi cần.
          ],
        ),
      ),
    );
  }
}
