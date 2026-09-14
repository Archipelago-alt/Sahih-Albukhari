import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../shared/context_ext.dart';

/// Data sources, attribution, licences and privacy.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final info = ref.watch(contentInfoProvider).value;
    final version = ref.watch(appVersionProvider);
    Widget section(String title, List<Widget> children) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(title, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
    Widget para(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(t, style: theme.textTheme.bodyMedium?.copyWith(height: 1.6)),
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            children: [
              section(l10n.aboutSourcesTitle, [
                para(l10n.aboutSourceShamela),
                para(l10n.aboutSourceEdition),
                if (info != null)
                  for (final e in info.sourceCard.entries)
                    Text('${e.key}: ${e.value}', textDirection: TextDirection.rtl, style: theme.textTheme.bodySmall),
                const SizedBox(height: 8),
                para(l10n.aboutSourceNote),
                para(l10n.aboutVerification),
                para(l10n.aboutNoTranslation),
                if (info?.sourceContentSha256 case final sha?)
                  Text(
                    l10n.aboutContentVersion(sha.substring(0, 16)),
                    textDirection: TextDirection.ltr,
                    style: theme.textTheme.bodySmall,
                  ),
              ]),
              section(l10n.aboutFontsTitle, [para(l10n.aboutFontAmiri), para(l10n.aboutFontNoto)]),
              section(l10n.aboutPrivacyTitle, [para(l10n.aboutPrivacyBody)]),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                leading: const Icon(Icons.gavel_outlined),
                title: Text(l10n.aboutLicenses),
                onTap: () =>
                    showLicensePage(context: context, applicationName: l10n.appTitle, applicationVersion: version),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(l10n.aboutAppVersion(version), style: theme.textTheme.bodySmall),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
