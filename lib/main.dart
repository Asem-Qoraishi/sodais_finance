import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sodais_finance/config/app_router.dart';
import 'package:sodais_finance/config/theme/app_theme.dart';
import 'package:sodais_finance/core/enums/app_locale_enum.dart';
import 'package:sodais_finance/core/localization/codegen_loader.g.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await ScreenUtil.ensureScreenSize();
  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: AppLocaleEnum.values
            .map((language) => Locale(language.languageCode))
            .toList(),
        path: 'assets/translations',
        assetLoader: CodegenLoader(),
        startLocale: Locale(AppLocaleEnum.fa.languageCode),
        fallbackLocale: Locale(AppLocaleEnum.fa.languageCode),
        useOnlyLangCode: true,
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;

    return ScreenUtilInit(
      designSize: Size(width, height),
      minTextAdapt: true,
      splitScreenMode: true,
      ensureScreenSize: true,
      builder: (context, child) => MaterialApp.router(
        onGenerateTitle: (context) => LocaleKeys.appName.tr(),
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(context),
        darkTheme: AppTheme.darkTheme(context),
        themeMode: ThemeMode.light,
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        routerConfig: AppRouter().goRouter,
      ),
    );
  }
}
