import 'package:mini_accounting_system/core/utils/route.dart';
import 'package:mini_accounting_system/notification_service.dart';
import 'package:mini_accounting_system/sqldb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  await NotificationService().requestNotificationPermission();
  await NotificationService().scheduleDailyReminders();
  SqlDb sqlDb = SqlDb(); // إنشاء كائن لقاعدة البيانات
  await sqlDb.intialDb(); // تهيئة قاعدة البيانات
  tz.setLocalLocation(tz.getLocation('Asia/Riyadh'));
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sqlDb), // 🔹 إضافة SqlDb كمزود
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(400, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder:
          (context, child) => MaterialApp.router(
            routerConfig: AppRouter.router,
            theme: ThemeData(
              textTheme: GoogleFonts.cairoTextTheme(
                Theme.of(context).textTheme,
              ),
              useMaterial3: false,
              scaffoldBackgroundColor: const Color(0xfffffbfb), // لون الخلفية
            ),
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar', 'AR'), // اللغة العربية
            ],
            locale: const Locale('ar', 'AR'),
            debugShowCheckedModeBanner: false,
          ),
    );
  }
}
