import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_poolakey/flutter_poolakey.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import 'dart:io';

const bazaarRsaKey = String.fromEnvironment('BAZAAR_RSA_KEY');

const List<Map<String, dynamic>> availableIcons = [
  {'name': 'خانه', 'icon': Icons.home},
  {'name': 'کارها', 'icon': Icons.list},
  {'name': 'تماس', 'icon': Icons.phone},
  {'name': 'تنظیمات', 'icon': Icons.settings},
  {'name': 'پروفایل', 'icon': Icons.person},
  {'name': 'علاقه‌مندی', 'icon': Icons.favorite},
  {'name': 'جستجو', 'icon': Icons.search},
  {'name': 'فروشگاه', 'icon': Icons.shopping_cart},
  {'name': 'گالری', 'icon': Icons.photo},
  {'name': 'ویژه', 'icon': Icons.star},
  {'name': 'فایل‌ها', 'icon': Icons.folder},
  {'name': 'درباره', 'icon': Icons.info},
  {'name': 'پیام', 'icon': Icons.message},
  {'name': 'موزیک', 'icon': Icons.music_note},
  {'name': 'مکان', 'icon': Icons.location_on},
];

const List<Map<String, String>> actionTypes = [
  {'id': 'none', 'name': 'بدون عملکرد', 'icon': 'block'},
  {'id': 'open_link', 'name': 'باز کردن لینک', 'icon': 'link'},
  {'id': 'go_page', 'name': 'رفتن به صفحه', 'icon': 'arrow_forward'},
  {'id': 'close_page', 'name': 'بستن صفحه', 'icon': 'close'},
  {'id': 'close_app', 'name': 'بستن اپ', 'icon': 'exit'},
  {'id': 'share', 'name': 'اشتراک‌گذاری', 'icon': 'share'},
  {'id': 'rate', 'name': 'ارسال نظر', 'icon': 'star'},
  {'id': 'show_dialog', 'name': 'نمایش دیالوگ', 'icon': 'message'},
  {'id': 'play_video', 'name': 'پخش فیلم', 'icon': 'video'},
  {'id': 'show_image', 'name': 'نمایش تصویر', 'icon': 'image'},
  {'id': 'play_audio', 'name': 'پخش صدا', 'icon': 'music'},
  {'id': 'download', 'name': 'دانلود از اینترنت', 'icon': 'download'},
];

IconData getActionIcon(String? id) {
  switch (id) {
    case 'none': return Icons.block;
    case 'open_link': return Icons.link;
    case 'go_page': return Icons.arrow_forward;
    case 'close_page': return Icons.close;
    case 'close_app': return Icons.exit_to_app;
    case 'share': return Icons.share;
    case 'rate': return Icons.star;
    case 'show_dialog': return Icons.message;
    case 'play_video': return Icons.video_library;
    case 'show_image': return Icons.image;
    case 'play_audio': return Icons.music_note;
    case 'download': return Icons.download;
    default: return Icons.widgets;
  }
}

String getActionName(String? id) {
  for (final a in actionTypes) {
    if (a['id'] == id) return a['name']!;
  }
  return 'نامشخص';
}

// ═══════════ ویجت‌های مشترک UI ═══════════
class GradientButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  final bool primary;
  final Color? color;
  const GradientButton({super.key, required this.text, required this.icon, required this.onTap, this.primary = true, this.color});
  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF6A11CB);
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              gradient: primary
                ? LinearGradient(colors: [c, Color.lerp(c, Colors.blue, 0.3)!])
                : null,
              color: primary ? null : Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(18),
              border: primary ? null : Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
              boxShadow: primary ? [BoxShadow(color: c.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 6))] : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(width: 10),
                Text(text, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? color;
  const FeatureCard({super.key, required this.icon, required this.title, required this.subtitle, required this.onTap, this.color});
  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF6A11CB);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [c, Color.lerp(c, Colors.white, 0.3)!]),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 3),
                      Text(subtitle, style: TextStyle(fontSize: 12.5, color: Colors.grey[600])),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════ Status Notifiers ═══════════
class ProStatus extends ChangeNotifier {
  bool _isPro = false;
  bool get isPro => _isPro;
  ProStatus() { _loadStatus(); }
  Future<void> _loadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isPro = prefs.getBool('is_pro') ?? false;
    notifyListeners();
  }
  Future<void> setPro(bool value) async {
    _isPro = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_pro', value);
    notifyListeners();
  }
}
final proStatus = ProStatus();

class ThemeNotifier extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;
  ThemeNotifier() { _loadTheme(); }
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool('dark_mode') ?? false;
    notifyListeners();
  }
  Future<void> toggleTheme() async {
    _isDark = !_isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _isDark);
    notifyListeners();
  }
}
final themeNotifier = ThemeNotifier();

void main() => runApp(const AppLand());

class AppLand extends StatelessWidget {
  const AppLand({super.key});
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeNotifier,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'اپ لند',
        themeMode: themeNotifier.isDark ? ThemeMode.dark : ThemeMode.light,
        theme: ThemeData(
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6A11CB), brightness: Brightness.light),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6A11CB), brightness: Brightness.dark),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _f;
  late Animation<double> _s;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _f = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _c, curve: Curves.easeIn));
    _s = Tween<double>(begin: 0.5, end: 1).animate(CurvedAnimation(parent: _c, curve: Curves.elasticOut));
    _c.forward();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
    });
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC), Color(0xFF1A5FB4)],
        ),
      ),
      child: Center(child: FadeTransition(opacity: _f, child: ScaleTransition(scale: _s, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 160, height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(45),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 50, spreadRadius: 20)],
          ),
          child: const Icon(Icons.apps, size: 100, color: Color(0xFF6A11CB)),
        ),
        const SizedBox(height: 45),
        const Text('اپ لند', style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 5, shadows: [Shadow(color: Colors.black26, blurRadius: 15)])),
        const SizedBox(height: 15),
        const Text('سرزمین اپ های تو', style: TextStyle(fontSize: 20, color: Colors.white70, letterSpacing: 2.5)),
        const SizedBox(height: 50),
        const SizedBox(width: 35, height: 35, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)),
      ])))),
    ));
  }
}
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}
class _MainScreenState extends State<MainScreen> {
  int _i = 0;
  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }
  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('onboarding_seen') ?? false;
    if (!seen && mounted) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) _showOnboarding();
    }
  }
  void _showOnboarding() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(children: [
          Icon(Icons.school, color: Color(0xFF6A11CB), size: 30),
          SizedBox(width: 12),
          Text('به اپ لند خوش آمدید!', style: TextStyle(fontSize: 17)),
        ]),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('با اپ لند بدون کدنویسی، اپ اندروید بسازید!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF6A11CB))),
              SizedBox(height: 16),
              Text('🎯 امکانات اپ:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              SizedBox(height: 10),
              Text('• ساخت اپ محتوا محور و والپیپر', style: TextStyle(fontSize: 13)),
              Text('• صفحه‌ساز با ۱۲ المان مختلف', style: TextStyle(fontSize: 13)),
              Text('• اسپلش با عکس، متن، رنگ و مدت زمان', style: TextStyle(fontSize: 13)),
              Text('• منوی پایین و کشویی داینامیک', style: TextStyle(fontSize: 13)),
              Text('• ۱۲ اکشن مختلف برای دکمه‌ها', style: TextStyle(fontSize: 13)),
              Text('• پخش فیلم و موزیک', style: TextStyle(fontSize: 13)),
              Text('• پشتیبان‌گیری و بازیابی', style: TextStyle(fontSize: 13)),
              SizedBox(height: 16),
              Text('🎁 نسخه‌ها:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              SizedBox(height: 10),
              Text('• پرو (۱۹۹,۰۰۰ تومان): برای هر اپ', style: TextStyle(fontSize: 13)),
              Text('• دائمی (۹۹۹,۰۰۰ تومان): همه اپ‌ها', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('onboarding_seen', true);
                if (mounted) Navigator.pop(c);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A11CB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text('متوجه شدم', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(onStart: () => setState(() => _i = 2)),
      const MyAppsPage(),
      CreateAppPage(onCreated: () => setState(() => _i = 1)),
      const SettingsPage(),
    ];
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: KeyedSubtree(key: ValueKey(_i), child: pages[_i]),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 25, offset: const Offset(0, -8))],
        ),
        child: NavigationBar(
          height: 70,
          selectedIndex: _i,
          onDestinationSelected: (i) => setState(() => _i = i),
          backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A1A1A) : Colors.white,
          indicatorColor: const Color(0xFF6A11CB).withOpacity(0.15),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: Color(0xFF6A11CB)), label: 'خانه'),
            NavigationDestination(icon: Icon(Icons.apps_outlined), selectedIcon: Icon(Icons.apps, color: Color(0xFF6A11CB)), label: 'اپ های من'),
            NavigationDestination(icon: Icon(Icons.add_circle_outline), selectedIcon: Icon(Icons.add_circle, color: Color(0xFF6A11CB)), label: 'ساخت اپ'),
            NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings, color: Color(0xFF6A11CB)), label: 'تنظیمات'),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final VoidCallback onStart;
  const HomePage({super.key, required this.onStart});
  Future<void> _openRubika(BuildContext ctx, String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) { await launchUrl(uri, mode: LaunchMode.externalApplication); return; }
      final androidIntent = Uri.parse('intent://rubika.ir/#Intent;scheme=https;package=ir.rubika;end');
      if (await canLaunchUrl(androidIntent)) { await launchUrl(androidIntent); return; }
      if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('لطفاً روبیکا رو نصب کنید یا این آدرس رو دستی باز کنید: $url')));
    } catch (e) {
      if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('خطا: $e')));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC), Color(0xFF1A5FB4)],
        ),
      ),
      child: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Container(
              width: 140, height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 40, spreadRadius: 12)],
              ),
              child: const Icon(Icons.apps, size: 80, color: Color(0xFF6A11CB)),
            ),
            const SizedBox(height: 30),
            const Text('اپ لند', style: TextStyle(fontSize: 54, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 4, shadows: [Shadow(color: Colors.black26, blurRadius: 12)])),
            const SizedBox(height: 10),
            const Text('سرزمین اپ های تو', style: TextStyle(fontSize: 20, color: Colors.white70, letterSpacing: 2)),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: const Text(
                'با اپ لند بدون کدنویسی، اپ اندروید بسازید! کافیه اسم، رنگ، آیکون و صفحات اپتون رو انتخاب کنید.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.white, height: 1.7),
              ),
            ),
            const SizedBox(height: 35),
            GradientButton(text: 'شروع کنید', icon: Icons.play_arrow, onTap: onStart, primary: true, color: Colors.white),
            const SizedBox(height: 14),
            GradientButton(text: 'مرکز آموزش ساخت اپ', icon: Icons.school, onTap: () => _openRubika(context, 'https://rubikabot.ir/Appland_ir'), primary: false),
            const SizedBox(height: 14),
            GradientButton(text: 'پشتیبانی', icon: Icons.support_agent, onTap: () => _openRubika(context, 'https://rubikabot.ir/support_1i'), primary: false),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('نسخه ۱.۰.۰', style: TextStyle(fontSize: 13, color: Colors.white70)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      )),
    );
  }
}
class MyAppsPage extends StatefulWidget {
  const MyAppsPage({super.key});
  @override
  State<MyAppsPage> createState() => _MyAppsPageState();
}
class _MyAppsPageState extends State<MyAppsPage> {
  List<Map<String, dynamic>> _apps = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _l = true;
  final _searchCtrl = TextEditingController();
  @override
  void initState() { super.initState(); _load(); }
  @override
  void didChangeDependencies() { super.didChangeDependencies(); _load(); }
  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final a = p.getStringList('my_apps') ?? [];
    if (mounted) setState(() {
      _apps = a.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
      _filtered = _apps;
      _l = false;
    });
  }
  void _filter(String q) {
    setState(() {
      _filtered = q.isEmpty ? _apps : _apps.where((e) => (e['name'] ?? '').toString().toLowerCase().contains(q.toLowerCase())).toList();
    });
  }
  Future<void> _del(int i) async {
    final realIndex = _apps.indexOf(_filtered[i]);
    final confirm = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Row(children: [Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30), SizedBox(width: 10), Text('حذف اپ')]),
      content: const Text('مطمئنی می خوای این اپ رو حذف کنی؟'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('لغو')),
        ElevatedButton(
          onPressed: () => Navigator.pop(c, true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Text('حذف'),
        ),
      ],
    ));
    if (confirm == true) {
      final p = await SharedPreferences.getInstance();
      final a = p.getStringList('my_apps') ?? [];
      a.removeAt(realIndex);
      await p.setStringList('my_apps', a);
      _load();
    }
  }
  void _edit(int i) {
    final realIndex = _apps.indexOf(_filtered[i]);
    Navigator.push(context, MaterialPageRoute(builder: (_) => AppEditorPage(appIndex: realIndex))).then((_) => _load());
  }
  void _preview(int i) {
    final app = _filtered[i];
    Navigator.push(context, MaterialPageRoute(builder: (_) => PreviewPage(app: app)));
  }
  void _showDetails(int i) {
    final app = _filtered[i];
    showDialog(context: context, builder: (c) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: Color(app['color'] ?? 0xFF6A11CB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.apps, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(app['name'] ?? '', style: const TextStyle(fontSize: 18))),
      ]),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        _detailRow('پکیج', app['packageName'] ?? ''),
        _detailRow('نوع', app['appType'] == 'content' ? 'محتوا محور' : 'والپیپر'),
        _detailRow('تعداد صفحات', '${(app['pages'] as List? ?? []).length}'),
        _detailRow('مارکت', app['market'] == 'myket' ? 'مایکت' : 'کافه‌بازار'),
        _detailRow('نسخه', '${app['versionName'] ?? '1.0.0'} (${app['versionCode'] ?? 1})'),
        _detailRow('وضعیت پرو', app['isPro'] == true ? 'پرو' : (proStatus.isPro ? 'پرو (دائمی)' : 'رایگان')),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('بستن'))],
    ));
  }
  Widget _detailRow(String label, String value) {
    return Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [
      Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      Expanded(child: Text(value, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13))),
    ]));
  }
  Future<void> _support(int i) async {
    final app = _filtered[i];
    await showDialog<String>(context: context, builder: (c) {
      final ctrl = TextEditingController();
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(children: [Icon(Icons.favorite, color: Colors.pink), SizedBox(width: 10), Text('پشتیبانی از پروژه')]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('از اپ "${app['name']}" حمایت کن'),
          const SizedBox(height: 12),
          TextField(controller: ctrl, maxLines: 3, decoration: InputDecoration(hintText: 'پیام شما (اختیاری)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('لغو')),
          ElevatedButton(
            onPressed: () => Navigator.pop(c),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A11CB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('ارسال'),
          ),
        ],
      );
    });
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('پیام پشتیبانی ارسال شد. ممنون!'), backgroundColor: Colors.green));
  }
  Future<void> _buyProForApp(int i) async {
    final app = _filtered[i];
    final realIndex = _apps.indexOf(app);
    if (app['isPro'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('این اپ قبلاً پرو شده!'), backgroundColor: Colors.green));
      return;
    }
    if (proStatus.isPro) {
      app['isPro'] = true;
      final p = await SharedPreferences.getInstance();
      final a = p.getStringList('my_apps') ?? [];
      a[realIndex] = jsonEncode(app);
      await p.setStringList('my_apps', a);
      _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اپ پرو شد (نسخه دائمی)!'), backgroundColor: Colors.green));
      return;
    }
    if (bazaarRsaKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('کلید RSA تنظیم نشده!'), backgroundColor: Colors.red));
      return;
    }
    try {
      await FlutterPoolakey.connect(
        bazaarRsaKey,
        onSucceed: () async {
          try {
            final response = await FlutterPoolakey.purchase('appland_pro', payload: 'app_pro_purchase');
            if (response != null) {
              app['isPro'] = true;
              final p = await SharedPreferences.getInstance();
              final a = p.getStringList('my_apps') ?? [];
              a[realIndex] = jsonEncode(app);
              await p.setStringList('my_apps', a);
              _load();
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اپ پرو شد!'), backgroundColor: Colors.green));
            } else {
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('پرداخت انجام نشد!'), backgroundColor: Colors.orange));
            }
          } catch (e) {
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا: $e'), backgroundColor: Colors.red));
          }
        },
        onFailed: () { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اتصال برقرار نشد'), backgroundColor: Colors.red)); },
        onDisconnected: () { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اتصال قطع شد'), backgroundColor: Colors.red)); },
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا: $e'), backgroundColor: Colors.red));
    }
  }
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('اپ های من', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF6A11CB),
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
          ),
        ),
      ),
      body: _l ? const Center(child: CircularProgressIndicator(color: Color(0xFF6A11CB)))
        : _apps.isEmpty ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: const Color(0xFF6A11CB).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.apps, size: 80, color: isDark ? Colors.grey[600] : Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            Text('هنوز اپی نساخته اید', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.grey[300] : Colors.grey[800])),
            const SizedBox(height: 10),
            Text('از تب «ساخت اپ» شروع کنید', style: TextStyle(fontSize: 15, color: Colors.grey[500])),
          ]))
        : Column(children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 4))],
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: _filter,
                  decoration: InputDecoration(
                    hintText: 'جستجو در اپ ها...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF6A11CB)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _filtered.isEmpty
                ? const Center(child: Text('اپی پیدا نشد', style: TextStyle(fontSize: 16, color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filtered.length,
                    itemBuilder: (c, i) {
                      final app = _filtered[i];
                      final isPro = app['isPro'] == true || proStatus.isPro;
                      final appColor = Color(app['color'] ?? 0xFF6A11CB);
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: Duration(milliseconds: 300 + i * 50),
                        builder: (context, value, child) => Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: Opacity(opacity: value, child: child),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _edit(i),
                              borderRadius: BorderRadius.circular(22),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: [BoxShadow(color: appColor.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8))],
                                  border: Border.all(color: appColor.withOpacity(0.15), width: 1.5),
                                ),
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 65, height: 65,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [appColor, Color.lerp(appColor, Colors.white, 0.3)!]),
                                        borderRadius: BorderRadius.circular(18),
                                        boxShadow: [BoxShadow(color: appColor.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
                                      ),
                                      child: Icon(isPro ? Icons.verified : Icons.apps, color: Colors.white, size: 34),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(children: [
                                            Flexible(child: Text(app['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17), overflow: TextOverflow.ellipsis)),
                                            if (isPro) const Padding(padding: EdgeInsets.only(right: 6), child: Icon(Icons.star, color: Colors.amber, size: 18)),
                                          ]),
                                          const SizedBox(height: 6),
                                          Row(children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: appColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                app['appType'] == 'content' ? 'محتوا محور' : 'والپیپر',
                                                style: TextStyle(fontSize: 11, color: appColor, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '${(app['pages'] as List? ?? []).length} صفحه',
                                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                                              ),
                                            ),
                                          ]),
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                      icon: Icon(Icons.more_vert, color: appColor),
                                      onSelected: (v) {
                                        if (v == 'del') _del(i);
                                        else if (v == 'details') _showDetails(i);
                                        else if (v == 'support') _support(i);
                                        else if (v == 'edit') _edit(i);
                                        else if (v == 'preview') _preview(i);
                                        else if (v == 'buy') _buyProForApp(i);
                                      },
                                      itemBuilder: (c) => [
                                        const PopupMenuItem(value: 'preview', child: Row(children: [Icon(Icons.play_circle, color: Colors.green), SizedBox(width: 10), Text('پیش‌نمایش')])),
                                        const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.build, color: Color(0xFF6A11CB)), SizedBox(width: 10), Text('ویرایش')])),
                                        if (!isPro)
                                          const PopupMenuItem(value: 'buy', child: Row(children: [Icon(Icons.star, color: Colors.amber), SizedBox(width: 10), Text('خرید پرو (۱۹۹,۰۰۰)')])),
                                        const PopupMenuItem(value: 'details', child: Row(children: [Icon(Icons.info, color: Colors.blue), SizedBox(width: 10), Text('جزئیات')])),
                                        const PopupMenuItem(value: 'support', child: Row(children: [Icon(Icons.favorite, color: Colors.pink), SizedBox(width: 10), Text('پشتیبانی')])),
                                        const PopupMenuItem(value: 'del', child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 10), Text('حذف')])),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ]),
    );
  }
}

class CreateAppPage extends StatefulWidget {
  final VoidCallback onCreated;
  const CreateAppPage({super.key, required this.onCreated});
  @override
  State<CreateAppPage> createState() => _CreateAppPageState();
}
class _CreateAppPageState extends State<CreateAppPage> {
  final _name = TextEditingController();
  final _welcome = TextEditingController();
  final _pkg = TextEditingController();
  Color _color = const Color(0xFF6A11CB);
  String _type = 'content';
  final _colors = [
    const Color(0xFF6A11CB),
    const Color(0xFF2575FC),
    const Color(0xFFFF6B6B),
    const Color(0xFF4ECDC4),
    const Color(0xFFFFA500),
    const Color(0xFF9B59B6),
    const Color(0xFF16A085),
    const Color(0xFFE74C3C),
  ];
  @override
  void dispose() { _name.dispose(); _welcome.dispose(); _pkg.dispose(); super.dispose(); }
  Future<void> _save() async {
    if (_name.text.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('نام اپ را وارد کنید'))); return; }
    if (_pkg.text.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('نام پکیج را وارد کنید'))); return; }
    final p = await SharedPreferences.getInstance();
    final a = p.getStringList('my_apps') ?? [];
    a.add(jsonEncode({
      'name': _name.text,
      'welcome': _welcome.text.isEmpty ? 'به ${_name.text} خوش آمدید' : _welcome.text,
      'color': _color.value,
      'packageName': _pkg.text,
      'appType': _type,
      'rsaKey': '',
      'isPro': false,
      'pages': [],
      'wallpapers': [],
      'themeColor': _color.value,
      'fontFamily': 'default',
      'splashText': '',
      'splashImage': '',
      'splashColor': 0xFF6A11CB,
      'splashDuration': 3,
      'splashTargetPage': 0,
      'bottomMenu': [],
      'drawerMenu': [],
      'adiveryKey': '',
      'tapsellKey': '',
      'adPlatform': 'adivery',
      'adEnabled': false,
      'adAppId': '',
      'adVideoUnitId': '',
      'adInterstitialUnitId': '',
      'adBannerUnitId': '',
      'adVideoEnabled': false,
      'adInterstitialEnabled': false,
      'adBannerEnabled': false,
      'iconPath': '',
      'market': 'bazaar',
      'versionCode': 1,
      'versionName': '1.0.0',
      'shortDescription': '',
    }));
    await p.setStringList('my_apps', a);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('اپ ${_name.text} ساخته شد'), backgroundColor: Colors.green));
      _name.clear(); _welcome.clear(); _pkg.clear();
      widget.onCreated();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ساخت اپ جدید', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF6A11CB),
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _buildCard(
            icon: Icons.info,
            title: 'اطلاعات اصلی',
            child: Column(children: [
              _buildField('نام اپ', _name, 'فروشگاه من', Icons.apps),
              const SizedBox(height: 16),
              _buildField('پیام خوش آمدگویی', _welcome, 'به فروشگاه من خوش آمدید', Icons.message),
              const SizedBox(height: 16),
              _buildField('نام پکیج', _pkg, 'ir.appland.myapp', Icons.code),
            ]),
          ),
          const SizedBox(height: 16),
          _buildCard(
            icon: Icons.category,
            title: 'نوع اپ',
            child: Column(children: [
              _buildTypeRadio('content', 'محتوا محور', 'صفحات دلخواه با المان‌های مختلف', Icons.pages),
              const SizedBox(height: 10),
              _buildTypeRadio('wallpaper', 'والپیپر', 'گالری پس زمینه', Icons.wallpaper),
            ]),
          ),
          const SizedBox(height: 16),
          _buildCard(
            icon: Icons.palette,
            title: 'رنگ اپ',
            child: Wrap(
              spacing: 12, runSpacing: 12,
              children: _colors.map((c) => GestureDetector(
                onTap: () => setState(() => _color = c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 55, height: 55,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(color: _color == c ? Colors.black : Colors.transparent, width: 4),
                    boxShadow: _color == c ? [BoxShadow(color: c.withOpacity(0.6), blurRadius: 20, spreadRadius: 4)] : [],
                  ),
                  child: _color == c ? const Icon(Icons.check, color: Colors.white, size: 30) : null,
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 25),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [_color, Color.lerp(_color, Colors.blue, 0.4)!]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: _color.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _save,
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle, color: Colors.white, size: 24),
                      SizedBox(width: 10),
                      Text('ساخت اپ', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }
  Widget _buildCard({required IconData icon, required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6A11CB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF6A11CB), size: 20),
            ),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ]),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
  Widget _buildTypeRadio(String value, String title, String subtitle, IconData icon) {
    final selected = _type == value;
    return GestureDetector(
      onTap: () => setState(() => _type = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF6A11CB).withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: selected ? const Color(0xFF6A11CB) : Colors.grey.shade300, width: selected ? 2 : 1),
        ),
        child: Row(children: [
          Icon(icon, color: selected ? const Color(0xFF6A11CB) : Colors.grey, size: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: selected ? const Color(0xFF6A11CB) : null)),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Radio<String>(value: value, groupValue: _type, activeColor: const Color(0xFF6A11CB), onChanged: (v) => setState(() => _type = v!)),
        ]),
      ),
    );
  }
  Widget _buildField(String label, TextEditingController ctrl, String hint, IconData icon) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      TextField(
        controller: ctrl,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          prefixIcon: Icon(icon, color: const Color(0xFF6A11CB)),
          filled: true,
        ),
      ),
    ]);
  }
}
class AppEditorPage extends StatefulWidget {
  final int appIndex;
  const AppEditorPage({super.key, required this.appIndex});
  @override
  State<AppEditorPage> createState() => _AppEditorPageState();
}
class _AppEditorPageState extends State<AppEditorPage> {
  Map<String, dynamic>? _app;
  final _rsaCtrl = TextEditingController();
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final a = p.getStringList('my_apps') ?? [];
    if (widget.appIndex < a.length) {
      setState(() {
        _app = jsonDecode(a[widget.appIndex]) as Map<String, dynamic>;
        _rsaCtrl.text = _app!['rsaKey'] ?? '';
      });
    }
  }
  Future<void> _save() async {
    if (_app == null) return;
    _app!['rsaKey'] = _rsaCtrl.text.trim();
    final p = await SharedPreferences.getInstance();
    final a = p.getStringList('my_apps') ?? [];
    a[widget.appIndex] = jsonEncode(_app);
    await p.setStringList('my_apps', a);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ذخیره شد'), backgroundColor: Colors.green));
  }
  bool get _isAppPro => _app?['isPro'] == true;
  bool get _hasAccess => proStatus.isPro || _isAppPro;
  @override
  Widget build(BuildContext context) {
    if (_app == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_app!['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF6A11CB),
          foregroundColor: Colors.white,
          elevation: 0,
          flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]))),
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.build), text: 'ساخت'),
              Tab(icon: Icon(Icons.campaign), text: 'تبلیغات'),
              Tab(icon: Icon(Icons.payment), text: 'پرداخت'),
              Tab(icon: Icon(Icons.settings), text: 'تنظیمات'),
            ],
          ),
        ),
        body: TabBarView(children: [
          _buildTab(),
          _adsTab(),
          _payTab(),
          _setTab(),
        ]),
      ),
    );
  }
  Widget _buildTab() {
    final pages = (_app!['pages'] as List? ?? []);
    return ListView(padding: const EdgeInsets.all(16), children: [
      if (_app!['appType'] == 'wallpaper')
        FeatureCard(icon: Icons.wallpaper, title: 'گالری والپیپر', subtitle: 'افزودن عکس های پس زمینه', onTap: () => _editWallpapers(), color: Colors.pink)
      else
        FeatureCard(icon: Icons.pages, title: 'صفحات اپ', subtitle: '${pages.length} صفحه ساخته شده', onTap: () => _editPages(pages), color: const Color(0xFF6A11CB)),
      FeatureCard(icon: Icons.preview, title: 'پیش نمایش', subtitle: 'مشاهده پیش نمایش کامل اپ', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PreviewPage(app: _app!))), color: Colors.green),
      FeatureCard(icon: Icons.android, title: 'خروجی APK', subtitle: 'به زودی در نسخه‌های بعدی', onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('به زودی! در نظرات درخواست کنید'))), color: Colors.grey),
      FeatureCard(icon: Icons.wallpaper, title: 'Splash Screen', subtitle: 'عکس + متن + رنگ + مدت زمان', onTap: _splashDialog, color: Colors.orange),
      FeatureCard(icon: Icons.navigation, title: 'منوی پایین', subtitle: 'ناوبری پایین اپ (حداکثر ۴)', onTap: _bottomMenuDialog, color: Colors.blue),
      FeatureCard(icon: Icons.menu, title: 'منوی کشویی', subtitle: 'منوی کناری اپ', onTap: _drawerMenuDialog, color: Colors.teal),
      FeatureCard(icon: Icons.palette, title: 'حالت پیشرفته تم', subtitle: 'رنگ و فونت اپ', onTap: _themeDialog, color: Colors.deepPurple),
    ]);
  }
  void _editWallpapers() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => WallpaperEditorPage(appIndex: widget.appIndex))).then((_) => _load());
  }
  void _editPages(List pages) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => PagesListPage(appIndex: widget.appIndex))).then((_) => _load());
  }
  void _themeDialog() {
    showDialog(context: context, builder: (c) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('حالت پیشرفته تم'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('رنگ اصلی اپ:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10, runSpacing: 10,
              children: [
                Colors.deepPurple, Colors.blue, Colors.red, Colors.teal, Colors.orange, Colors.purple, Colors.pink, Colors.green,
              ].map((c) => GestureDetector(
                onTap: () => setState(() => _app!['themeColor'] = c.value),
                child: Container(width: 42, height: 42, decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: (_app!['themeColor'] ?? 0) == c.value ? Colors.black : Colors.transparent, width: 3))),
              )).toList(),
            ),
            const SizedBox(height: 20),
            const Text('فونت اپ:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _app!['fontFamily'] ?? 'default',
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'default', child: Text('پیش فرض')),
                DropdownMenuItem(value: 'vazir', child: Text('وزیرمتن')),
                DropdownMenuItem(value: 'iranSans', child: Text('ایران سنس')),
              ],
              onChanged: (v) => setState(() => _app!['fontFamily'] = v),
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('لغو')),
          ElevatedButton(
            onPressed: () { _save(); Navigator.pop(c); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم ذخیره شد'), backgroundColor: Colors.green)); },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A11CB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('ذخیره'),
          ),
        ],
      );
    });
  }
  void _splashDialog() {
    final textCtrl = TextEditingController(text: _app!['splashText'] ?? '');
    Color selectedColor = Color(_app!['splashColor'] ?? 0xFF6A11CB);
    double duration = (_app!['splashDuration'] ?? 3).toDouble();
    int targetPage = _app!['splashTargetPage'] ?? 0;
    String imagePath = _app!['splashImage'] ?? '';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(children: [Icon(Icons.wallpaper, color: Color(0xFF6A11CB)), SizedBox(width: 10), Text('طراحی اسپلش')]),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('متن اسپلش:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(controller: textCtrl, decoration: InputDecoration(hintText: 'به اپ من خوش آمدید', border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))),
                const SizedBox(height: 16),
                const Text('عکس اسپلش:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                if (imagePath.isNotEmpty)
                  ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(imagePath), width: double.infinity, height: 100, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image))),
                const SizedBox(height: 6),
                Row(children: [
                  Expanded(child: OutlinedButton.icon(
                    onPressed: () async {
                      final picker = ImagePicker();
                      final img = await picker.pickImage(source: ImageSource.gallery);
                      if (img != null) setStateDialog(() => imagePath = img.path);
                    },
                    icon: const Icon(Icons.image),
                    label: const Text('انتخاب عکس'),
                    style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  )),
                  if (imagePath.isNotEmpty)
                    IconButton(onPressed: () => setStateDialog(() => imagePath = ''), icon: const Icon(Icons.delete, color: Colors.red)),
                ]),
                const SizedBox(height: 16),
                const Text('رنگ پس‌زمینه:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  Colors.deepPurple, Colors.blue, Colors.red, Colors.teal, Colors.orange, Colors.purple, Colors.pink, Colors.green, Colors.black, Colors.white,
                ].map((color) => GestureDetector(
                  onTap: () => setStateDialog(() => selectedColor = color),
                  child: Container(width: 42, height: 42, decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: selectedColor == color ? Colors.blue : Colors.grey.shade300, width: selectedColor == color ? 3 : 1))),
                )).toList()),
                const SizedBox(height: 16),
                Text('مدت زمان: ${duration.toInt()} ثانیه', style: const TextStyle(fontWeight: FontWeight.bold)),
                Slider(value: duration, min: 1, max: 10, divisions: 9, label: '${duration.toInt()}', activeColor: const Color(0xFF6A11CB), onChanged: (v) => setStateDialog(() => duration = v)),
                const SizedBox(height: 8),
                const Text('صفحه بعد از اسپلش:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                DropdownButton<int>(
                  value: targetPage,
                  isExpanded: true,
                  items: [
                    for (int i = 0; i < (_app!['pages'] as List? ?? []).length; i++)
                      DropdownMenuItem(value: i, child: Text((_app!['pages'] as List)[i]['name'] ?? 'صفحه ${i + 1}')),
                  ],
                  onChanged: (v) => setStateDialog(() => targetPage = v ?? 0),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: const Text('لغو', style: TextStyle(color: Colors.red))),
            ElevatedButton(
              onPressed: () async {
                _app!['splashText'] = textCtrl.text;
                _app!['splashImage'] = imagePath;
                _app!['splashColor'] = selectedColor.value;
                _app!['splashDuration'] = duration.toInt();
                _app!['splashTargetPage'] = targetPage;
                await _save();
                if (mounted) Navigator.pop(c);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A11CB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('ذخیره'),
            ),
          ],
        ),
      ),
    );
  }
  void _bottomMenuDialog() {
    List<dynamic> items = List.from(_app!['bottomMenu'] ?? []);
    final pages = (_app!['pages'] as List? ?? []);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(children: [Icon(Icons.navigation, color: Color(0xFF6A11CB)), SizedBox(width: 10), Text('منوی پایین')]),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('حداکثر ۴ آیتم (${items.length}/۴)', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 12),
                if (pages.isEmpty) const Text('اول باید حداقل یه صفحه بسازی!', style: TextStyle(color: Colors.red)),
                for (int i = 0; i < items.length; i++) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(child: Text(items[i]['label'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold))),
                          IconButton(icon: const Icon(Icons.edit, size: 18, color: Color(0xFF6A11CB)), onPressed: () async {
                            final result = await _editMenuItem(items[i], pages);
                            if (result != null) setStateDialog(() => items[i] = result);
                          }),
                          IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.red), onPressed: () => setStateDialog(() => items.removeAt(i))),
                        ]),
                        Text('مقصد: ${items[i]['pageIndex'] != null && items[i]['pageIndex'] < pages.length ? pages[items[i]['pageIndex']]['name'] : 'نامشخص'}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
                if (items.length < 4 && pages.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () async {
                      final result = await _editMenuItem({'label': '', 'iconType': 'builtin', 'iconIndex': 0, 'iconPath': '', 'pageIndex': 0}, pages);
                      if (result != null) setStateDialog(() => items.add(result));
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('افزودن آیتم'),
                    style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: const Text('لغو', style: TextStyle(color: Colors.red))),
            ElevatedButton(
              onPressed: () async { _app!['bottomMenu'] = items; await _save(); if (mounted) Navigator.pop(c); },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A11CB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('ذخیره'),
            ),
          ],
        ),
      ),
    );
  }
  void _drawerMenuDialog() {
    List<dynamic> items = List.from(_app!['drawerMenu'] ?? []);
    final pages = (_app!['pages'] as List? ?? []);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(children: [Icon(Icons.menu, color: Color(0xFF6A11CB)), SizedBox(width: 10), Text('منوی کشویی')]),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${items.length} آیتم', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 12),
                if (pages.isEmpty) const Text('اول باید حداقل یه صفحه بسازی!', style: TextStyle(color: Colors.red)),
                for (int i = 0; i < items.length; i++) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(child: Text(items[i]['label'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold))),
                          IconButton(icon: const Icon(Icons.edit, size: 18, color: Color(0xFF6A11CB)), onPressed: () async {
                            final result = await _editMenuItem(items[i], pages);
                            if (result != null) setStateDialog(() => items[i] = result);
                          }),
                          IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.red), onPressed: () => setStateDialog(() => items.removeAt(i))),
                        ]),
                        Text('مقصد: ${items[i]['pageIndex'] != null && items[i]['pageIndex'] < pages.length ? pages[items[i]['pageIndex']]['name'] : 'نامشخص'}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
                if (pages.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () async {
                      final result = await _editMenuItem({'label': '', 'iconType': 'builtin', 'iconIndex': 0, 'iconPath': '', 'pageIndex': 0}, pages);
                      if (result != null) setStateDialog(() => items.add(result));
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('افزودن آیتم'),
                    style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: const Text('لغو', style: TextStyle(color: Colors.red))),
            ElevatedButton(
              onPressed: () async { _app!['drawerMenu'] = items; await _save(); if (mounted) Navigator.pop(c); },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A11CB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('ذخیره'),
            ),
          ],
        ),
      ),
    );
  }
  Future<Map<String, dynamic>?> _editMenuItem(Map<String, dynamic> item, List pages) async {
    final labelCtrl = TextEditingController(text: item['label'] ?? '');
    String iconType = item['iconType'] ?? 'builtin';
    int iconIndex = item['iconIndex'] ?? 0;
    String iconPath = item['iconPath'] ?? '';
    int pageIndex = item['pageIndex'] ?? 0;
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('ویرایش آیتم'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('نام آیتم:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(controller: labelCtrl, decoration: InputDecoration(hintText: 'مثلا: خانه', border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))),
                const SizedBox(height: 16),
                const Text('آیکون:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Row(children: [
                  ChoiceChip(label: const Text('آماده'), selected: iconType == 'builtin', onSelected: (v) => setStateDialog(() => iconType = 'builtin')),
                  const SizedBox(width: 8),
                  ChoiceChip(label: const Text('گالری'), selected: iconType == 'gallery', onSelected: (v) => setStateDialog(() => iconType = 'gallery')),
                ]),
                const SizedBox(height: 10),
                if (iconType == 'builtin')
                  Wrap(spacing: 6, runSpacing: 6, children: [
                    for (int i = 0; i < availableIcons.length; i++)
                      GestureDetector(
                        onTap: () => setStateDialog(() => iconIndex = i),
                        child: Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: iconIndex == i ? const Color(0xFF6A11CB).withOpacity(0.2) : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: iconIndex == i ? const Color(0xFF6A11CB) : Colors.transparent, width: 2),
                          ),
                          child: Icon(availableIcons[i]['icon'], color: const Color(0xFF6A11CB), size: 22),
                        ),
                      ),
                  ])
                else ...[
                  if (iconPath.isNotEmpty)
                    ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(File(iconPath), width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image))),
                  const SizedBox(height: 6),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picker = ImagePicker();
                      final img = await picker.pickImage(source: ImageSource.gallery);
                      if (img != null) setStateDialog(() => iconPath = img.path);
                    },
                    icon: const Icon(Icons.image),
                    label: const Text('انتخاب از گالری'),
                    style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ],
                const SizedBox(height: 16),
                const Text('مقصد:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                DropdownButton<int>(
                  value: pageIndex < pages.length ? pageIndex : 0,
                  isExpanded: true,
                  items: [
                    for (int i = 0; i < pages.length; i++)
                      DropdownMenuItem(value: i, child: Text(pages[i]['name'] ?? 'صفحه ${i + 1}')),
                  ],
                  onChanged: (v) => setStateDialog(() => pageIndex = v ?? 0),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: const Text('لغو')),
            ElevatedButton(
              onPressed: () => Navigator.pop(c, {'label': labelCtrl.text, 'iconType': iconType, 'iconIndex': iconIndex, 'iconPath': iconPath, 'pageIndex': pageIndex}),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A11CB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('ذخیره'),
            ),
          ],
        ),
      ),
    );
  }
  Widget _adsTab() {
    if (!_hasAccess) {
      return _lockedTab('تبلیغات', 'برای فعال سازی تبلیغات (ادیوری و تپسل)، این اپ رو با قیمت ۱۹۹,۰۰۰ تومان پرو کنید.', Icons.campaign);
    }
    bool adEnabled = _app!['adEnabled'] ?? false;
    String platform = _app!['adPlatform'] ?? 'adivery';
    bool videoEnabled = _app!['adVideoEnabled'] ?? false;
    bool interstitialEnabled = _app!['adInterstitialEnabled'] ?? false;
    bool bannerEnabled = _app!['adBannerEnabled'] ?? false;
    return StatefulBuilder(
      builder: (context, setStateAds) => ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFF6A11CB).withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [Icon(Icons.info_outline, color: Color(0xFF6A11CB), size: 20), SizedBox(width: 8), Text('راهنما', style: TextStyle(fontWeight: FontWeight.bold))]),
              SizedBox(height: 8),
              Text('برای فعال‌سازی تبلیغات، از سایت ادیوری یا تپسل ثبت‌نام کنید و کلید خود را دریافت کنید.', style: TextStyle(fontSize: 13)),
              SizedBox(height: 6),
              Text('در صفحه‌ساز، المان «بنر تبلیغ» را اضافه کنید تا تبلیغات نمایش داده شود.', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 4))]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('فعال‌سازی تبلیغات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: const Text('تبلیغات در اپ نمایش داده شود'),
                value: adEnabled,
                activeColor: const Color(0xFF6A11CB),
                onChanged: (v) => setStateAds(() { _app!['adEnabled'] = v; adEnabled = v; }),
              ),
              const Divider(),
              const Text('پلتفرم تبلیغات:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setStateAds(() { _app!['adPlatform'] = 'adivery'; platform = 'adivery'; }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: platform == 'adivery' ? const Color(0xFFFFC107).withOpacity(0.2) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: platform == 'adivery' ? const Color(0xFFFFC107) : Colors.transparent, width: 2),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.play_circle, color: platform == 'adivery' ? const Color(0xFFFFC107) : Colors.grey, size: 40),
                            const SizedBox(height: 6),
                            Text('ادیوری', style: TextStyle(fontWeight: FontWeight.bold, color: platform == 'adivery' ? Colors.black : Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setStateAds(() { _app!['adPlatform'] = 'tapsell'; platform = 'tapsell'; }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: platform == 'tapsell' ? Colors.red.withOpacity(0.15) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: platform == 'tapsell' ? Colors.red : Colors.transparent, width: 2),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.play_circle, color: platform == 'tapsell' ? Colors.red : Colors.grey, size: 40),
                            const SizedBox(height: 6),
                            Text('تپسل', style: TextStyle(fontWeight: FontWeight.bold, color: platform == 'tapsell' ? Colors.black : Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('شناسه برنامه (App ID):', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: TextEditingController(text: _app!['adAppId'] ?? ''),
                onChanged: (v) => _app!['adAppId'] = v,
                decoration: InputDecoration(
                  hintText: 'مثلاً: 7c388fbf-c528-...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  prefixIcon: const Icon(Icons.vpn_key),
                ),
              ),
              const SizedBox(height: 8),
              Text('از پنل ${platform == 'adivery' ? 'ادیوری' : 'تپسل'} دریافت کنید', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildAdTypeCard(
          icon: Icons.video_library,
          title: 'تبلیغ ویدیویی',
          enabled: videoEnabled,
          unitId: _app!['adVideoUnitId'] ?? '',
          hint: 'شناسه جایگاه ویدیویی',
          onToggle: (v) => setStateAds(() { _app!['adVideoEnabled'] = v; videoEnabled = v; }),
          onUnitIdChanged: (v) => _app!['adVideoUnitId'] = v,
        ),
        const SizedBox(height: 12),
        _buildAdTypeCard(
          icon: Icons.flash_on,
          title: 'تبلیغ آنی (Interstitial)',
          enabled: interstitialEnabled,
          unitId: _app!['adInterstitialUnitId'] ?? '',
          hint: 'شناسه جایگاه آنی',
          onToggle: (v) => setStateAds(() { _app!['adInterstitialEnabled'] = v; interstitialEnabled = v; }),
          onUnitIdChanged: (v) => _app!['adInterstitialUnitId'] = v,
        ),
        const SizedBox(height: 12),
        _buildAdTypeCard(
          icon: Icons.crop_16_9,
          title: 'تبلیغ بنری',
          enabled: bannerEnabled,
          unitId: _app!['adBannerUnitId'] ?? '',
          hint: 'شناسه جایگاه بنری',
          onToggle: (v) => setStateAds(() { _app!['adBannerEnabled'] = v; bannerEnabled = v; }),
          onUnitIdChanged: (v) => _app!['adBannerUnitId'] = v,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async { await _save(); if (mounted) setStateAds(() {}); },
                icon: const Icon(Icons.save),
                label: const Text('ذخیره'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _load(),
                icon: const Icon(Icons.cancel),
                label: const Text('لغو'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
          ],
        ),
      ]),
    );
  }
  Widget _buildAdTypeCard({required IconData icon, required String title, required bool enabled, required String unitId, required String hint, required Function(bool) onToggle, required Function(String) onUnitIdChanged}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF6A11CB).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: const Color(0xFF6A11CB), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
              Switch(value: enabled, activeColor: const Color(0xFF6A11CB), onChanged: onToggle),
            ],
          ),
          if (enabled) ...[
            const SizedBox(height: 10),
            TextField(
              controller: TextEditingController(text: unitId),
              onChanged: onUnitIdChanged,
              decoration: InputDecoration(hintText: hint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ],
        ],
      ),
    );
  }
  Widget _payTab() {
    if (!_hasAccess) {
      return _lockedTab('پرداخت', 'برای فعال سازی پرداخت درون برنامه ای، این اپ رو با قیمت ۱۹۹,۰۰۰ تومان پرو کنید.', Icons.payment);
    }
    return ListView(padding: const EdgeInsets.all(16), children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 4))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [Icon(Icons.vpn_key, color: Color(0xFF6A11CB)), SizedBox(width: 10), Text('کلید RSA (کافه بازار)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
            const SizedBox(height: 12),
            TextField(
              controller: _rsaCtrl,
              maxLines: 5,
              decoration: InputDecoration(hintText: 'MII...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('ذخیره'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A11CB), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              ),
            ),
          ],
        ),
      ),
    ]);
  }
  Widget _setTab() {
    String market = _app!['market'] ?? 'bazaar';
    String iconPath = _app!['iconPath'] ?? '';
    final nameCtrl = TextEditingController(text: _app!['name'] ?? '');
    final pkgCtrl = TextEditingController(text: _app!['packageName'] ?? '');
    final descCtrl = TextEditingController(text: _app!['shortDescription'] ?? '');
    final vcCtrl = TextEditingController(text: '${_app!['versionCode'] ?? 1}');
    final vnCtrl = TextEditingController(text: _app!['versionName'] ?? '1.0.0');
    return StatefulBuilder(
      builder: (context, setStateSet) => ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 4))]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(children: [Icon(Icons.image, color: Color(0xFF6A11CB)), SizedBox(width: 10), Text('آیکون اپ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
              const SizedBox(height: 14),
              Row(children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: Color(_app!['color'] ?? 0xFF6A11CB),
                    borderRadius: BorderRadius.circular(20),
                    image: iconPath.isNotEmpty
                      ? DecorationImage(image: FileImage(File(iconPath)), fit: BoxFit.cover, onError: (_, __) {})
                      : null,
                  ),
                  child: iconPath.isEmpty ? const Icon(Icons.apps, color: Colors.white, size: 40) : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final img = await picker.pickImage(source: ImageSource.gallery);
                          if (img != null) setStateSet(() => _app!['iconPath'] = img.path);
                        },
                        icon: const Icon(Icons.image),
                        label: const Text('انتخاب آیکون'),
                        style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                      if (iconPath.isNotEmpty)
                        TextButton.icon(
                          onPressed: () => setStateSet(() => _app!['iconPath'] = ''),
                          icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                          label: const Text('حذف', style: TextStyle(color: Colors.red)),
                        ),
                    ],
                  ),
                ),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 4))]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(children: [Icon(Icons.info, color: Color(0xFF6A11CB)), SizedBox(width: 10), Text('اطلاعات اپ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
              const SizedBox(height: 14),
              TextField(controller: nameCtrl, onChanged: (v) => _app!['name'] = v, decoration: InputDecoration(labelText: 'نام اپ', border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)), prefixIcon: const Icon(Icons.text_fields))),
              const SizedBox(height: 12),
              TextField(controller: pkgCtrl, onChanged: (v) => _app!['packageName'] = v, decoration: InputDecoration(labelText: 'نام پکیج', border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)), prefixIcon: const Icon(Icons.code))),
              const SizedBox(height: 12),
              TextField(controller: descCtrl, onChanged: (v) => _app!['shortDescription'] = v, maxLines: 3, decoration: InputDecoration(labelText: 'توضیحات کوتاه', hintText: 'مثلاً: بهترین فروشگاه آنلاین', border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)), prefixIcon: const Icon(Icons.description))),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 4))]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(children: [Icon(Icons.store, color: Color(0xFF6A11CB)), SizedBox(width: 10), Text('مارکت مقصد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setStateSet(() { _app!['market'] = 'bazaar'; market = 'bazaar'; }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: market == 'bazaar' ? Colors.green.withOpacity(0.15) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: market == 'bazaar' ? Colors.green : Colors.transparent, width: 2),
                        ),
                        child: Column(children: [
                          Icon(Icons.shopping_bag, color: market == 'bazaar' ? Colors.green : Colors.grey, size: 32),
                          const SizedBox(height: 6),
                          Text('کافه‌بازار', style: TextStyle(fontWeight: FontWeight.bold, color: market == 'bazaar' ? Colors.green : Colors.grey)),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setStateSet(() { _app!['market'] = 'myket'; market = 'myket'; }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: market == 'myket' ? Colors.blue.withOpacity(0.15) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: market == 'myket' ? Colors.blue : Colors.transparent, width: 2),
                        ),
                        child: Column(children: [
                          Icon(Icons.shopping_bag, color: market == 'myket' ? Colors.blue : Colors.grey, size: 32),
                          const SizedBox(height: 6),
                          Text('مایکت', style: TextStyle(fontWeight: FontWeight.bold, color: market == 'myket' ? Colors.blue : Colors.grey)),
                        ]),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 4))]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(children: [Icon(Icons.numbers, color: Color(0xFF6A11CB)), SizedBox(width: 10), Text('نسخه', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: TextField(controller: vcCtrl, keyboardType: TextInputType.number, onChanged: (v) => _app!['versionCode'] = int.tryParse(v) ?? 1, decoration: InputDecoration(labelText: 'کد نسخه', border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: vnCtrl, onChanged: (v) => _app!['versionName'] = v, decoration: InputDecoration(labelText: 'نام نسخه', border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))))),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async { await _save(); if (mounted) setStateSet(() {}); },
            icon: const Icon(Icons.save),
            label: const Text('ذخیره تنظیمات'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A11CB), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
          ),
        ),
      ]),
    );
  }
  Widget _lockedTab(String title, String message, IconData icon) {
    return Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: const Color(0xFF6A11CB).withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(Icons.lock, size: 70, color: const Color(0xFF6A11CB).withOpacity(0.7)),
      ),
      const SizedBox(height: 24),
      Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: Colors.grey)),
      const SizedBox(height: 30),
      ElevatedButton.icon(
        onPressed: () => _showBuyDialogForApp(),
        icon: const Icon(Icons.shopping_cart),
        label: const Text('خرید پرو این اپ - ۱۹۹,۰۰۰ تومان'),
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A11CB), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
      ),
    ])));
  }
  void _showBuyDialogForApp() {
    showDialog(context: context, builder: (c) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text('خرید پرو این اپ'),
      content: const Text('برای فعال سازی تبلیغات و پرداخت این اپ، مبلغ ۱۹۹,۰۰۰ تومان پرداخت کنید.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('لغو')),
        ElevatedButton(
          onPressed: () async { Navigator.pop(c); await _purchaseThisApp(); },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A11CB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Text('پرداخت'),
        ),
      ],
    ));
  }
  Future<void> _purchaseThisApp() async {
    if (proStatus.isPro) { setState(() => _app!['isPro'] = true); await _save(); return; }
    if (bazaarRsaKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('کلید RSA تنظیم نشده!'), backgroundColor: Colors.red));
      return;
    }
    try {
      await FlutterPoolakey.connect(
        bazaarRsaKey,
        onSucceed: () async {
          try {
            final response = await FlutterPoolakey.purchase('appland_pro', payload: 'app_pro');
            if (response != null) {
              setState(() => _app!['isPro'] = true);
              await _save();
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اپ پرو شد!'), backgroundColor: Colors.green));
            }
          } catch (e) {}
        },
        onFailed: () {},
        onDisconnected: () {},
      );
    } catch (e) {}
  }
  void _changeName() {
    final ctrl = TextEditingController(text: _app!['name'] ?? '');
    showDialog(context: context, builder: (c) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text('تغییر نام'),
      content: TextField(controller: ctrl, decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('لغو')),
        ElevatedButton(onPressed: () async { _app!['name'] = ctrl.text; await _save(); if (mounted) Navigator.pop(c); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A11CB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('ذخیره')),
      ],
    ));
  }
}
class WallpaperEditorPage extends StatefulWidget {
  final int appIndex;
  const WallpaperEditorPage({super.key, required this.appIndex});
  @override
  State<WallpaperEditorPage> createState() => _WallpaperEditorPageState();
}
class _WallpaperEditorPageState extends State<WallpaperEditorPage> {
  List<String> _wallpapers = [];
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final a = p.getStringList('my_apps') ?? [];
    if (widget.appIndex < a.length) {
      final app = jsonDecode(a[widget.appIndex]) as Map<String, dynamic>;
      setState(() => _wallpapers = List<String>.from(app['wallpapers'] ?? []));
    }
  }
  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    final a = p.getStringList('my_apps') ?? [];
    final app = jsonDecode(a[widget.appIndex]) as Map<String, dynamic>;
    app['wallpapers'] = _wallpapers;
    a[widget.appIndex] = jsonEncode(app);
    await p.setStringList('my_apps', a);
  }
  Future<void> _pick() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) { setState(() => _wallpapers.add(img.path)); await _save(); }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('گالری والپیپر', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF6A11CB),
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]))),
      ),
      body: _wallpapers.isEmpty
        ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(color: const Color(0xFF6A11CB).withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.wallpaper, size: 80, color: Color(0xFF6A11CB)),
            ),
            const SizedBox(height: 24),
            const Text('هنوز عکسی اضافه نشده', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('با دکمه + عکس اضافه کن', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ]))
        : GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.75),
            itemCount: _wallpapers.length,
            itemBuilder: (c, i) => Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(File(_wallpapers[i]), width: double.infinity, height: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300, child: const Icon(Icons.broken_image))),
                ),
                Positioned(
                  top: 6, left: 6,
                  child: GestureDetector(
                    onTap: () async { setState(() => _wallpapers.removeAt(i)); await _save(); },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6)]),
                      child: const Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 6, right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(10)),
                    child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pick,
        backgroundColor: const Color(0xFF6A11CB),
        icon: const Icon(Icons.add_photo_alternate, color: Colors.white),
        label: const Text('افزودن عکس', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class PagesListPage extends StatefulWidget {
  final int appIndex;
  const PagesListPage({super.key, required this.appIndex});
  @override
  State<PagesListPage> createState() => _PagesListPageState();
}
class _PagesListPageState extends State<PagesListPage> {
  List _pages = [];
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final a = p.getStringList('my_apps') ?? [];
    if (widget.appIndex < a.length) {
      final app = jsonDecode(a[widget.appIndex]) as Map<String, dynamic>;
      setState(() => _pages = List.from(app['pages'] ?? []));
    }
  }
  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    final a = p.getStringList('my_apps') ?? [];
    final app = jsonDecode(a[widget.appIndex]) as Map<String, dynamic>;
    app['pages'] = _pages;
    a[widget.appIndex] = jsonEncode(app);
    await p.setStringList('my_apps', a);
  }
  void _add() {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (c) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Row(children: [Icon(Icons.add_circle, color: Color(0xFF6A11CB)), SizedBox(width: 10), Text('صفحه جدید')]),
      content: TextField(controller: ctrl, decoration: InputDecoration(hintText: 'نام صفحه', border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('لغو')),
        ElevatedButton(
          onPressed: () async {
            if (ctrl.text.isEmpty) return;
            setState(() => _pages.add({'name': ctrl.text, 'elements': []}));
            await _save();
            if (mounted) Navigator.pop(c);
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A11CB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Text('ساخت'),
        ),
      ],
    ));
  }
  void _edit(int i) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => PageEditorPage(appIndex: widget.appIndex, pageIndex: i))).then((_) => _load());
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('صفحات اپ (${_pages.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF6A11CB),
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]))),
      ),
      body: _pages.isEmpty
        ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(color: const Color(0xFF6A11CB).withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.pages, size: 80, color: Color(0xFF6A11CB)),
            ),
            const SizedBox(height: 24),
            const Text('هنوز صفحه ای نساخته اید', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('با دکمه + صفحه بساز', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ]))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _pages.length,
            itemBuilder: (c, i) => TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 300 + i * 50),
              builder: (context, value, child) => Transform.translate(offset: Offset(0, 20 * (1 - value)), child: Opacity(opacity: value, child: child)),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _edit(i),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 4))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50, height: 50,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20))),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_pages[i]['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text('${(_pages[i]['elements'] as List? ?? []).length} المان', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                              ],
                            ),
                          ),
                          IconButton(icon: const Icon(Icons.edit, color: Color(0xFF6A11CB)), onPressed: () => _edit(i)),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                title: const Text('حذف صفحه'),
                                content: Text('صفحه «${_pages[i]['name']}» حذف شود؟'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('لغو')),
                                  ElevatedButton(onPressed: () => Navigator.pop(c, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('حذف')),
                                ],
                              ));
                              if (confirm == true) {
                                setState(() => _pages.removeAt(i));
                                await _save();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        backgroundColor: const Color(0xFF6A11CB),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('صفحه جدید', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class PageEditorPage extends StatefulWidget {
  final int appIndex;
  final int pageIndex;
  const PageEditorPage({super.key, required this.appIndex, required this.pageIndex});
  @override
  State<PageEditorPage> createState() => _PageEditorPageState();
}
class _PageEditorPageState extends State<PageEditorPage> {
  Map<String, dynamic>? _page;
  List _allPages = [];
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final a = p.getStringList('my_apps') ?? [];
    if (widget.appIndex < a.length) {
      final app = jsonDecode(a[widget.appIndex]) as Map<String, dynamic>;
      final pages = List.from(app['pages'] ?? []);
      setState(() => _allPages = pages);
      if (widget.pageIndex < pages.length) setState(() => _page = Map<String, dynamic>.from(pages[widget.pageIndex]));
    }
  }
  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    final a = p.getStringList('my_apps') ?? [];
    final app = jsonDecode(a[widget.appIndex]) as Map<String, dynamic>;
    final pages = List.from(app['pages'] ?? []);
    pages[widget.pageIndex] = _page;
    app['pages'] = pages;
    a[widget.appIndex] = jsonEncode(app);
    await p.setStringList('my_apps', a);
  }
  void _addElement(String type) {
    final elements = List.from(_page!['elements'] ?? []);
    elements.add({
      'type': type,
      'text': '',
      'link': '',
      'mediaPath': '',
      'mediaSource': 'link',
      'color': 0xFF6A11CB,
      'textColor': 0xFFFFFFFF,
      'items': [],
      'targetPage': 0,
      'action': 'open_link',
      'actionValue': '',
      'images': [],
    });
    _page!['elements'] = elements;
    setState(() {}); _save();
  }
  void _deleteElement(int i) { setState(() { final e = List.from(_page!['elements']); e.removeAt(i); _page!['elements'] = e; }); _save(); }
  void _moveElement(int i, int delta) { final e = List.from(_page!['elements']); if (i + delta < 0 || i + delta >= e.length) return; final t = e[i]; e[i] = e[i + delta]; e[i + delta] = t; setState(() => _page!['elements'] = e); _save(); }
  void _editElement(int i) {
    final el = Map<String, dynamic>.from(_page!['elements'][i]);
    final textCtrl = TextEditingController(text: el['text'] ?? '');
    final linkCtrl = TextEditingController(text: el['link'] ?? '');
    final actionValueCtrl = TextEditingController(text: el['actionValue'] ?? '');
    final videoLinkCtrl = TextEditingController(text: el['videoLink'] ?? '');
    String mediaSource = el['mediaSource'] ?? 'link';
    String mediaPath = el['mediaPath'] ?? '';
    int targetPage = el['targetPage'] ?? 0;
    String action = el['action'] ?? 'open_link';
    List<String> sliderImages = List<String>.from(el['images'] ?? []);
    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('ویرایش ${_label(el['type'])}'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (el['type'] == 'text' || el['type'] == 'button' || el['type'] == 'imagebutton')
                TextField(controller: textCtrl, decoration: InputDecoration(labelText: 'متن', border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))),
              if (el['type'] == 'image' || el['type'] == 'imagebutton')
                TextField(controller: linkCtrl, decoration: InputDecoration(labelText: 'لینک تصویر (اختیاری)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))),
              if (el['type'] == 'image' || el['type'] == 'imagebutton') ...[
                const SizedBox(height: 8),
                if (mediaPath.isNotEmpty)
                  ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(mediaPath), height: 100, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox())),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final img = await picker.pickImage(source: ImageSource.gallery);
                    if (img != null) setStateDialog(() => mediaPath = img.path);
                  },
                  icon: const Icon(Icons.image),
                  label: const Text('انتخاب تصویر از گالری'),
                  style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ],
              if (el['type'] == 'video') ...[
                const SizedBox(height: 8),
                const Text('منبع:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Row(children: [
                  ChoiceChip(label: const Text('از لینک'), selected: mediaSource == 'link', onSelected: (v) => setStateDialog(() => mediaSource = 'link')),
                  const SizedBox(width: 8),
                  ChoiceChip(label: const Text('از گالری'), selected: mediaSource == 'gallery', onSelected: (v) => setStateDialog(() => mediaSource = 'gallery')),
                ]),
                const SizedBox(height: 8),
                if (mediaSource == 'link')
                  TextField(controller: videoLinkCtrl, decoration: InputDecoration(labelText: 'لینک فیلم', border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))))
                else ...[
                  if (mediaPath.isNotEmpty)
                    Text('فایل: ${mediaPath.split('/').last}', style: const TextStyle(fontSize: 12, color: Colors.green)),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picker = ImagePicker();
                      final file = await picker.pickVideo(source: ImageSource.gallery);
                      if (file != null) setStateDialog(() => mediaPath = file.path);
                    },
                    icon: const Icon(Icons.folder_open),
                    label: const Text('انتخاب از گالری'),
                    style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ],
              ],
              if (el['type'] == 'audio') ...[
                const SizedBox(height: 8),
                const Text('منبع:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Row(children: [
                  ChoiceChip(label: const Text('از لینک'), selected: mediaSource == 'link', onSelected: (v) => setStateDialog(() => mediaSource = 'link')),
                  const SizedBox(width: 8),
                  ChoiceChip(label: const Text('از گالری'), selected: mediaSource == 'gallery', onSelected: (v) => setStateDialog(() => mediaSource = 'gallery')),
                ]),
                const SizedBox(height: 8),
                if (mediaSource == 'link')
                  TextField(controller: linkCtrl, decoration: InputDecoration(labelText: 'لینک موزیک', border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))))
                else ...[
                  if (mediaPath.isNotEmpty)
                    Text('فایل: ${mediaPath.split('/').last}', style: const TextStyle(fontSize: 12, color: Colors.green)),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picker = ImagePicker();
                      final file = await picker.pickMedia();
                      if (file != null) setStateDialog(() => mediaPath = file.path);
                    },
                    icon: const Icon(Icons.folder_open),
                    label: const Text('انتخاب از گالری'),
                    style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ],
              ],
              if (el['type'] == 'slider') ...[
                const SizedBox(height: 8),
                Text('تعداد عکس: ${sliderImages.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: [
                    for (int j = 0; j < sliderImages.length; j++)
                      Stack(
                        children: [
                          ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(File(sliderImages[j]), width: 75, height: 75, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image))),
                          Positioned(
                            top: 0, right: 0,
                            child: GestureDetector(
                              onTap: () => setStateDialog(() => sliderImages.removeAt(j)),
                              child: Container(padding: const EdgeInsets.all(3), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white, size: 14)),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final img = await picker.pickImage(source: ImageSource.gallery);
                    if (img != null) setStateDialog(() => sliderImages.add(img.path));
                  },
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('افزودن عکس'),
                  style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ],
              if (el['type'] == 'banner')
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Row(children: [Icon(Icons.info, color: Colors.orange), SizedBox(width: 10), Expanded(child: Text('این المان به عنوان جایگاه تبلیغ بنری استفاده می‌شود.', style: TextStyle(fontSize: 13)))]),
                ),
              if (el['type'] == 'button' || el['type'] == 'imagebutton' || el['type'] == 'purchase') ...[
                const SizedBox(height: 12),
                const Text('عملکرد:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                DropdownButton<String>(
                  value: action,
                  isExpanded: true,
                  items: actionTypes.map((a) => DropdownMenuItem(value: a['id'], child: Text(a['name']!))).toList(),
                  onChanged: (v) => setStateDialog(() => action = v ?? 'none'),
                ),
                const SizedBox(height: 10),
                if (action == 'open_link' || action == 'play_video' || action == 'play_audio' || action == 'show_image' || action == 'download')
                  TextField(controller: actionValueCtrl, decoration: InputDecoration(labelText: 'لینک / مقدار', border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))),
                if (action == 'go_page')
                  DropdownButton<int>(
                    value: targetPage < _allPages.length ? targetPage : 0,
                    isExpanded: true,
                    items: [
                      for (int j = 0; j < _allPages.length; j++)
                        DropdownMenuItem(value: j, child: Text(_allPages[j]['name'] ?? 'صفحه ${j + 1}')),
                    ],
                    onChanged: (v) => setStateDialog(() => targetPage = v ?? 0),
                  ),
                if (action == 'show_dialog')
                  TextField(controller: actionValueCtrl, decoration: InputDecoration(labelText: 'متن دیالوگ', border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))),
              ],
              if (el['type'] == 'nextpage') ...[
                const SizedBox(height: 12),
                const Text('صفحه مقصد:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                DropdownButton<int>(
                  value: targetPage < _allPages.length ? targetPage : 0,
                  isExpanded: true,
                  items: [
                    for (int j = 0; j < _allPages.length; j++)
                      DropdownMenuItem(value: j, child: Text(_allPages[j]['name'] ?? 'صفحه ${j + 1}')),
                  ],
                  onChanged: (v) => setStateDialog(() => targetPage = v ?? 0),
                ),
              ],
              const SizedBox(height: 16),
              const Text('رنگ:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Wrap(spacing: 8, runSpacing: 8, children: [
                Colors.deepPurple, Colors.blue, Colors.red, Colors.teal, Colors.orange, Colors.purple, Colors.pink, Colors.green,
              ].map((c) => GestureDetector(
                onTap: () => setStateDialog(() => el['color'] = c.value),
                child: Container(width: 42, height: 42, decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: el['color'] == c.value ? Colors.black : Colors.transparent, width: 3))),
              )).toList()),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: const Text('لغو')),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  el['text'] = textCtrl.text;
                  el['link'] = linkCtrl.text;
                  el['mediaSource'] = mediaSource;
                  el['mediaPath'] = mediaPath;
                  el['videoLink'] = videoLinkCtrl.text;
                  el['targetPage'] = targetPage;
                  el['action'] = action;
                  el['actionValue'] = actionValueCtrl.text;
                  el['images'] = sliderImages;
                  _page!['elements'][i] = el;
                });
                _save();
                Navigator.pop(c);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A11CB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('ذخیره'),
            ),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    if (_page == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final elements = (_page!['elements'] as List? ?? []);
    return Scaffold(
      appBar: AppBar(
        title: Text(_page!['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF6A11CB),
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]))),
      ),
      body: elements.isEmpty
        ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(color: const Color(0xFF6A11CB).withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.widgets, size: 80, color: Color(0xFF6A11CB)),
            ),
            const SizedBox(height: 24),
            const Text('هنوز المانی اضافه نشده', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('از دکمه‌های پایین المان اضافه کن', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ]))
        : ListView.builder(
            padding: const EdgeInsets.all(16), itemCount: elements.length, itemBuilder: (c, i) {
              final el = elements[i];
              String subtitle = el['text'] ?? el['link'] ?? '';
              if (el['type'] == 'nextpage') {
                final t = el['targetPage'] ?? 0;
                subtitle = t < _allPages.length ? 'مقصد: ${_allPages[t]['name']}' : 'مقصد: صفحه اول';
              } else if (el['type'] == 'video' || el['type'] == 'audio') {
                subtitle = el['mediaSource'] == 'gallery' ? 'از گالری: ${(el['mediaPath'] ?? '').split('/').last}' : 'از لینک: ${el['link'] ?? ''}';
              } else if (el['type'] == 'button') {
                subtitle = '${el['text'] ?? ''} • ${getActionName(el['action'])}';
              } else if (el['type'] == 'slider') {
                subtitle = '${(el['images'] as List? ?? []).length} عکس';
              }
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 300 + i * 40),
                builder: (context, value, child) => Transform.translate(offset: Offset(0, 20 * (1 - value)), child: Opacity(opacity: value, child: child)),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 3))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6A11CB).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(_icon(el['type']), color: const Color(0xFF6A11CB), size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_label(el['type']), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              if (subtitle.isNotEmpty)
                                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        IconButton(icon: const Icon(Icons.arrow_upward, size: 18), onPressed: () => _moveElement(i, -1)),
                        IconButton(icon: const Icon(Icons.arrow_downward, size: 18), onPressed: () => _moveElement(i, 1)),
                        IconButton(icon: const Icon(Icons.edit, color: Color(0xFF6A11CB), size: 20), onPressed: () => _editElement(i)),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () => _deleteElement(i)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, -5))],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _btn(Icons.text_fields, 'متن', 'text', Colors.blue),
            _btn(Icons.smart_button, 'دکمه', 'button', const Color(0xFF6A11CB)),
            _btn(Icons.image, 'تصویر', 'image', Colors.green),
            _btn(Icons.touch_app, 'دکمه تصویری', 'imagebutton', Colors.teal),
            _btn(Icons.video_library, 'فیلم', 'video', Colors.red),
            _btn(Icons.music_note, 'موزیک', 'audio', Colors.pink),
            _btn(Icons.view_carousel, 'اسلایدر', 'slider', Colors.orange),
            _btn(Icons.campaign, 'بنر تبلیغ', 'banner', Colors.amber),
            _btn(Icons.arrow_forward, 'صفحه بعد', 'nextpage', Colors.deepPurple),
            _btn(Icons.payment, 'پرداخت', 'purchase', Colors.indigo),
          ]),
        ),
      ),
    );
  }
  Widget _btn(IconData icon, String label, String type, Color color) {
    return Padding(padding: const EdgeInsets.only(right: 8), child: ElevatedButton.icon(
      onPressed: () => _addElement(type),
      icon: Icon(icon, size: 16), label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    ));
  }
  IconData _icon(String? t) {
    switch (t) {
      case 'text': return Icons.text_fields;
      case 'button': return Icons.smart_button;
      case 'image': return Icons.image;
      case 'imagebutton': return Icons.touch_app;
      case 'video': return Icons.video_library;
      case 'audio': return Icons.music_note;
      case 'slider': return Icons.view_carousel;
      case 'banner': return Icons.campaign;
      case 'bottomnav': return Icons.navigation;
      case 'drawer': return Icons.menu;
      case 'nextpage': return Icons.arrow_forward;
      case 'purchase': return Icons.payment;
      default: return Icons.widgets;
    }
  }
  String _label(String? t) {
    switch (t) {
      case 'text': return 'متن';
      case 'button': return 'دکمه';
      case 'image': return 'تصویر';
      case 'imagebutton': return 'دکمه تصویری';
      case 'video': return 'فیلم';
      case 'audio': return 'موزیک';
      case 'slider': return 'اسلایدر';
      case 'banner': return 'بنر تبلیغ';
      case 'bottomnav': return 'منوی پایین';
      case 'drawer': return 'منوی کشویی';
      case 'nextpage': return 'صفحه بعد';
      case 'purchase': return 'پرداخت';
      default: return 'نامشخص';
    }
  }
}
class PreviewPage extends StatefulWidget {
  final Map<String, dynamic> app;
  const PreviewPage({super.key, required this.app});
  @override
  State<PreviewPage> createState() => _PreviewPageState();
}
class _PreviewPageState extends State<PreviewPage> {
  late Map<String, dynamic> _app;
  bool _showSplash = true;
  int _currentPageIndex = 0;
  @override
  void initState() {
    super.initState();
    _app = Map<String, dynamic>.from(widget.app);
    _startSplashTimer();
  }
  void _startSplashTimer() {
    final duration = (_app['splashDuration'] ?? 3) as int;
    final targetPage = (_app['splashTargetPage'] ?? 0) as int;
    Future.delayed(Duration(seconds: duration), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
          _currentPageIndex = targetPage;
        });
      }
    });
  }
  void _goToPage(int index) {
    final pages = (_app['pages'] as List? ?? []);
    if (index >= 0 && index < pages.length) {
      setState(() => _currentPageIndex = index);
    }
  }
  Future<void> _downloadWallpaper(BuildContext context, String path, int index) async {
    try {
      await Gal.putImage(path, album: 'AppLand');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('والپیپر $index ذخیره شد!'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا در ذخیره: $e'), backgroundColor: Colors.red));
      }
    }
  }
  Widget _buildSplash() {
    final splashColor = Color(_app['splashColor'] ?? 0xFF6A11CB);
    final splashText = _app['splashText'] ?? _app['name'] ?? '';
    final splashImage = _app['splashImage'] ?? '';
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [splashColor, Color.lerp(splashColor, Colors.black, 0.3)!],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (splashImage.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 30, spreadRadius: 10)],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(35),
                  child: Image.file(File(splashImage), width: 160, height: 160, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 100, color: Colors.white54)),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(35),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 30, spreadRadius: 10)],
                ),
                child: Icon(Icons.apps, size: 80, color: splashColor),
              ),
            const SizedBox(height: 35),
            if (splashText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(splashText, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black45, blurRadius: 10)])),
              ),
            const SizedBox(height: 50),
            const SizedBox(width: 35, height: 35, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)),
          ],
        ),
      ),
    );
  }
  Future<void> _handleAction(String action, String value, int targetPage) async {
    switch (action) {
      case 'none':
        break;
      case 'open_link':
        if (value.isNotEmpty) {
          final uri = Uri.parse(value);
          if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        break;
      case 'go_page':
        _goToPage(targetPage);
        break;
      case 'close_page':
        if (Navigator.canPop(context)) Navigator.pop(context);
        break;
      case 'close_app':
        if (mounted) SystemNavigator.pop();
        break;
      case 'share':
        await Share.share('اپ ${_app['name'] ?? ''} رو نصب کن!');
        break;
      case 'rate':
        final uri = Uri.parse('bazaar://details?id=${_app['packageName'] ?? ''}');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('کافه‌بازار نصب نیست')));
        }
        break;
      case 'show_dialog':
        if (mounted) {
          showDialog(
            context: context,
            builder: (c) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              content: Text(value.isNotEmpty ? value : 'پیام'),
              actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('بستن'))],
            ),
          );
        }
        break;
      case 'play_video':
      case 'play_audio':
      case 'show_image':
      case 'download':
        if (value.isNotEmpty) {
          final uri = Uri.parse(value);
          if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        break;
    }
  }
  Widget _buildElement(Map<String, dynamic> el) {
    final type = el['type'];
    final action = el['action'] ?? 'open_link';
    final actionValue = el['actionValue'] ?? '';
    final targetPage = el['targetPage'] ?? 0;
    if (type == 'text') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(el['text'] ?? '', style: TextStyle(fontSize: 18, color: Color(el['color'] ?? 0xFF000000), height: 1.6)),
      );
    }
    if (type == 'button') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _handleAction(action, actionValue, targetPage),
            icon: Icon(getActionIcon(action), size: 20),
            label: Text(el['text'] ?? 'دکمه', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(el['color'] ?? 0xFF6A11CB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 4,
            ),
          ),
        ),
      );
    }
    if (type == 'image') {
      final src_val = (el['mediaPath'] ?? '').isNotEmpty ? el['mediaPath'] : (el['link'] ?? '');
      if (src_val.isEmpty) return const SizedBox();
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: (el['mediaPath'] ?? '').isNotEmpty
            ? Image.file(File(src_val), errorBuilder: (_, __, ___) => const SizedBox())
            : Image.network(src_val, errorBuilder: (_, __, ___) => const SizedBox()),
        ),
      );
    }
    if (type == 'imagebutton') {
      final src_val = (el['mediaPath'] ?? '').isNotEmpty ? el['mediaPath'] : (el['link'] ?? '');
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: GestureDetector(
          onTap: () => _handleAction(action, actionValue, targetPage),
          child: Container(
            width: double.infinity,
            height: 130,
            decoration: BoxDecoration(
              color: Color(el['color'] ?? 0xFF6A11CB),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Color(el['color'] ?? 0xFF6A11CB).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5))],
              image: src_val.isNotEmpty
                ? DecorationImage(
                    image: (el['mediaPath'] ?? '').isNotEmpty ? FileImage(File(src_val)) : NetworkImage(src_val) as ImageProvider,
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
                  )
                : null,
            ),
            child: Center(
              child: Text(
                el['text'] ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black54, blurRadius: 8)]),
              ),
            ),
          ),
        ),
      );
    }
    if (type == 'video') {
      final src = el['mediaSource'] ?? 'link';
      final src_val = src == 'gallery' ? (el['mediaPath'] ?? '') : (el['link'] ?? el['videoLink'] ?? '');
      if (src_val.isEmpty) return const SizedBox();
      if (src == 'gallery') {
        return Padding(padding: const EdgeInsets.only(bottom: 16), child: _VideoPlayerWidget(path: src_val));
      } else {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _handleAction('play_video', src_val, targetPage),
              borderRadius: BorderRadius.circular(15),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50, height: 50,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('پخش فیلم', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 3),
                          Text(src_val, style: const TextStyle(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const Icon(Icons.open_in_new, size: 18, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }
    if (type == 'audio') {
      final src = el['mediaSource'] ?? 'link';
      final src_val = src == 'gallery' ? (el['mediaPath'] ?? '') : (el['link'] ?? '');
      if (src_val.isEmpty) return const SizedBox();
      if (src == 'gallery') {
        return Padding(padding: const EdgeInsets.only(bottom: 16), child: _AudioPlayerWidget(path: src_val));
      } else {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _handleAction('play_audio', src_val, targetPage),
              borderRadius: BorderRadius.circular(15),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50, height: 50,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.music_note, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('پخش موزیک', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 3),
                          Text(src_val, style: const TextStyle(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const Icon(Icons.open_in_new, size: 18, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }
    if (type == 'slider') {
      final images = List<String>.from(el['images'] ?? []);
      if (images.isEmpty) return const SizedBox();
      final PageController controller = PageController();
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            SizedBox(
              height: 220,
              child: PageView.builder(
                controller: controller,
                itemCount: images.length,
                itemBuilder: (c, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.file(File(images[i]), fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300, child: const Icon(Icons.broken_image))),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 8, height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF6A11CB).withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              )),
            ),
          ],
        ),
      );
    }
    if (type == 'banner') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          width: double.infinity,
          height: 70,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.grey.withOpacity(0.15), Colors.grey.withOpacity(0.05)]),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.withOpacity(0.3), style: BorderStyle.solid, width: 1.5),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.campaign, color: Colors.grey[600], size: 24),
                const SizedBox(height: 2),
                Text('جایگاه تبلیغ بنری', style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      );
    }
    if (type == 'nextpage') {
      final pages = (_app['pages'] as List? ?? []);
      final targetPageName = (targetPage >= 0 && targetPage < pages.length) ? pages[targetPage]['name'] : null;
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _goToPage(targetPage),
            icon: const Icon(Icons.arrow_forward),
            label: Text(targetPageName != null ? 'برو به $targetPageName' : 'صفحه بعد', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(el['color'] ?? 0xFF6A11CB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 4,
            ),
          ),
        ),
      );
    }
    return const SizedBox();
  }
  Widget _buildPageContent(Map<String, dynamic> page, int pageIndex) {
    final elements = (page['elements'] as List? ?? []);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          page['name'] ?? '',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(_app['themeColor'] ?? 0xFF6A11CB)),
        ),
        const SizedBox(height: 22),
        ...elements.map((e) => _buildElement(e as Map<String, dynamic>)),
      ],
    );
  }
  Widget? _buildBottomNav() {
    final items = (_app['bottomMenu'] as List? ?? []);
    final pages = (_app['pages'] as List? ?? []);
    if (items.length < 2 || pages.isEmpty) return null;
    final validIndex = _currentPageIndex < items.length ? _currentPageIndex : 0;
    return NavigationBar(
      height: 68,
      selectedIndex: validIndex.clamp(0, items.length - 1),
      onDestinationSelected: (i) {
        final item = items[i];
        final pageIndex = item['pageIndex'] ?? 0;
        _goToPage(pageIndex);
      },
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A1A1A) : Colors.white,
      indicatorColor: Color(_app['themeColor'] ?? 0xFF6A11CB).withOpacity(0.15),
      destinations: items.map<Widget>((item) {
        Widget iconWidget;
        if (item['iconType'] == 'gallery' && (item['iconPath'] ?? '').isNotEmpty) {
          iconWidget = ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.file(File(item['iconPath']), width: 24, height: 24, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.circle)));
        } else {
          final idx = (item['iconIndex'] ?? 0) as int;
          final icon = (idx >= 0 && idx < availableIcons.length) ? availableIcons[idx]['icon'] as IconData : Icons.circle;
          iconWidget = Icon(icon);
        }
        return NavigationDestination(icon: iconWidget, selectedIcon: iconWidget, label: item['label'] ?? '');
      }).toList(),
    );
  }
  Widget? _buildDrawer() {
    final items = (_app['drawerMenu'] as List? ?? []);
    final pages = (_app['pages'] as List? ?? []);
    if (items.isEmpty || pages.isEmpty) return null;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Color(_app['themeColor'] ?? 0xFF6A11CB), Color.lerp(Color(_app['themeColor'] ?? 0xFF6A11CB), Colors.blue, 0.5)!]),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, spreadRadius: 5)],
                    ),
                    child: Icon(Icons.apps, size: 40, color: Color(_app['themeColor'] ?? 0xFF6A11CB)),
                  ),
                  const SizedBox(height: 12),
                  Text(_app['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          ...items.map<Widget>((item) {
            Widget leadingWidget;
            if (item['iconType'] == 'gallery' && (item['iconPath'] ?? '').isNotEmpty) {
              leadingWidget = ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(item['iconPath']), width: 30, height: 30, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.circle)));
            } else {
              final idx = (item['iconIndex'] ?? 0) as int;
              final icon = (idx >= 0 && idx < availableIcons.length) ? availableIcons[idx]['icon'] as IconData : Icons.circle;
              leadingWidget = Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(_app['themeColor'] ?? 0xFF6A11CB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Color(_app['themeColor'] ?? 0xFF6A11CB), size: 22),
              );
            }
            return ListTile(
              leading: leadingWidget,
              title: Text(item['label'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                _goToPage(item['pageIndex'] ?? 0);
              },
            );
          }),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    if (_app['appType'] == 'wallpaper') {
      final wps = List<String>.from(_app['wallpapers'] ?? []);
      return Scaffold(
        appBar: AppBar(
          title: Text(_app['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Color(_app['themeColor'] ?? 0xFF6A11CB),
          foregroundColor: Colors.white,
        ),
        body: wps.isEmpty ? const Center(child: Text('والپیپری اضافه نشده')) : PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: wps.length,
          itemBuilder: (c, i) => Stack(
            fit: StackFit.expand,
            children: [
              Image.file(File(wps[i]), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image))),
              Positioned(
                bottom: 30, right: 20,
                child: FloatingActionButton(
                  heroTag: 'dl_$i',
                  backgroundColor: Colors.white,
                  onPressed: () => _downloadWallpaper(context, wps[i], i + 1),
                  child: const Icon(Icons.download, color: Color(0xFF6A11CB)),
                ),
              ),
            ],
          ),
        ),
      );
    }
    final pages = (_app['pages'] as List? ?? []);
    if (pages.isEmpty) {
      return Scaffold(appBar: AppBar(title: Text(_app['name'] ?? '')), body: const Center(child: Text('صفحه ای نساخته نشده')));
    }
    if (_showSplash) {
      return Scaffold(body: _buildSplash());
    }
    if (_currentPageIndex >= pages.length) _currentPageIndex = 0;
    return Scaffold(
      appBar: AppBar(
        title: Text(pages[_currentPageIndex]['name'] ?? _app['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(_app['themeColor'] ?? 0xFF6A11CB),
        foregroundColor: Colors.white,
      ),
      drawer: _buildDrawer(),
      body: _buildPageContent(pages[_currentPageIndex] as Map<String, dynamic>, _currentPageIndex),
      bottomNavigationBar: _buildBottomNav(),
    );
  }
}

class _VideoPlayerWidget extends StatefulWidget {
  final String path;
  const _VideoPlayerWidget({required this.path});
  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}
class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _error = false;
  @override
  void initState() {
    super.initState();
    _init();
  }
  Future<void> _init() async {
    try {
      _controller = VideoPlayerController.file(File(widget.path));
      await _controller!.initialize();
      if (mounted) setState(() => _initialized = true);
    } catch (e) {
      if (mounted) setState(() => _error = true);
    }
  }
  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    if (_error) {
      return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(15)), child: const Text('خطا در بارگذاری فیلم'));
    }
    if (!_initialized) {
      return Container(padding: const EdgeInsets.all(30), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(15)), child: const Center(child: CircularProgressIndicator(color: Color(0xFF6A11CB))));
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_controller!),
            Container(color: Colors.black.withOpacity(0.1)),
            IconButton(
              icon: Icon(_controller!.value.isPlaying ? Icons.pause_circle : Icons.play_circle, color: Colors.white, size: 70, shadows: [Shadow(color: Colors.black, blurRadius: 10)] as List<Shadow>),
              onPressed: () {
                setState(() {
                  _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AudioPlayerWidget extends StatefulWidget {
  final String path;
  const _AudioPlayerWidget({required this.path});
  @override
  State<_AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}
class _AudioPlayerWidgetState extends State<_AudioPlayerWidget> {
  final AudioPlayer _player = AudioPlayer();
  bool _playing = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  @override
  void initState() {
    super.initState();
    _init();
  }
  Future<void> _init() async {
    try {
      await _player.setSourceDeviceFile(widget.path);
      _player.onDurationChanged.listen((d) { if (mounted) setState(() => _duration = d); });
      _player.onPositionChanged.listen((p) { if (mounted) setState(() => _position = p); });
      _player.onPlayerComplete.listen((_) { if (mounted) setState(() { _playing = false; _position = Duration.zero; }); });
    } catch (e) {}
  }
  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              if (_playing) {
                await _player.pause();
              } else {
                await _player.resume();
              }
              setState(() => _playing = !_playing);
            },
            child: Container(
              width: 55, height: 55,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
                shape: BoxShape.circle,
              ),
              child: Icon(_playing ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 30),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Slider(
                  value: _duration.inSeconds > 0 ? _position.inSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble()) : 0,
                  max: _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 1,
                  activeColor: const Color(0xFF6A11CB),
                  onChanged: (v) async { await _player.seek(Duration(seconds: v.toInt())); },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_fmt(_position), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    Text(_fmt(_duration), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _backupApps(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final appsList = prefs.getStringList('my_apps') ?? [];
      if (appsList.isEmpty) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('هنوز اپی نساخته‌اید!'), backgroundColor: Colors.orange));
        return;
      }
      final now = DateTime.now();
      final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final timeStr = '${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}';
      final backupData = {
        'app': 'AppLand',
        'version': '1.0.0',
        'date': '$dateStr $timeStr',
        'appsCount': appsList.length,
        'apps': appsList.map((e) => jsonDecode(e)).toList(),
      };
      final content = jsonEncode(backupData);
      final dir = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${dir.path}/AppLand_Backups');
      if (!await backupDir.exists()) { await backupDir.create(recursive: true); }
      final fileName = 'appland_backup_${dateStr}_$timeStr.json';
      final file = File('${backupDir.path}/$fileName');
      await file.writeAsString(content, encoding: utf8);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('پشتیبان ساخته شد: $fileName'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: 'اشتراک‌گذاری',
            textColor: Colors.white,
            onPressed: () async {
              await Share.shareXFiles([XFile(file.path)], subject: 'پشتیبان اپ‌لند', text: 'پشتیبان اپ‌های من در اپ‌لند');
            },
          ),
        ));
      }
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا در پشتیبان‌گیری: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _restoreApps(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: false);
      if (result == null || result.files.single.path == null) return;
      final file = File(result.files.single.path!);
      final content = await file.readAsString(encoding: utf8);
      final data = jsonDecode(content) as Map<String, dynamic>;
      if (data['app'] != 'AppLand' || data['apps'] == null) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فایل پشتیبان معتبر نیست!'), backgroundColor: Colors.red));
        return;
      }
      final apps = (data['apps'] as List).cast<Map<String, dynamic>>();
      final appsCount = apps.length;
      if (context.mounted) {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Row(children: [Icon(Icons.restore, color: Color(0xFF6A11CB)), SizedBox(width: 10), Text('بازیابی پشتیبان')]),
            content: Text('تعداد $appsCount اپ پیدا شد.\n\nآیا می‌خواهید اضافه شوند؟'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('لغو')),
              ElevatedButton(onPressed: () => Navigator.pop(c, true), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A11CB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('بازیابی')),
            ],
          ),
        );
        if (confirm != true) return;
      }
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getStringList('my_apps') ?? [];
      int addedCount = 0;
      for (final app in apps) {
        final encoded = jsonEncode(app);
        if (!existing.contains(encoded)) { existing.add(encoded); addedCount++; }
      }
      await prefs.setStringList('my_apps', existing);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$addedCount اپ بازیابی شد!'), backgroundColor: Colors.green, duration: const Duration(seconds: 4)));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا در بازیابی: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _buyLifetime(BuildContext context) async {
    if (proStatus.isPro) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('شما نسخه دائمی دارید!'), backgroundColor: Colors.green));
      return;
    }
    if (bazaarRsaKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('کلید RSA تنظیم نشده!'), backgroundColor: Colors.red));
      return;
    }
    try {
      await FlutterPoolakey.connect(
        bazaarRsaKey,
        onSucceed: () async {
          try {
            final response = await FlutterPoolakey.purchase('Appland_daemi', payload: 'lifetime');
            if (response != null) {
              await proStatus.setPro(true);
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('نسخه دائمی فعال شد!'), backgroundColor: Colors.green));
            }
          } catch (e) {}
        },
        onFailed: () {},
        onDisconnected: () {},
      );
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تنظیمات', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF6A11CB),
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]))),
      ),
      body: AnimatedBuilder(animation: themeNotifier, builder: (context, _) => ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 4))]),
          child: Column(children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFF6A11CB).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.dark_mode, color: Color(0xFF6A11CB), size: 24),
              ),
              const SizedBox(width: 14),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('حالت تاریک', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                SizedBox(height: 3),
                Text('تغییر تم اپ', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ])),
              Switch(value: themeNotifier.isDark, activeColor: const Color(0xFF6A11CB), onChanged: (v) => themeNotifier.toggleTheme()),
            ]),
          ]),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 4))]),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.language, color: Colors.blue, size: 24)),
            const SizedBox(width: 14),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('زبان', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              SizedBox(height: 3),
              Text('فارسی', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ])),
          ]),
        ),
        const SizedBox(height: 12),
        _buildActionTile(icon: Icons.backup, color: Colors.green, title: 'پشتیبان‌گیری از اپ‌ها', subtitle: 'ذخیره همه اپ‌ها توی یه فایل', onTap: () => _backupApps(context)),
        const SizedBox(height: 12),
        _buildActionTile(icon: Icons.restore, color: Colors.orange, title: 'بازیابی از پشتیبان', subtitle: 'برگرداندن اپ‌ها از فایل پشتیبان', onTap: () => _restoreApps(context)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 6))],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _buyLifetime(context),
              borderRadius: BorderRadius.circular(20),
              child: Row(children: [
                const Icon(Icons.workspace_premium, color: Colors.white, size: 42),
                const SizedBox(width: 14),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('خرید نسخه دائمی', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('۹۹۹,۰۰۰ تومان - همه اپ ها رایگان', style: TextStyle(color: Colors.white, fontSize: 12)),
                ])),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                ),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildActionTile(icon: Icons.info, color: const Color(0xFF6A11CB), title: 'درباره اپ لند', subtitle: 'اطلاعات و امکانات اپ', onTap: () => showAboutDialog(
          context: context,
          applicationName: 'اپ لند',
          applicationVersion: '1.0.0',
          children: const [
            Text('با اپ لند بدون کدنویسی، اپ اندروید بسازید!'),
            SizedBox(height: 8),
            Text('امکانات: ساخت اپ (محتوا محور/والپیپر)، صفحه ساز، تبلیغات، پرداخت درون برنامه ای، تم پیشرفته، فونت دلخواه و...'),
          ],
        )),
        const SizedBox(height: 30),
        Center(
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF6A11CB).withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.apps, color: Color(0xFF6A11CB), size: 40),
            ),
            const SizedBox(height: 10),
            const Text('اپ لند', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF6A11CB))),
            const SizedBox(height: 4),
            const Text('نسخه ۱.۰.۰', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ]),
        ),
        const SizedBox(height: 20),
      ])),
    );
  }
  Widget _buildActionTile({required IconData icon, required Color color, required String title, required String subtitle, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 4))]),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ])),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ]),
          ),
        ),
      ),
    );
  }
}