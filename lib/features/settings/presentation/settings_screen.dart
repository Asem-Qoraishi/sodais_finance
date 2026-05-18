import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sodais_finance/config/app_router.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/enums/app_locale_enum.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/core/utils/helpers/app_locale_helper.dart';
import 'package:sodais_finance/features/app/presentation/controllers/app_theme_mode_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isAppLockEnabled = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(appThemeModeProvider);
    final isDarkEnabled =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && theme.brightness == Brightness.dark);

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.settings.tr()),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          sizeConstants.spacingSmall,
          sizeConstants.spacingSmall,
          sizeConstants.spacingSmall,
          sizeConstants.spacingXXLarge,
        ),
        children: [
          _SettingsGroup(
            children: [
              _SettingsTile(
                icon: Icons.lock_outline_rounded,
                title: LocaleKeys.appLock.tr(),
                subtitle: LocaleKeys.secureWithBiometrics.tr(),
                trailing: Switch.adaptive(
                  value: _isAppLockEnabled,
                  onChanged: (value) {
                    setState(() {
                      _isAppLockEnabled = value;
                    });
                  },
                ),
              ),
              _SettingsTile(
                icon: Icons.language_rounded,
                title: LocaleKeys.languageAndFormat.tr(),
                subtitle:
                    '${LocaleKeys.currencyDateLanguage.tr()} • ${_currentLocaleLabel(context)}',
                onTap: _showLanguageSheet,
              ),
              _SettingsTile(
                icon: Icons.auto_fix_high_rounded,
                title: LocaleKeys.customizeInvoice.tr(),
                subtitle: LocaleKeys.invoicePrefixExample.tr(),
                onTap: () => _showComingSoon(),
              ),
              _SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: LocaleKeys.darkMode.tr(),
                subtitle: LocaleKeys.switchBetweenLightAndDark.tr(),
                trailing: Switch.adaptive(
                  value: isDarkEnabled,
                  onChanged: (value) => ref
                      .read(appThemeModeProvider.notifier)
                      .setDarkMode(value),
                ),
              ),
            ],
          ),
          SizedBox(height: sizeConstants.spacingSmall),
          _SettingsGroup(
            children: [
              _SettingsTile(
                icon: Icons.bar_chart_rounded,
                title: LocaleKeys.reports.tr(),
                subtitle: LocaleKeys.summaryOfSalesReports.tr(),
                onTap: () => context.push('/${routeNames.settings}/${routeNames.reports}'),
              ),
              _SettingsTile(
                icon: Icons.table_view_rounded,
                title: LocaleKeys.exportInvoiceDataToExcel.tr(),
                subtitle: LocaleKeys.editWithExcelOrGoogleSheet.tr(),
                onTap: () => _showComingSoon(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _currentLocaleLabel(BuildContext context) {
    return switch (appLocaleHelper.currentLocale(context)) {
      AppLocaleEnum.en => LocaleKeys.english.tr(),
      AppLocaleEnum.fa => LocaleKeys.persian.tr(),
      AppLocaleEnum.ps => LocaleKeys.pashto.tr(),
    };
  }

  Future<void> _showLanguageSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: sizeConstants.spacingMedium,
                  vertical: sizeConstants.spacingSmall,
                ),
                child: Text(
                  LocaleKeys.selectLanguage.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              for (final locale in AppLocaleEnum.values)
                ListTile(
                  title: Text(_localeLabel(locale)),
                  trailing: appLocaleHelper.currentLocale(context) == locale
                      ? Icon(
                          Icons.check_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () async {
                    await context.setLocale(locale.locale);
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  String _localeLabel(AppLocaleEnum locale) {
    return switch (locale) {
      AppLocaleEnum.en => LocaleKeys.english.tr(),
      AppLocaleEnum.fa => LocaleKeys.persian.tr(),
      AppLocaleEnum.ps => LocaleKeys.pashto.tr(),
    };
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(LocaleKeys.comingSoon.tr())),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(sizeConstants.radiusLarge),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          for (int index = 0; index < children.length; index++) ...[
            if (index > 0)
              Divider(
                height: 1,
                indent: sizeConstants.spacingMedium,
                endIndent: sizeConstants.spacingMedium,
              ),
            children[index],
          ],
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: trailing == null ? onTap : null,
      borderRadius: BorderRadius.circular(sizeConstants.radiusLarge),
      child: Padding(
        padding: EdgeInsets.all(sizeConstants.spacingMedium),
        child: Row(
          children: [
            Container(
              width: sizeConstants.avatarXSmall,
              height: sizeConstants.avatarXSmall,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(sizeConstants.radiusMedium),
              ),
              child: Icon(icon, color: theme.colorScheme.primary),
            ),
            SizedBox(width: sizeConstants.spacingSmall),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: sizeConstants.spacingXXSmall),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: sizeConstants.spacingSmall),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.hintColor,
                ),
          ],
        ),
      ),
    );
  }
}
