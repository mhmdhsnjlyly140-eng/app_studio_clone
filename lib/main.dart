import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_poolakey/flutter_poolakey.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
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
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6A11CB), brightness: Brightness.dark),
          useMaterial3: true,
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
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
        ),
      ),
      child: Center(child: FadeTransition(opacity: _f, child: ScaleTransition(scale: _s, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 150, height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 40, spreadRadius: 15)],
          ),
          child: const Icon(Icons.apps, size: 90, color: Color(0xFF6A11CB)),
        ),
        const SizedBox(height: 40),
        const Text('اپ لند', style: TextStyle(fontSize: 52, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 4)),
        const SizedBox(height: 15),
        const Text('سرزمین اپ های تو', style: TextStyle(fontSize: 20, color: Colors.white70, letterSpacing: 2)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [Icon(Icons.school, color: Color(0xFF6A11CB)), SizedBox(width: 10), Text('به اپ لند خوش آمدید!')]),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('با اپ لند می تونید بدون کدنویسی، اپ اندروید بسازید!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              SizedBox(height: 16),
              Text('۱. صفحه خانه:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('شروع اپ، مرکز آموزش و پشتیبانی.', style: TextStyle(fontSize: 13)),
              SizedBox(height: 12),
              Text('۲. اپ های من:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('لیست اپ هایی که ساختید.', style: TextStyle(fontSize: 13)),
              SizedBox(height: 12),
              Text('۳. ساخت اپ:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('اطلاعات اپ (اسم، رنگ، آیکون، پکیج) رو وارد کنید.', style: TextStyle(fontSize: 13)),
              SizedBox(height: 12),
              Text('۴. صفحه ساز:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('از داخل ویرایش اپ، صفحات و المان ها رو بسازید.', style: TextStyle(fontSize: 13)),
              SizedBox(height: 12),
              Text('۵. تبلیغات و پرداخت (برای هر اپ):', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('با ۱۹۹,۰۰۰ تومان، تبلیغات و پرداخت هر اپ فعال میشه.', style: TextStyle(fontSize: 13)),
              SizedBox(height: 12),
              Text('۶. نسخه دائمی اپ لند:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('با ۹۹۹,۰۰۰ تومان، همه اپ ها رایگان میشن.', style: TextStyle(fontSize: 13)),
              SizedBox(height: 12),
              Text('۷. پشتیبان‌گیری:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('از تنظیمات، می تونید از اپ هاتون بکاپ بگیرید.', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('onboarding_seen', true);
              if (mounted) Navigator.pop(c);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A11CB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text('متوجه شدم'),
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
      body: pages[_i],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: NavigationBar(
          selectedIndex: _i,
          onDestinationSelected: (i) => setState(() => _i = i),
          backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
          indicatorColor: const Color(0xFF6A11CB).withOpacity(0.15),
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
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
        ),
      ),
      child: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(children: [
        const SizedBox(height: 40),
        Container(
          width: 130, height: 130,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 30, spreadRadius: 10)],
          ),
          child: const Icon(Icons.apps, size: 75, color: Color(0xFF6A11CB)),
        ),
        const SizedBox(height: 35),
        const Text('اپ لند', style: TextStyle(fontSize: 52, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 3)),
        const SizedBox(height: 12),
        const Text('سرزمین اپ های تو', style: TextStyle(fontSize: 20, color: Colors.white70)),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'با اپ لند بدون کدنویسی، اپ اندروید بسازید! کافیه اسم، رنگ، آیکون و صفحات اپتون رو انتخاب کنید.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ),
        const SizedBox(height: 40),
        _buildButton(context, 'شروع کنید', Icons.play_arrow, onStart, true),
        const SizedBox(height: 16),
        _buildButton(context, 'مرکز آموزش ساخت اپ', Icons.school, () => _openRubika(context, 'https://rubikabot.ir/Appland_ir'), false),
        const SizedBox(height: 16),
        _buildButton(context, 'پشتیبانی', Icons.support_agent, () => _openRubika(context, 'https://rubikabot.ir/support_1i'), false),
        const SizedBox(height: 40),
        const Text('نسخه ۱.۰.۰', style: TextStyle(fontSize: 14, color: Colors.white54)),
        const SizedBox(height: 20),
      ]))),
    );
  }
  Widget _buildButton(BuildContext context, String text, IconData icon, VoidCallback onTap, bool primary) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 28),
        label: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: primary ? Colors.white : Colors.white.withOpacity(0.2),
          foregroundColor: primary ? const Color(0xFF6A11CB) : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: primary ? BorderSide.none : const BorderSide(color: Colors.white, width: 2),
          ),
          elevation: primary ? 8 : 0,
        ),
      ),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(children: [Icon(Icons.warning, color: Colors.red), SizedBox(width: 10), Text('حذف اپ')]),
      content: const Text('مطمئنی می خوای این اپ رو حذف کنی؟'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('لغو')),
        ElevatedButton(onPressed: () => Navigator.pop(c, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), child: const Text('حذف')),
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
  void _showDetails(int i) {
    final app = _filtered[i];
    showDialog(context: context, builder: (c) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(app['name'] ?? ''),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        _detailRow('پکیج', app['packageName'] ?? ''),
        _detailRow('نوع', app['appType'] == 'content' ? 'محتوا محور' : 'والپیپر'),
        _detailRow('تعداد صفحات', '${(app['pages'] as List? ?? []).length}'),
        _detailRow('وضعیت پرو', app['isPro'] == true ? 'پرو' : (proStatus.isPro ? 'پرو (دائمی)' : 'رایگان')),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('بستن'))],
    ));
  }
  Widget _detailRow(String label, String value) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
      Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      Expanded(child: Text(value, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13))),
    ]));
  }
  Future<void> _support(int i) async {
    final app = _filtered[i];
    await showDialog<String>(context: context, builder: (c) {
      final ctrl = TextEditingController();
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [Icon(Icons.favorite, color: Colors.pink), SizedBox(width: 10), Text('پشتیبانی از پروژه')]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('از اپ "${app['name']}" حمایت کن'),
          const SizedBox(height: 12),
          TextField(controller: ctrl, maxLines: 3, decoration: const InputDecoration(hintText: 'پیام شما (اختیاری)', border: OutlineInputBorder())),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('لغو')),
          ElevatedButton(onPressed: () => Navigator.pop(c), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A11CB)), child: const Text('ارسال')),
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
        onFailed: () {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اتصال برقرار نشد'), backgroundColor: Colors.red));
        },
        onDisconnected: () {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اتصال قطع شد'), backgroundColor: Colors.red));
        },
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
        title: const Text('اپ های من'),
        backgroundColor: const Color(0xFF6A11CB),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _l ? const Center(child: CircularProgressIndicator())
        : _apps.isEmpty ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.apps, size: 100, color: isDark ? Colors.grey[700] : Colors.grey[300]),
            const SizedBox(height: 24),
            Text('هنوز اپی نساخته اید', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.grey[400] : Colors.grey[600])),
            const SizedBox(height: 12),
            Text('از تب «ساخت اپ» شروع کنید', style: TextStyle(fontSize: 15, color: isDark ? Colors.grey[500] : Colors.grey[500])),
          ]))
        : Column(children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _filter,
                decoration: InputDecoration(
                  hintText: 'جستجو در اپ ها...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  filled: true,
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
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: Container(
                            width: 60, height: 60,
                            decoration: BoxDecoration(
                              color: Color(app['color'] ?? 0xFF6A11CB),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Color(app['color'] ?? 0xFF6A11CB).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 3))],
                            ),
                            child: Icon(isPro ? Icons.verified : Icons.apps, color: Colors.white, size: 32),
                          ),
                          title: Row(children: [
                            Text(app['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                            if (isPro) const Padding(padding: EdgeInsets.only(right: 8), child: Icon(Icons.star, color: Colors.amber, size: 18)),
                          ]),
                          subtitle: Text('${(app['pages'] as List? ?? []).length} صفحه • ${app['appType'] == 'content' ? 'محتوا محور' : 'والپیپر'}${isPro ? ' • پرو' : ''}', style: const TextStyle(fontSize: 13)),
                          trailing: PopupMenuButton<String>(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            onSelected: (v) {
                              if (v == 'del') _del(i);
                              else if (v == 'details') _showDetails(i);
                              else if (v == 'support') _support(i);
                              else if (v == 'edit') _edit(i);
                              else if (v == 'buy') _buyProForApp(i);
                            },
                            itemBuilder: (c) => [
                              const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.build, color: Color(0xFF6A11CB)), SizedBox(width: 10), Text('ویرایش')])),
                              if (!isPro)
                                const PopupMenuItem(value: 'buy', child: Row(children: [Icon(Icons.star, color: Colors.amber), SizedBox(width: 10), Text('خرید پرو (۱۹۹,۰۰۰)')])),
                              const PopupMenuItem(value: 'details', child: Row(children: [Icon(Icons.info, color: Colors.blue), SizedBox(width: 10), Text('جزئیات')])),
                              const PopupMenuItem(value: 'support', child: Row(children: [Icon(Icons.favorite, color: Colors.pink), SizedBox(width: 10), Text('پشتیبانی')])),
                              const PopupMenuItem(value: 'del', child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 10), Text('حذف')])),
                            ],
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
  final _colors = [const Color(0xFF6A11CB), const Color(0xFF2575FC), const Color(0xFFFF6B6B), const Color(0xFF4ECDC4), const Color(0xFFFFA500), const Color(0xFF9B59B6)];
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
      appBar: AppBar(title: const Text('ساخت اپ جدید'), backgroundColor: const Color(0xFF6A11CB), foregroundColor: Colors.white, elevation: 0),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _buildField('نام اپ', _name, 'فروشگاه من', Icons.apps),
        const SizedBox(height: 20),
        _buildField('پیام خوش آمدگویی', _welcome, 'به فروشگاه من خوش آمدید', Icons.message),
        const SizedBox(height: 20),
        _buildField('نام پکیج', _pkg, 'ir.appland.myapp', Icons.code),
        const SizedBox(height: 20),
        const Text('نوع اپ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade300)),
          child: Column(children: [
            RadioListTile<String>(value: 'content', groupValue: _type, onChanged: (v) => setState(() => _type = v!), title: const Text('محتوا محور'), subtitle: const Text('صفحات دلخواه')),
            RadioListTile<String>(value: 'wallpaper', groupValue: _type, onChanged: (v) => setState(() => _type = v!), title: const Text('والپیپر'), subtitle: const Text('گالری پس زمینه')),
          ]),
        ),
        const SizedBox(height: 20),
        const Text('به زودی:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('به زودی! در نظرات درخواست کنید'))),
            icon: const Icon(Icons.language),
            label: const Text('ساخت وب'),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
          )),
          const SizedBox(width: 10),
          Expanded(child: OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('به زودی! در نظرات درخواست کنید'))),
            icon: const Icon(Icons.games),
            label: const Text('بازی'),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
          )),
        ]),
        const SizedBox(height: 25),
        const Text('رنگ اپ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12, runSpacing: 12,
          children: _colors.map((c) => GestureDetector(
            onTap: () => setState(() => _color = c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 55, height: 55,
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: Border.all(color: _color == c ? Colors.black : Colors.transparent, width: 4),
                boxShadow: _color == c ? [BoxShadow(color: c.withOpacity(0.5), blurRadius: 15, spreadRadius: 3)] : [],
              ),
              child: _color == c ? const Icon(Icons.check, color: Colors.white, size: 30) : null,
            ),
          )).toList(),
        ),
        const SizedBox(height: 35),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: _color, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 8, shadowColor: _color.withOpacity(0.5),
          ),
          child: const Text('ساخت اپ', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 20),
      ])),
    );
  }
  Widget _buildField(String label, TextEditingController ctrl, String hint, IconData icon) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      TextField(controller: ctrl, decoration: InputDecoration(hintText: hint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)), prefixIcon: Icon(icon))),
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
  final _adiveryCtrl = TextEditingController();
  final _tapsellCtrl = TextEditingController();
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final a = p.getStringList('my_apps') ?? [];
    if (widget.appIndex < a.length) {
      setState(() {
        _app = jsonDecode(a[widget.appIndex]) as Map<String, dynamic>;
        _rsaCtrl.text = _app!['rsaKey'] ?? '';
        _adiveryCtrl.text = _app!['adiveryKey'] ?? '';
        _tapsellCtrl.text = _app!['tapsellKey'] ?? '';
      });
    }
  }
  Future<void> _save() async {
    if (_app == null) return;
    _app!['rsaKey'] = _rsaCtrl.text.trim();
    _app!['adiveryKey'] = _adiveryCtrl.text.trim();
    _app!['tapsellKey'] = _tapsellCtrl.text.trim();
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
          title: Text(_app!['name'] ?? ''),
          backgroundColor: const Color(0xFF6A11CB),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
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
        _card(Icons.wallpaper, 'گالری والپیپر', 'افزودن عکس های پس زمینه', () => _editWallpapers())
      else
        _card(Icons.pages, 'صفحات اپ', 'ساخت و ویرایش صفحات', () => _editPages(pages)),
      _card(Icons.preview, 'پیش نمایش', 'مشاهده پیش نمایش اپ', () => Navigator.push(context, MaterialPageRoute(builder: (_) => PreviewPage(app: _app!)))),
      _card(Icons.android, 'خروجی APK', 'به زودی', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('به زودی! در نظرات درخواست کنید')))),
      _card(Icons.wallpaper, 'Splash Screen', 'عکس + متن + مدت زمان', _splashDialog),
      _card(Icons.navigation, 'منوی پایین', 'ناوبری پایین اپ (حداکثر ۴)', _bottomMenuDialog),
      _card(Icons.menu, 'منوی کشویی', 'منوی کناری اپ', _drawerMenuDialog),
      _card(Icons.palette, 'حالت پیشرفته تم', 'رنگ و فونت اپ', _themeDialog),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('حالت پیشرفته تم'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('رنگ اصلی اپ:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: [
                Colors.deepPurple, Colors.blue, Colors.red, Colors.teal, Colors.orange, Colors.purple,
              ].map((c) => GestureDetector(
                onTap: () => setState(() => _app!['themeColor'] = c.value),
                child: Container(width: 40, height: 40, decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: (_app!['themeColor'] ?? 0) == c.value ? Colors.black : Colors.transparent, width: 3))),
              )).toList(),
            ),
            const SizedBox(height: 16),
            const Text('فونت اپ:'),
            const SizedBox(height: 8),
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
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A11CB)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(children: [
            Icon(Icons.wallpaper, color: Color(0xFF6A11CB)),
            SizedBox(width: 10),
            Text('طراحی اسپلش'),
          ]),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('متن اسپلش:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: textCtrl,
                  decoration: const InputDecoration(
                    hintText: 'به اپ من خوش آمدید',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('عکس اسپلش:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                if (imagePath.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(imagePath),
                      width: double.infinity,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                    ),
                  ),
                const SizedBox(height: 6),
                Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final img = await picker.pickImage(source: ImageSource.gallery);
                        if (img != null) {
                          setStateDialog(() => imagePath = img.path);
                        }
                      },
                      icon: const Icon(Icons.image),
                      label: const Text('انتخاب عکس'),
                    ),
                  ),
                  if (imagePath.isNotEmpty)
                    IconButton(
                      onPressed: () => setStateDialog(() => imagePath = ''),
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                ]),
                const SizedBox(height: 16),
                const Text('رنگ پس‌زمینه:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Colors.deepPurple,
                    Colors.blue,
                    Colors.red,
                    Colors.teal,
                    Colors.orange,
                    Colors.purple,
                    Colors.pink,
                    Colors.green,
                    Colors.black,
                    Colors.white,
                  ].map((color) => GestureDetector(
                    onTap: () => setStateDialog(() => selectedColor = color),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedColor == color ? Colors.blue : Colors.grey.shade300,
                          width: selectedColor == color ? 3 : 1,
                        ),
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                Text('مدت زمان: ${duration.toInt()} ثانیه', style: const TextStyle(fontWeight: FontWeight.bold)),
                Slider(
                  value: duration,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: '${duration.toInt()}',
                  activeColor: const Color(0xFF6A11CB),
                  onChanged: (v) => setStateDialog(() => duration = v),
                ),
                const SizedBox(height: 8),
                const Text('صفحه بعد از اسپلش:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                DropdownButton<int>(
                  value: targetPage,
                  isExpanded: true,
                  items: [
                    for (int i = 0; i < (_app!['pages'] as List? ?? []).length; i++)
                      DropdownMenuItem(
                        value: i,
                        child: Text((_app!['pages'] as List)[i]['name'] ?? 'صفحه ${i + 1}'),
                      ),
                  ],
                  onChanged: (v) => setStateDialog(() => targetPage = v ?? 0),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('لغو', style: TextStyle(color: Colors.red)),
            ),
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
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A11CB)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(children: [
            Icon(Icons.navigation, color: Color(0xFF6A11CB)),
            SizedBox(width: 10),
            Text('منوی پایین'),
          ]),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('حداکثر ۴ آیتم (${items.length}/۴)', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 12),
                if (pages.isEmpty)
                  const Text('اول باید حداقل یه صفحه بسازی!', style: TextStyle(color: Colors.red)),
                for (int i = 0; i < items.length; i++) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                            child: Text(items[i]['label'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18, color: Color(0xFF6A11CB)),
                            onPressed: () async {
                              final result = await _editMenuItem(items[i], pages);
                              if (result != null) {
                                setStateDialog(() => items[i] = result);
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                            onPressed: () => setStateDialog(() => items.removeAt(i)),
                          ),
                        ]),
                        Text('مقصد: ${items[i]['pageIndex'] != null && items[i]['pageIndex'] < pages.length ? pages[items[i]['pageIndex']]['name'] : 'نامشخص'}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
                if (items.length < 4 && pages.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () async {
                      final result = await _editMenuItem({
                        'label': '',
                        'iconType': 'builtin',
                        'iconIndex': 0,
                        'iconPath': '',
                        'pageIndex': 0,
                      }, pages);
                      if (result != null) {
                        setStateDialog(() => items.add(result));
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('افزودن آیتم'),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('لغو', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () async {
                _app!['bottomMenu'] = items;
                await _save();
                if (mounted) Navigator.pop(c);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A11CB)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(children: [
            Icon(Icons.menu, color: Color(0xFF6A11CB)),
            SizedBox(width: 10),
            Text('منوی کشویی'),
          ]),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${items.length} آیتم', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 12),
                if (pages.isEmpty)
                  const Text('اول باید حداقل یه صفحه بسازی!', style: TextStyle(color: Colors.red)),
                for (int i = 0; i < items.length; i++) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                            child: Text(items[i]['label'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18, color: Color(0xFF6A11CB)),
                            onPressed: () async {
                              final result = await _editMenuItem(items[i], pages);
                              if (result != null) {
                                setStateDialog(() => items[i] = result);
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                            onPressed: () => setStateDialog(() => items.removeAt(i)),
                          ),
                        ]),
                        Text('مقصد: ${items[i]['pageIndex'] != null && items[i]['pageIndex'] < pages.length ? pages[items[i]['pageIndex']]['name'] : 'نامشخص'}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
                if (pages.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () async {
                      final result = await _editMenuItem({
                        'label': '',
                        'iconType': 'builtin',
                        'iconIndex': 0,
                        'iconPath': '',
                        'pageIndex': 0,
                      }, pages);
                      if (result != null) {
                        setStateDialog(() => items.add(result));
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('افزودن آیتم'),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('لغو', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () async {
                _app!['drawerMenu'] = items;
                await _save();
                if (mounted) Navigator.pop(c);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A11CB)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('ویرایش آیتم'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('نام آیتم:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: labelCtrl,
                  decoration: const InputDecoration(hintText: 'مثلا: خانه', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                const Text('آیکون:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Row(children: [
                  ChoiceChip(
                    label: const Text('آماده'),
                    selected: iconType == 'builtin',
                    onSelected: (v) => setStateDialog(() => iconType = 'builtin'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('گالری'),
                    selected: iconType == 'gallery',
                    onSelected: (v) => setStateDialog(() => iconType = 'gallery'),
                  ),
                ]),
                const SizedBox(height: 8),
                if (iconType == 'builtin')
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (int i = 0; i < availableIcons.length; i++)
                        GestureDetector(
                          onTap: () => setStateDialog(() => iconIndex = i),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: iconIndex == i ? const Color(0xFF6A11CB).withOpacity(0.2) : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: iconIndex == i ? const Color(0xFF6A11CB) : Colors.transparent, width: 2),
                            ),
                            child: Icon(availableIcons[i]['icon'], color: const Color(0xFF6A11CB), size: 22),
                          ),
                        ),
                    ],
                  )
                else ...[
                  if (iconPath.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(File(iconPath), width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)),
                    ),
                  const SizedBox(height: 6),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picker = ImagePicker();
                      final img = await picker.pickImage(source: ImageSource.gallery);
                      if (img != null) {
                        setStateDialog(() => iconPath = img.path);
                      }
                    },
                    icon: const Icon(Icons.image),
                    label: const Text('انتخاب از گالری'),
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
              onPressed: () {
                Navigator.pop(c, {
                  'label': labelCtrl.text,
                  'iconType': iconType,
                  'iconIndex': iconIndex,
                  'iconPath': iconPath,
                  'pageIndex': pageIndex,
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A11CB)),
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
    return ListView(padding: const EdgeInsets.all(16), children: [
      _field('کلید ادیوری', _app!['adiveryKey'] ?? '', (v) => _app!['adiveryKey'] = v),
      const SizedBox(height: 16),
      _field('کلید تپسل', _app!['tapsellKey'] ?? '', (v) => _app!['tapsellKey'] = v),
      const SizedBox(height: 24),
      _saveBtn(),
    ]);
  }
  Widget _payTab() {
    if (!_hasAccess) {
      return _lockedTab('پرداخت', 'برای فعال سازی پرداخت درون برنامه ای، این اپ رو با قیمت ۱۹۹,۰۰۰ تومان پرو کنید.', Icons.payment);
    }
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('کلید RSA (کافه بازار)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      TextField(controller: _rsaCtrl, maxLines: 5, decoration: InputDecoration(hintText: 'MII...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)), prefixIcon: const Icon(Icons.vpn_key))),
      const SizedBox(height: 24),
      _saveBtn(),
    ]);
  }
  Widget _setTab() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      ListTile(leading: const Icon(Icons.edit, color: Color(0xFF6A11CB)), title: const Text('تغییر نام'), subtitle: Text(_app!['name'] ?? ''), onTap: _changeName),
      const Divider(),
      ListTile(leading: const Icon(Icons.code, color: Color(0xFF6A11CB)), title: const Text('نام پکیج'), subtitle: Text(_app!['packageName'] ?? '')),
    ]);
  }
  Widget _field(String label, String value, Function(String) onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      TextField(controller: TextEditingController(text: value), onChanged: onChanged, decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))),
    ]);
  }
  Widget _saveBtn() {
    return ElevatedButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: const Text('ذخیره'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A11CB), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))));
  }
  Widget _lockedTab(String title, String message, IconData icon) {
    return Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.lock, size: 80, color: Colors.grey),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('خرید پرو این اپ'),
      content: const Text('برای فعال سازی تبلیغات و پرداخت این اپ، مبلغ ۱۹۹,۰۰۰ تومان پرداخت کنید.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('لغو')),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(c);
            await _purchaseThisApp();
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A11CB)),
          child: const Text('پرداخت'),
        ),
      ],
    ));
  }
  Future<void> _purchaseThisApp() async {
    if (proStatus.isPro) {
      setState(() => _app!['isPro'] = true);
      await _save();
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
            final response = await FlutterPoolakey.purchase('appland_pro', payload: 'app_pro');
            if (response != null) {
              setState(() => _app!['isPro'] = true);
              await _save();
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اپ پرو شد!'), backgroundColor: Colors.green));
            } else {
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('پرداخت انجام نشد!'), backgroundColor: Colors.orange));
            }
          } catch (e) {
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا: $e'), backgroundColor: Colors.red));
          }
        },
        onFailed: () {},
        onDisconnected: () {},
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا: $e'), backgroundColor: Colors.red));
    }
  }
  void _changeName() {
    final ctrl = TextEditingController(text: _app!['name'] ?? '');
    showDialog(context: context, builder: (c) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('تغییر نام'),
      content: TextField(controller: ctrl, decoration: const InputDecoration(border: OutlineInputBorder())),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('لغو')),
        ElevatedButton(onPressed: () async { _app!['name'] = ctrl.text; await _save(); if (mounted) Navigator.pop(c); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A11CB)), child: const Text('ذخیره')),
      ],
    ));
  }
  Widget _card(IconData icon, String title, String sub, VoidCallback onTap) {
    return Card(margin: const EdgeInsets.only(bottom: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(leading: Icon(icon, color: const Color(0xFF6A11CB), size: 32), title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), subtitle: Text(sub), trailing: const Icon(Icons.arrow_forward_ios, size: 16), onTap: onTap));
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
      appBar: AppBar(title: const Text('گالری والپیپر'), backgroundColor: const Color(0xFF6A11CB), foregroundColor: Colors.white),
      body: _wallpapers.isEmpty
        ? const Center(child: Text('هنوز عکسی اضافه نشده', style: TextStyle(fontSize: 16, color: Colors.grey)))
        : ListView.builder(padding: const EdgeInsets.all(16), itemCount: _wallpapers.length, itemBuilder: (c, i) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: Image.file(File(_wallpapers[i]), width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)),
              title: Text('عکس ${i + 1}'),
              trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async { setState(() => _wallpapers.removeAt(i)); await _save(); }),
            ),
          )),
      floatingActionButton: FloatingActionButton(onPressed: _pick, backgroundColor: const Color(0xFF6A11CB), child: const Icon(Icons.add, color: Colors.white)),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('صفحه جدید'),
      content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'نام صفحه', border: OutlineInputBorder())),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('لغو')),
        ElevatedButton(onPressed: () async { if (ctrl.text.isEmpty) return; setState(() => _pages.add({'name': ctrl.text, 'elements': []})); await _save(); if (mounted) Navigator.pop(c); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A11CB)), child: const Text('ساخت')),
      ],
    ));
  }
  void _edit(int i) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => PageEditorPage(appIndex: widget.appIndex, pageIndex: i))).then((_) => _load());
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('صفحات اپ'), backgroundColor: const Color(0xFF6A11CB), foregroundColor: Colors.white),
      body: _pages.isEmpty
        ? const Center(child: Text('هنوز صفحه ای نساخته اید', style: TextStyle(fontSize: 16, color: Colors.grey)))
        : ListView.builder(padding: const EdgeInsets.all(16), itemCount: _pages.length, itemBuilder: (c, i) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: const Color(0xFF6A11CB), child: Text('${i + 1}', style: const TextStyle(color: Colors.white))),
              title: Text(_pages[i]['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${(_pages[i]['elements'] as List? ?? []).length} المان'),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.edit, color: Color(0xFF6A11CB)), onPressed: () => _edit(i)),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async { setState(() => _pages.removeAt(i)); await _save(); }),
              ]),
            ),
          )),
      floatingActionButton: FloatingActionButton(onPressed: _add, backgroundColor: const Color(0xFF6A11CB), child: const Icon(Icons.add, color: Colors.white)),
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
    elements.add({'type': type, 'text': '', 'link': '', 'mediaPath': '', 'color': 0xFF6A11CB, 'textColor': 0xFFFFFFFF, 'items': [], 'targetPage': 0});
    _page!['elements'] = elements;
    setState(() {}); _save();
  }
  void _deleteElement(int i) { setState(() { final e = List.from(_page!['elements']); e.removeAt(i); _page!['elements'] = e; }); _save(); }
  void _moveElement(int i, int delta) { final e = List.from(_page!['elements']); if (i + delta < 0 || i + delta >= e.length) return; final t = e[i]; e[i] = e[i + delta]; e[i + delta] = t; setState(() => _page!['elements'] = e); _save(); }
  void _editElement(int i) {
    final el = Map<String, dynamic>.from(_page!['elements'][i]);
    final textCtrl = TextEditingController(text: el['text'] ?? '');
    final linkCtrl = TextEditingController(text: el['link'] ?? '');
    int targetPage = el['targetPage'] ?? 0;
    showDialog(context: context, builder: (c) => StatefulBuilder(
      builder: (context, setStateDialog) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('ویرایش ${_label(el['type'])}'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (el['type'] == 'text' || el['type'] == 'button')
              TextField(controller: textCtrl, decoration: const InputDecoration(labelText: 'متن', border: OutlineInputBorder())),
            if (el['type'] == 'button' || el['type'] == 'image' || el['type'] == 'video' || el['type'] == 'audio')
              TextField(controller: linkCtrl, decoration: const InputDecoration(labelText: 'لینک (اختیاری)', border: OutlineInputBorder())),
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
            Wrap(spacing: 8, runSpacing: 8, children: [
              Colors.deepPurple, Colors.blue, Colors.red, Colors.teal, Colors.orange, Colors.purple,
            ].map((c) => GestureDetector(
              onTap: () => setStateDialog(() => el['color'] = c.value),
              child: Container(width: 40, height: 40, decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: el['color'] == c.value ? Colors.black : Colors.transparent, width: 3))),
            )).toList()),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('لغو')),
          ElevatedButton(onPressed: () { setState(() { el['text'] = textCtrl.text; el['link'] = linkCtrl.text; el['targetPage'] = targetPage; _page!['elements'][i] = el; }); _save(); Navigator.pop(c); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A11CB)), child: const Text('ذخیره')),
        ],
      ),
    ));
  }
  @override
  Widget build(BuildContext context) {
    if (_page == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final elements = (_page!['elements'] as List? ?? []);
    return Scaffold(
      appBar: AppBar(title: Text(_page!['name'] ?? ''), backgroundColor: const Color(0xFF6A11CB), foregroundColor: Colors.white),
      body: elements.isEmpty ? const Center(child: Text('هنوز المانی اضافه نشده', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey))) : ListView.builder(
        padding: const EdgeInsets.all(16), itemCount: elements.length, itemBuilder: (c, i) {
          final el = elements[i];
          String subtitle = el['text'] ?? el['link'] ?? '';
          if (el['type'] == 'nextpage') {
            final t = el['targetPage'] ?? 0;
            subtitle = t < _allPages.length ? 'مقصد: ${_allPages[t]['name']}' : 'مقصد: صفحه اول';
          }
          return Card(margin: const EdgeInsets.only(bottom: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), child: ListTile(
            leading: Icon(_icon(el['type']), color: const Color(0xFF6A11CB)),
            title: Text(_label(el['type'])),
            subtitle: Text(subtitle),
            onTap: () => _editElement(i),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(icon: const Icon(Icons.arrow_upward, size: 18), onPressed: () => _moveElement(i, -1)),
              IconButton(icon: const Icon(Icons.arrow_downward, size: 18), onPressed: () => _moveElement(i, 1)),
              IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 18), onPressed: () => _deleteElement(i)),
            ]),
          ));
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Theme.of(context).cardColor, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -3))]),
        child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
          _btn(Icons.text_fields, 'متن', 'text'),
          _btn(Icons.smart_button, 'دکمه', 'button'),
          _btn(Icons.image, 'تصویر', 'image'),
          _btn(Icons.video_library, 'فیلم', 'video'),
          _btn(Icons.music_note, 'موزیک', 'audio'),
          _btn(Icons.navigation, 'منوی پایین', 'bottomnav'),
          _btn(Icons.menu, 'منوی کشویی', 'drawer'),
          _btn(Icons.arrow_forward, 'صفحه بعد', 'nextpage'),
          _btn(Icons.payment, 'پرداخت', 'purchase'),
        ])),
      ),
    );
  }
  Widget _btn(IconData icon, String label, String type) {
    return Padding(padding: const EdgeInsets.only(right: 8), child: ElevatedButton.icon(
      onPressed: () => _addElement(type),
      icon: Icon(icon, size: 18), label: Text(label, style: const TextStyle(fontSize: 13)),
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A11CB), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    ));
  }
  IconData _icon(String? t) { switch (t) { case 'text': return Icons.text_fields; case 'button': return Icons.smart_button; case 'image': return Icons.image; case 'video': return Icons.video_library; case 'audio': return Icons.music_note; case 'bottomnav': return Icons.navigation; case 'drawer': return Icons.menu; case 'nextpage': return Icons.arrow_forward; case 'purchase': return Icons.payment; default: return Icons.widgets; } }
  String _label(String? t) {
    switch (t) {
      case 'text': return 'متن';
      case 'button': return 'دکمه';
      case 'image': return 'تصویر';
      case 'video': return 'فیلم';
      case 'audio': return 'موزیک';
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('والپیپر $index ذخیره شد!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در ذخیره: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
  Widget _buildSplash() {
    final splashColor = Color(_app['splashColor'] ?? 0xFF6A11CB);
    final splashText = _app['splashText'] ?? _app['name'] ?? '';
    final splashImage = _app['splashImage'] ?? '';
    return Container(
      color: splashColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (splashImage.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.file(
                  File(splashImage),
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 100, color: Colors.white54),
                ),
              )
            else
              const Icon(Icons.apps, size: 100, color: Colors.white),
            const SizedBox(height: 30),
            if (splashText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  splashText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildPageContent(Map<String, dynamic> page, int pageIndex) {
    final elements = (page['elements'] as List? ?? []);
    final pages = (_app['pages'] as List? ?? []);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          page['name'] ?? '',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(_app['themeColor'] ?? 0xFF6A11CB)),
        ),
        const SizedBox(height: 20),
        ...elements.asMap().entries.map((entry) {
          final el = entry.value as Map<String, dynamic>;
          final type = el['type'];
          if (type == 'text') {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(el['text'] ?? '', style: TextStyle(fontSize: 18, color: Color(el['color'] ?? 0xFF000000))),
            );
          }
          if (type == 'button') {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final link = el['link'] ?? '';
                    if (link.isNotEmpty) {
                      final uri = Uri.parse(link);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('دکمه ${el['text']} زده شد')));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(el['color'] ?? 0xFF6A11CB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(el['text'] ?? ''),
                ),
              ),
            );
          }
          if (type == 'image') {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(el['mediaPath'] ?? ''), errorBuilder: (_, __, ___) => const SizedBox()),
              ),
            );
          }
          if (type == 'nextpage') {
            final target = el['targetPage'] ?? 0;
            final targetPage = (target >= 0 && target < pages.length) ? pages[target] : null;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _goToPage(target),
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(targetPage != null ? 'برو به ${targetPage['name']}' : 'صفحه بعد'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(el['color'] ?? 0xFF6A11CB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            );
          }
          return const SizedBox();
        }),
      ],
    );
  }
  Widget? _buildBottomNav() {
    final items = (_app['bottomMenu'] as List? ?? []);
    final pages = (_app['pages'] as List? ?? []);
    if (items.length < 2 || pages.isEmpty) return null;
    final validIndex = _currentPageIndex < items.length ? _currentPageIndex : 0;
    return NavigationBar(
      selectedIndex: validIndex.clamp(0, items.length - 1),
      onDestinationSelected: (i) {
        final item = items[i];
        final pageIndex = item['pageIndex'] ?? 0;
        _goToPage(pageIndex);
      },
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
      indicatorColor: Color(_app['themeColor'] ?? 0xFF6A11CB).withOpacity(0.15),
      destinations: items.map<Widget>((item) {
        Widget iconWidget;
        if (item['iconType'] == 'gallery' && (item['iconPath'] ?? '').isNotEmpty) {
          iconWidget = ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.file(File(item['iconPath']), width: 24, height: 24, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.circle)),
          );
        } else {
          final idx = (item['iconIndex'] ?? 0) as int;
          final icon = (idx >= 0 && idx < availableIcons.length) ? availableIcons[idx]['icon'] as IconData : Icons.circle;
          iconWidget = Icon(icon);
        }
        return NavigationDestination(
          icon: iconWidget,
          selectedIcon: iconWidget,
          label: item['label'] ?? '',
        );
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
          DrawerHeader(
            decoration: BoxDecoration(color: Color(_app['themeColor'] ?? 0xFF6A11CB)),
            child: Center(
              child: Text(
                _app['name'] ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          ...items.map<Widget>((item) {
            Widget leadingWidget;
            if (item['iconType'] == 'gallery' && (item['iconPath'] ?? '').isNotEmpty) {
              leadingWidget = ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.file(File(item['iconPath']), width: 28, height: 28, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.circle)),
              );
            } else {
              final idx = (item['iconIndex'] ?? 0) as int;
              final icon = (idx >= 0 && idx < availableIcons.length) ? availableIcons[idx]['icon'] as IconData : Icons.circle;
              leadingWidget = Icon(icon, color: Color(_app['themeColor'] ?? 0xFF6A11CB));
            }
            return ListTile(
              leading: leadingWidget,
              title: Text(item['label'] ?? ''),
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
        appBar: AppBar(title: Text(_app['name'] ?? ''), backgroundColor: Color(_app['themeColor'] ?? 0xFF6A11CB), foregroundColor: Colors.white),
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
      return Scaffold(
        appBar: AppBar(title: Text(_app['name'] ?? '')),
        body: const Center(child: Text('صفحه ای نساخته نشده')),
      );
    }
    if (_showSplash) {
      return Scaffold(body: _buildSplash());
    }
    if (_currentPageIndex >= pages.length) {
      _currentPageIndex = 0;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(pages[_currentPageIndex]['name'] ?? _app['name'] ?? ''),
        backgroundColor: Color(_app['themeColor'] ?? 0xFF6A11CB),
        foregroundColor: Colors.white,
      ),
      drawer: _buildDrawer(),
      body: _buildPageContent(pages[_currentPageIndex] as Map<String, dynamic>, _currentPageIndex),
      bottomNavigationBar: _buildBottomNav(),
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
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('هنوز اپی نساخته‌اید!'), backgroundColor: Colors.orange));
        }
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا در پشتیبان‌گیری: $e'), backgroundColor: Colors.red));
      }
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
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فایل پشتیبان معتبر نیست!'), backgroundColor: Colors.red));
        }
        return;
      }
      final apps = (data['apps'] as List).cast<Map<String, dynamic>>();
      final appsCount = apps.length;
      if (context.mounted) {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(children: [Icon(Icons.restore, color: Color(0xFF6A11CB)), SizedBox(width: 10), Text('بازیابی پشتیبان')]),
            content: Text('تعداد $appsCount اپ پیدا شد.\n\nآیا می‌خواهید اضافه شوند؟'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('لغو')),
              ElevatedButton(onPressed: () => Navigator.pop(c, true), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A11CB)), child: const Text('بازیابی')),
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$addedCount اپ بازیابی شد!'), backgroundColor: Colors.green, duration: const Duration(seconds: 4)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا در بازیابی: $e'), backgroundColor: Colors.red));
      }
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
            } else {
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('پرداخت انجام نشد!'), backgroundColor: Colors.orange));
            }
          } catch (e) {
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا: $e'), backgroundColor: Colors.red));
          }
        },
        onFailed: () {},
        onDisconnected: () {},
      );
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تنظیمات'), backgroundColor: const Color(0xFF6A11CB), foregroundColor: Colors.white, elevation: 0),
      body: AnimatedBuilder(animation: themeNotifier, builder: (context, _) => ListView(padding: const EdgeInsets.all(16), children: [
        Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), child: Column(children: [
          SwitchListTile(secondary: const Icon(Icons.dark_mode, color: Color(0xFF6A11CB)), title: const Text('حالت تاریک'), subtitle: const Text('تغییر تم اپ'), value: themeNotifier.isDark, onChanged: (v) => themeNotifier.toggleTheme()),
        ])),
        const SizedBox(height: 12),
        Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), child: const Column(children: [
          ListTile(leading: Icon(Icons.language, color: Color(0xFF6A11CB)), title: Text('زبان'), subtitle: Text('فارسی')),
        ])),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Column(children: [
            ListTile(
              leading: const Icon(Icons.backup, color: Color(0xFF6A11CB)),
              title: const Text('پشتیبان‌گیری از اپ‌ها'),
              subtitle: const Text('ذخیره همه اپ‌ها توی یه فایل'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _backupApps(context),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.restore, color: Color(0xFF6A11CB)),
              title: const Text('بازیابی از پشتیبان'),
              subtitle: const Text('برگرداندن اپ‌ها از فایل پشتیبان'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _restoreApps(context),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ListTile(
            leading: const Icon(Icons.workspace_premium, color: Colors.amber, size: 32),
            title: const Text('خرید نسخه دائمی', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('با ۹۹۹,۰۰۰ تومان، همه اپ ها رایگان میشه'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _buyLifetime(context),
          ),
        ),
        const SizedBox(height: 12),
        Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), child: ListTile(
          leading: const Icon(Icons.info, color: Color(0xFF6A11CB)),
          title: const Text('درباره اپ لند'),
          onTap: () => showAboutDialog(context: context, applicationName: 'اپ لند', applicationVersion: '1.0.0', children: const [
            Text('با اپ لند بدون کدنویسی، اپ اندروید بسازید!'),
            SizedBox(height: 8),
            Text('امکانات: ساخت اپ (محتوا محور/والپیپر)، صفحه ساز، تبلیغات، پرداخت درون برنامه ای، تم پیشرفته، فونت دلخواه و...'),
          ]),
        )),
      ])),
    );
  }
}