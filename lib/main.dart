import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await deviceConfig.load();
  runApp(const ProFootballMasterApp());
}

// ═══════════════════ DEVICE ═══════════════════
enum DeviceKind { phone, tablet, tv }

class DeviceConfig extends ChangeNotifier {
  DeviceKind _kind = DeviceKind.phone;
  DeviceKind get kind => _kind;
  bool get isTV => _kind == DeviceKind.tv;
  bool get isTablet => _kind == DeviceKind.tablet;
  bool get isPhone => _kind == DeviceKind.phone;
  double get scale => isTV ? 1.5 : (isTablet ? 1.2 : 1.0);
  double get padding => isTV ? 36 : (isTablet ? 24 : 16);
  int get gridCols => isTV ? 2 : (isTablet ? 2 : 1);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('device_kind');
    if (saved != null) {
      _kind = DeviceKind.values.firstWhere((e) => e.name == saved, orElse: () => DeviceKind.phone);
    } else {
      _kind = await _autoDetect();
    }
    notifyListeners();
  }

  Future<DeviceKind> _autoDetect() async {
    try {
      if (Platform.isAndroid) {
        final info = await DeviceInfoPlugin().androidInfo;
        if (info.systemFeatures.contains('android.software.leanback')) return DeviceKind.tv;
        final shortest = info.physicalSize.width > info.physicalSize.height
            ? info.physicalSize.height / info.devicePixelRatio
            : info.physicalSize.width / info.devicePixelRatio;
        if (shortest >= 600) return DeviceKind.tablet;
      }
    } catch (_) {}
    return DeviceKind.phone;
  }

  Future<void> setKind(DeviceKind k) async {
    _kind = k;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('device_kind', k.name);
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('device_kind');
    notifyListeners();
  }
}

final deviceConfig = DeviceConfig();

// ═══════════════════ COLORS ═══════════════════
class C {
  static const bg = Color(0xFF090D16);
  static const card = Color(0xFF131B2E);
  static const green = Color(0xFF10B981);
  static const amber = Color(0xFFF59E0B);
}

extension _Op on Color {
  Color op(double o) => withValues(alpha: o);
}

// ═══════════════════ TRANSLATION ═══════════════════
final ValueNotifier<String> langNotifier = ValueNotifier('egy');

const Map<String, Map<String, String>> _tr = {
  'egy': {
    'title': 'أكاديمية الاحتراف الكروي',
    'subtitle': 'اختار مركزك أو مهارتك وابدأ التدريب',
    'defense': 'أكاديمية الدفاع',
    'goalkeeper': 'حراسة المرمى',
    'attack': 'أكاديمية الهجوم',
    'shooting': 'أكاديمية التسديد الصاروخي 🔥',
    'langBtn': 'فصحى',
    'all': 'الكل',
    'ball': '⚽ بالكورة',
    'dumbbell': '🏋️ بالدمبل',
    'none': '🏃 بدون أدوات',
    'search': 'ابحث برقم التمرين (مثال: 500)',
    'notFound': 'مفيش تمرين بالشكل ده',
    'level': 'المستوى',
    'xp': 'نقطة خبرة',
    'doneCount': 'تمرين مكتمل',
    'favs': 'المفضلة',
    'sets': 'جولات',
    'reps': 'تكرار',
    'min': 'دقيقة',
    'steps': 'خطوات التمرين',
    'finishSet': 'خلصت الجولة',
    'rest': 'استراحة.. اشرب مية',
    'skip': 'تخطي الاستراحة',
    'finished': 'برافو يا كابتن! 🏆',
    'finishedMsg': 'خلصت التمرين وكسبت',
    'ok': 'تمام',
    'beginner': 'مبتدئ',
    'intermediate': 'متوسط',
    'pro': 'محترف',
    'setWord': 'الجولة',
    'of': 'من',
    'ballReq': '⚽ الأداة: كورة',
    'dumbReq': '🏋️ الأداة: دمبل خفيف',
    'noneReq': '🏃 بدون أدوات',
    'drill': 'تمرين',
    'nutritionTitle': 'دليل التغذية',
    'tipsTitle': 'مرشد المحترف',
    'nutritionBtn': '🥗 التغذية',
    'tipsBtn': '🎯 النصائح',
    'coachLabel': 'المدرب بيوضح',
  },
  'ar': {
    'title': 'أكاديمية كرة القدم الاحترافية',
    'subtitle': 'اختر قسمك التدريبي وابدأ التطور',
    'defense': 'قسم الدفاع',
    'goalkeeper': 'قسم حراسة المرمى',
    'attack': 'قسم الهجوم',
    'shooting': 'أكاديمية التسديد الصاروخي 🔥',
    'langBtn': 'English',
    'all': 'الكل',
    'ball': '⚽ بالكرة',
    'dumbbell': '🏋️ بالدمبل',
    'none': '🏃 بدون أدوات',
    'search': 'ابحث برقم التمرين (مثال: 500)',
    'notFound': 'لا يوجد تمرين مطابق',
    'level': 'المستوى',
    'xp': 'نقطة خبرة',
    'doneCount': 'تمرين مكتمل',
    'favs': 'المفضلة',
    'sets': 'جولات',
    'reps': 'تكرار',
    'min': 'دقيقة',
    'steps': 'خطوات التمرين',
    'finishSet': 'أنهيت الجولة',
    'rest': 'وقت الراحة.. اشرب الماء',
    'skip': 'تخطي الاستراحة',
    'finished': 'أحسنت أيها اللاعب! 🏆',
    'finishedMsg': 'أنهيت التمرين وحصلت على',
    'ok': 'حسناً',
    'beginner': 'مبتدئ',
    'intermediate': 'متوسط',
    'pro': 'محترف',
    'setWord': 'الجولة',
    'of': 'من',
    'ballReq': '⚽ الأداة: كرة قدم',
    'dumbReq': '🏋️ الأداة: دمبل خفيف',
    'noneReq': '🏃 بدون أدوات',
    'drill': 'تمرين',
    'nutritionTitle': 'دليل التغذية',
    'tipsTitle': 'مرشد المحترف',
    'nutritionBtn': '🥗 التغذية',
    'tipsBtn': '🎯 النصائح',
    'coachLabel': 'المدرب بيوضح',
  },
  'en': {
    'title': 'Pro Football Academy',
    'subtitle': 'Pick your training hub',
    'defense': 'Defense Hub',
    'goalkeeper': 'Goalkeeper Vault',
    'attack': 'Attack Hub',
    'shooting': 'Power Shooting Hub 🔥',
    'langBtn': 'مصري',
    'all': 'All',
    'ball': '⚽ Ball',
    'dumbbell': '🏋️ Dumbbell',
    'none': '🏃 No equipment',
    'search': 'Search by number (e.g. 500)',
    'notFound': 'No matching drill',
    'level': 'Level',
    'xp': 'XP',
    'doneCount': 'drills done',
    'favs': 'Favorites',
    'sets': 'sets',
    'reps': 'reps',
    'min': 'min',
    'steps': 'Drill steps',
    'finishSet': 'Set finished',
    'rest': 'Rest.. hydrate',
    'skip': 'Skip rest',
    'finished': 'Great work! 🏆',
    'finishedMsg': 'Drill complete! You earned',
    'ok': 'OK',
    'beginner': 'Beginner',
    'intermediate': 'Intermediate',
    'pro': 'Pro',
    'setWord': 'Set',
    'of': 'of',
    'ballReq': '⚽ Required: football',
    'dumbReq': '🏋️ Required: dumbbell',
    'noneReq': '🏃 Bodyweight',
    'drill': 'Drill',
    'nutritionTitle': 'Nutrition Guide',
    'tipsTitle': 'Pro Tips',
    'nutritionBtn': '🥗 Nutrition',
    'tipsBtn': '🎯 Tips',
    'coachLabel': 'Coach Demo',
  },
};

String tr(String k) => _tr[langNotifier.value]![k] ?? k;

// ═══════════════════ PROGRESS ═══════════════════
class Progress extends ChangeNotifier {
  final Set<String> done = {};
  final Set<String> favs = {};
  int xp = 0;
  int get level => xp ~/ 500 + 1;
  double get levelProgress => (xp % 500) / 500;
  int doneIn(String cat) => done.where((e) => e.startsWith('${cat}_')).length;
  void complete(Drill d) {
    done.add(d.id);
    xp += d.xp;
    notifyListeners();
  }
  void toggleFav(String id) {
    favs.contains(id) ? favs.remove(id) : favs.add(id);
    notifyListeners();
  }
}

final Progress progress = Progress();

// ═══════════════════ TEMPLATES ═══════════════════
class Tpl {
  final String ar, egy, en;
  final List<String> sAr, sEn;
  const Tpl(this.ar, this.egy, this.en, this.sAr, this.sEn);
}

const Map<String, List<List<Tpl>>> _tpls = {
  'defense': [
    [
      Tpl('تشتيت الكرة العالية', 'تشتيت الكورة العالية', 'Clearing High Balls',
          ['خذ وضع الاستعداد وعيناك على الكرة', 'اطلب من زميل رفع كرة عالية', 'اقفز واشتّت الكرة بالرأس بعيداً عن المرمى'],
          ['Get into a ready stance', 'Have a partner lift a high ball', 'Jump and head the ball away from goal']),
      Tpl('التمرير تحت الضغط', 'التمرير تحت الضغط', 'Passing Under Pressure',
          ['استلم الكرة بلمسة واحدة', 'أبعد الكرة عن المنافس بجسمك', 'مرّر بدقة لزميلك'],
          ['Control with one touch', 'Shield the ball from the opponent', 'Pass accurately to a teammate']),
    ],
    [
      Tpl('سكوات الدمبل لقوة الساقين', 'سكوات بالدمبل لقوة رجليك', 'Dumbbell Squats for Leg Power',
          ['امسك دمبلاً خفيفاً عند الصدر', 'انزل ببطء حتى توازي الفخذان الأرض', 'اصعد بقوة مع استقامة الظهر'],
          ['Hold a light dumbbell at your chest', 'Lower slowly until thighs are parallel', 'Drive up with a straight back']),
      Tpl('الاندفاع الأمامي بالدمبل', 'لانجز بالدمبل', 'Dumbbell Walking Lunges',
          ['امسك دمبلاً في كل يد', 'اخطُ للأمام وانزل بالركبة الخلفية', 'بدّل الساقين بتحكم'],
          ['Hold a dumbbell in each hand', 'Step forward and lower the back knee', 'Alternate legs with control']),
    ],
    [
      Tpl('الحركة الجانبية الدفاعية', 'التحرك الجانبي للمدافع', 'Defensive Lateral Shuffles',
          ['اثنِ ركبتيك وأبقِ ظهرك مستقيماً', 'تحرك جانباً 5 خطوات دون تقاطع القدمين', 'غيّر الاتجاه بسرعة'],
          ['Bend knees, keep back straight', 'Shuffle sideways 5 steps without crossing feet', 'Change direction quickly']),
      Tpl('توقيت الالتحام', 'توقيت التدخل', 'Tackle Timing Footwork',
          ['اقترب من نقطة وهمية بخطوات صغيرة', 'اختر لحظة التدخل بثبات', 'ارجع لوضع الاتجاه فوراً'],
          ['Close in on a marker with small steps', 'Pick your moment to step in', 'Recover to a ready stance immediately']),
    ],
  ],
  'goalkeeper': [
    [
      Tpl('التصدي للكرات المنخفضة', 'صدة الكورة الأرضية', 'Low Shot Save',
          ['قف في وضعية الاستعداد، وزنك على مقدمة القدم', 'اقرأ اتجاه رجل المهاجم قبل التسديد', 'اخد خطوة صغيرة ناحية اتجاه الكرة', 'انقض وأمسك بالكفين لو ينفع'],
          ['Stand in ready position, weight on balls of feet', 'Read the attacker\'s leg before the shot', 'Take a small step toward the ball direction', 'Dive and catch with both hands or parry']),
      Tpl('التصدي للكرات العالية', 'صدة الكورة العالية', 'High Ball Save',
          ['اقفز من قدم قوية واحدة مع رفع الركبة التانية', 'ايديك في وضع W (الكفين لفوق)', 'امسك الكرة واضمها للصدر قبل النزول', 'لو مش قادر تمسك، ادفعها بعيد عن المرمى'],
          ['Jump off one strong foot, raise opposite knee', 'Hands in W-shape (palms up)', 'Catch and secure to chest before landing', 'If can\'t catch, parry clear of goal']),
    ],
    [
      Tpl('تقوية الكتف بالدمبل', 'تقوية كتفك للصدة', 'Dumbbell Shoulder Press',
          ['امسك دمبل خفيف في كل يد عند مستوى الكتف', 'ارفع لفوق لحد ما الذراع تمد', 'انزل ببطء بتحكم', '3 مجموعات × 10-12 عدة'],
          ['Hold light dumbbells at shoulder level', 'Press overhead until arms extend', 'Lower slowly with control', '3 sets × 10-12 reps']),
      Tpl('ثبات الجذع بالدمبل', 'لف الجذع بالدمبل', 'Dumbbell Russian Twist',
          ['اجلس وارفع قدميك قليلاً عن الأرض', 'امسك دمبل بيدين اثنتين أمام صدرك', 'لف الجذع يميناً ويساراً بتحكم', '3 مجموعات × 20 لفة'],
          ['Sit with feet slightly off ground', 'Hold dumbbell with both hands at chest', 'Rotate torso left and right', '3 sets × 20 twists']),
    ],
    [
      Tpl('الغطس الجانبي المحترف', 'الغطس الجانبي للمحترفين', 'Pro Side Dive',
          ['اعمل على عشب ناعم أو مرتبة', 'ادفع بقوة من القدم القريبة من الكرة', 'مد الذراعين ناحية الكرة في نفس اللحظة', 'انزل على جانبك وقم بسرعة', '10 انقضاضات × 3 مجموعات'],
          ['Practice on soft grass or mat', 'Explosively push off the near foot', 'Extend both arms toward the ball', 'Land on your side and rise fast', '10 dives × 3 sets']),
      Tpl('سرعة رد الفعل', 'سرعة ردة فعلك', 'Reaction Speed',
          ['قف في منتصف المرمى بوضع الاستعداد', 'اطلب من زميلك يقذف كرة فجأة يمين أو شمال', 'اتحرك باتجاه واحد فقط بأقصى سرعة', '15 تكرار × 3 مجموعات'],
          ['Stand at goal centre in ready position', 'Have partner throw suddenly to left or right', 'Move that direction only at max speed', '15 reps × 3 sets']),
    ],
  ],
  'attack': [
    [
      Tpl('التسديد على المرمى', 'التسديد على الجون', 'Finishing Drill',
          ['استلم الكرة وافتح زاوية التسديد', 'ضع قدم الارتكاز بجانب الكرة', 'سدّد بوجه القدم الداخلي نحو الزاوية'],
          ['Receive and open the shooting angle', 'Plant your standing foot beside the ball', 'Strike with your instep to the corner']),
      Tpl('المراوغة بين الأقماع', 'الدريبل بين الأقماع', 'Cone Dribbling',
          ['ضع 6 أقماع بمسافة متر', 'مرّر الكرة بلمسات قصيرة', 'ارفع رأسك بين اللمسات'],
          ['Set 6 cones one metre apart', 'Weave through with short touches', 'Keep your head up between touches']),
    ],
    [
      Tpl('سكوات القفز الخفيف', 'سكوات قفز خفيف', 'Light Jump Squats',
          ['دمبل خفيف جداً عند الصدر', 'انزل ثم اقفز بقوة', 'ارتد بنعومة على مقدمة القدم'],
          ['Very light dumbbell at chest', 'Squat then jump explosively', 'Land softly on the balls of your feet']),
      Tpl('الرفعة الرومانية', 'الرفعة الرومانية بالدمبل', 'Dumbbell Romanian Deadlift',
          ['دمبل في كل يد أمام الفخذين', 'ادفع الحوض للخلف مع استقامة الظهر', 'اصعد بعصر الأرداف'],
          ['Dumbbell in each hand at thighs', 'Hinge hips back, back straight', 'Stand up squeezing glutes']),
    ],
    [
      Tpl('الانطلاق السريع', 'الانطلاق السريع', 'Sprint Starts',
          ['خذ وضع البداية المنخفض', 'انطلق بأقصى سرعة لمسافة 15 متراً', 'امشِ للعودة واسترد أنفاسك'],
          ['Take a low start stance', 'Sprint at full speed for 15 metres', 'Walk back and recover']),
      Tpl('تغيير الاتجاه', 'تغيير الاتجاه', 'Change of Direction',
          ['اركض نحو قمع وهمي', 'اضغط بالقدم الخارجية وغيّر الاتجاه', 'تسارع فوراً'],
          ['Run at an imaginary cone', 'Plant the outside foot and cut', 'Accelerate immediately']),
    ],
  ],
  'shooting': [
    [
      Tpl('تكنيك وش القدم للتسديد الصاروخي', 'شوط بصدر الرجل (الصاروخية)', 'Instep Power Shot',
          ['ضع قدم الارتكاز بجانب الكرة بمسافة شبر', 'شدّ مفصل الكاحل وثبّته جيداً', 'اضرب وسط الكرة بوصلة رباط الحذاء'],
          ['Plant standing foot a palm-width away', 'Lock your ankle firmly', 'Strike dead center with your laces']),
      Tpl('تسديد الكرة العالية', 'شوط عالي وصاروخي لفوق', 'High Elevation Shot',
          ['ميل بجسمك للخلف قليلاً لحظة التسديد', 'اضرب من أسفل منتصف الكرة بقوة', 'أكمل حركة الرجل للأعلى (Follow Through)'],
          ['Lean slightly back before striking', 'Strike below the center of the ball', 'Follow through with your leg high']),
    ],
    [
      Tpl('تقوية الساق بالدمبل', 'تقوية الرجل بالدمبل للشوط القوي', 'Dumbbell Calf Raises',
          ['قف وامسك دمبلاً في كل يد', 'اصعد على أطراف أصابع قدميك ببطء وانزل', 'كرر لبناء قوة دفع صاروخية'],
          ['Stand holding dumbbells', 'Raise up on your toes slowly and lower', 'Repeat to build explosive power']),
      Tpl('طعن الساقين بالدمبل', 'لنجز بالدمبل لقوة التسديد', 'Dumbbell Power Lunges',
          ['امسك دمبل وثبت قدم للأمام وأخرى للخلف', 'انزل واصعد بقوة وبشكل متفجر', 'يبني قوة عضلية هائلة للتسديد'],
          ['Hold a dumbbell, step forward into a lunge', 'Lower then drive up explosively', 'Builds massive leg drive for shooting']),
    ],
    [
      Tpl('التسديد على الطائر (فولي)', 'شوط على الطائر (ڤولي)', 'Volley Shooting',
          ['ارمِ الكرة لنفسك خفيفاً لتسقط أمامك', 'وجه جسمك وثبّت عينك على الكرة', 'اضربها وهي في الهواء'],
          ['Toss the ball and let it drop', 'Body squared, eyes on ball', 'Strike it cleanly out of the air']),
      Tpl('التسديد السريع من الحركة', 'شوط صاروخي وأنت جاري', 'Running Power Shot',
          ['خذ خطوتين سريعتين نحو الكرة', 'ثبت قدم الارتكاز بقوة على الأرض', 'أطلق صاروخاً نحو الزاوية البعيدة'],
          ['Take two fast approach steps', 'Plant your standing foot firmly', 'Unleash a power shot to far corner']),
    ],
  ],
};

// ═══════════════════ DRILL ═══════════════════
class Drill {
  final String id, category, equipmentType;
  final int index, difficulty, sets, reps, duration, breakTime, xp;
  final String titleAr, titleEgy, titleEn;
  final List<String> stepsAr, stepsEn;

  Drill({
    required this.id, required this.index, required this.category,
    required this.equipmentType, required this.difficulty, required this.sets,
    required this.reps, required this.duration, required this.breakTime,
    required this.xp, required this.titleAr, required this.titleEgy,
    required this.titleEn, required this.stepsAr, required this.stepsEn,
  });

  String title(String lang) => lang == 'egy' ? titleEgy : (lang == 'ar' ? titleAr : titleEn);
  List<String> steps(String lang) => lang == 'en' ? stepsEn : stepsAr;
  String get difficultyKey => const ['beginner', 'intermediate', 'pro'][difficulty];
}

class DatabaseManager {
  static const int totalDrillsCount = 100000;

  static String eqOf(int index) {
    final rem = index % 3;
    return rem == 0 ? 'ball' : (rem == 1 ? 'dumbbell' : 'none');
  }

  static Drill getDrill(int index, String category) {
    final eq = index % 3;
    final catTpls = _tpls[category] ?? _tpls['attack']!;
    final tpl = catTpls[eq][(index ~/ 3) % catTpls[eq].length];
    final diff = (index ~/ 3) % 3;
    return Drill(
      id: '${category}_$index', index: index, category: category,
      equipmentType: eqOf(index), difficulty: diff,
      sets: 3 + index % 3, reps: 8 + (index % 5) * 2,
      duration: 10 + (index % 4) * 5, breakTime: 45 + diff * 15,
      xp: 20 + diff * 15,
      titleAr: '${tpl.ar} #$index', titleEgy: '${tpl.egy} #$index', titleEn: '${tpl.en} #$index',
      stepsAr: tpl.sAr, stepsEn: tpl.sEn,
    );
  }
}

// ═══════════════════ MAIN APP ═══════════════════
class ProFootballMasterApp extends StatefulWidget {
  const ProFootballMasterApp({super.key});
  @override
  State<ProFootballMasterApp> createState() => _ProFootballMasterAppState();
}

class _ProFootballMasterAppState extends State<ProFootballMasterApp> {
  bool _chosen = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      if (p.getString('device_kind') != null && mounted) {
        setState(() => _chosen = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([langNotifier, deviceConfig]),
      builder: (context, _) {
        return MaterialApp(
          title: 'Pro Football Academy',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: C.bg,
            primaryColor: C.green,
            colorScheme: const ColorScheme.dark(primary: C.green, secondary: C.amber),
          ),
          builder: (context, child) => ValueListenableBuilder<String>(
            valueListenable: langNotifier,
            builder: (context, lang, _) => Directionality(
              textDirection: lang == 'en' ? TextDirection.ltr : TextDirection.rtl,
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(deviceConfig.scale),
                ),
                child: child!,
              ),
            ),
          ),
          home: _chosen
              ? const DashboardScreen()
              : DeviceSelectScreen(onSelected: () => setState(() => _chosen = true)),
        );
      },
    );
  }
}

// ═══════════════════ DEVICE SELECT ═══════════════════
class DeviceSelectScreen extends StatelessWidget {
  final VoidCallback onSelected;
  const DeviceSelectScreen({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.smartphone, 'تليفون', DeviceKind.phone, const Color(0xFF3B82F6)),
      (Icons.tablet_android, 'تابلت', DeviceKind.tablet, const Color(0xFF8B5CF6)),
      (Icons.tv, 'تلفزيون', DeviceKind.tv, const Color(0xFFF59E0B)),
    ];
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⚽', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 12),
                const Text('انت بتستخدم إيه؟',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                const Text('اختار الجهاز عشان نظبط حجم الشاشة',
                    style: TextStyle(color: Colors.white70, fontSize: 15)),
                const SizedBox(height: 32),
                for (final it in items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _BigFocusButton(
                      icon: it.$1, label: it.$2, color: it.$4,
                      onTap: () async {
                        await deviceConfig.setKind(it.$3);
                        onSelected();
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BigFocusButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _BigFocusButton({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  State<_BigFocusButton> createState() => _BigFocusButtonState();
}

class _BigFocusButtonState extends State<_BigFocusButton> {
  bool _f = false;
  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (v) => setState(() => _f = v),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: _f ? 0.35 : 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _f ? widget.color : widget.color.withValues(alpha: 0.4),
              width: _f ? 3 : 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 42, color: widget.color),
              const SizedBox(width: 20),
              Expanded(
                child: Text(widget.label,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              Icon(Icons.arrow_forward_ios, color: widget.color, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════ DASHBOARD ═══════════════════
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void toggleLang() {
    final v = langNotifier.value;
    langNotifier.value = v == 'egy' ? 'ar' : (v == 'ar' ? 'en' : 'egy');
  }

  void openDrills(BuildContext context, String key) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => DrillsScreen(categoryKey: key)));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([langNotifier, progress, deviceConfig]),
      builder: (context, _) {
        final cards = [
          PositionCard(title: tr('defense'), icon: Icons.shield_rounded,
              colors: const [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
              done: progress.doneIn('defense'), onTap: () => openDrills(context, 'defense')),
          PositionCard(title: tr('goalkeeper'), icon: Icons.sports_handball_rounded,
              colors: const [Color(0xFFB45309), Color(0xFFF59E0B)],
              done: progress.doneIn('goalkeeper'), onTap: () => openDrills(context, 'goalkeeper')),
          PositionCard(title: tr('attack'), icon: Icons.local_fire_department_rounded,
              colors: const [Color(0xFF991B1B), Color(0xFFEF4444)],
              done: progress.doneIn('attack'), onTap: () => openDrills(context, 'attack')),
          PositionCard(title: tr('shooting'), icon: Icons.bolt_rounded,
              colors: const [Color(0xFF047857), Color(0xFF059669)],
              done: progress.doneIn('shooting'), onTap: () => openDrills(context, 'shooting')),
        ];
        final wide = deviceConfig.gridCols > 1;

        return Scaffold(
          appBar: AppBar(
            title: Text(tr('title'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            backgroundColor: C.card,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.devices, color: C.green),
                tooltip: 'تغيير الجهاز',
                onPressed: () async {
                  await deviceConfig.reset();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const ProFootballMasterApp()),
                      (_) => false,
                    );
                  }
                },
              ),
              TextButton.icon(
                onPressed: toggleLang,
                icon: const Icon(Icons.language, color: C.green),
                label: Text(tr('langBtn'), style: const TextStyle(color: Colors.white70)),
              ),
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [C.bg, C.card], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(deviceConfig.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StatsCard(),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _FeatureButton(
                          icon: Icons.restaurant_menu_rounded, label: tr('nutritionBtn'),
                          color: C.green,
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const NutritionScreen())),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FeatureButton(
                          icon: Icons.lightbulb_rounded, label: tr('tipsBtn'),
                          color: C.amber,
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const TipsScreen())),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(tr('subtitle'), style: const TextStyle(color: C.green, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 14),
                  if (wide)
                    GridView.count(
                      crossAxisCount: 2, shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 2.8,
                      children: cards,
                    )
                  else
                    for (final c in cards)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: SizedBox(height: deviceConfig.isTV ? 140 : 110, child: c),
                      ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FeatureButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _FeatureButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class StatsCard extends StatelessWidget {
  const StatsCard({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: C.green.op(0.4)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 76, height: 76,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 76, height: 76,
                  child: CircularProgressIndicator(
                    value: progress.levelProgress, strokeWidth: 7,
                    backgroundColor: Colors.white12, color: C.green,
                  ),
                ),
                Text('${progress.level}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${tr('level')} ${progress.level}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('⭐ ${progress.xp} ${tr('xp')}', style: const TextStyle(color: C.amber, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('✅ ${progress.done.length} ${tr('doneCount')}', style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PositionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Color> colors;
  final int done;
  final VoidCallback onTap;
  const PositionCard({super.key, required this.title, required this.icon,
      required this.colors, required this.done, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: colors.last.op(0.3), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.op(0.2), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: deviceConfig.isTV ? 44 : 34, color: Colors.white),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(
                    fontSize: deviceConfig.isTV ? 24 : 19,
                    fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('✅ $done ${tr('doneCount')}',
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════ DRILLS SCREEN ═══════════════════
class DrillsScreen extends StatefulWidget {
  final String categoryKey;
  const DrillsScreen({super.key, required this.categoryKey});
  @override
  State<DrillsScreen> createState() => _DrillsScreenState();
}

class _DrillsScreenState extends State<DrillsScreen> {
  String selectedEquipment = 'all';
  String searchQuery = '';
  bool favOnly = false;

  bool matchesEquipment(int n) => selectedEquipment == 'all' || DatabaseManager.eqOf(n) == selectedEquipment;

  List<int>? fixedList() {
    if (searchQuery.isNotEmpty) {
      final n = int.tryParse(searchQuery);
      if (n != null && n >= 0 && n <= DatabaseManager.totalDrillsCount && matchesEquipment(n)) return [n];
      return [];
    }
    if (favOnly) {
      final prefix = '${widget.categoryKey}_';
      return progress.favs
          .where((id) => id.startsWith(prefix))
          .map((id) => int.parse(id.substring(prefix.length)))
          .where(matchesEquipment).toList()..sort();
    }
    return null;
  }

  int countFor() {
    if (selectedEquipment == 'all') return DatabaseManager.totalDrillsCount;
    if (selectedEquipment == 'ball') return 33334;
    return 33333;
  }

  int realIndex(int i) {
    final a = i + 1;
    if (selectedEquipment == 'ball') return (a - 1) * 3;
    if (selectedEquipment == 'dumbbell') return (a - 1) * 3 + 1;
    if (selectedEquipment == 'none') return (a - 1) * 3 + 2;
    return i;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([langNotifier, progress, deviceConfig]),
      builder: (context, _) {
        final lang = langNotifier.value;
        final fixed = fixedList();
        final itemCount = fixed?.length ?? countFor();

        return Scaffold(
          appBar: AppBar(
            title: Text(tr(widget.categoryKey)),
            backgroundColor: C.card,
            actions: [
              IconButton(
                tooltip: tr('favs'),
                icon: Icon(favOnly ? Icons.favorite : Icons.favorite_border, color: Colors.redAccent),
                onPressed: () => setState(() => favOnly = !favOnly),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final k in const ['all', 'ball', 'dumbbell', 'none']) ...[
                        FilterChipLabel(label: tr(k), isSelected: selectedEquipment == k,
                            onTap: () => setState(() => selectedEquipment = k)),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (v) => setState(() => searchQuery = v.trim()),
                  decoration: InputDecoration(
                    hintText: tr('search'),
                    prefixIcon: const Icon(Icons.search, color: C.green),
                    filled: true, fillColor: C.card,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
              ),
              Expanded(
                child: itemCount == 0
                    ? Center(child: Text(tr('notFound'),
                        style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)))
                    : ListView.builder(
                        itemCount: itemCount,
                        itemBuilder: (context, i) {
                          final idx = fixed != null ? fixed[i] : realIndex(i);
                          final drill = DatabaseManager.getDrill(idx, widget.categoryKey);
                          final isDone = progress.done.contains(drill.id);
                          final isFav = progress.favs.contains(drill.id);
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(color: C.card, borderRadius: BorderRadius.circular(14)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: C.green.op(0.15), borderRadius: BorderRadius.circular(10)),
                                child: Icon(
                                    isDone ? Icons.check_circle_rounded : Icons.fitness_center_rounded,
                                    color: C.green),
                              ),
                              title: Text(drill.title(lang),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  '${tr(drill.equipmentType)} • ${tr(drill.difficultyKey)} • ${drill.duration} ${tr('min')}',
                                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                                        color: Colors.redAccent),
                                    onPressed: () => progress.toggleFav(drill.id),
                                  ),
                                  const Icon(Icons.play_circle_fill_rounded, color: C.green, size: 34),
                                ],
                              ),
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => ActiveSessionScreen(drill: drill))),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class FilterChipLabel extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const FilterChipLabel({super.key, required this.label, required this.isSelected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: C.green,
      backgroundColor: C.card,
      labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
    );
  }
}

// ═══════════════════ ACTIVE SESSION ═══════════════════
class ActiveSessionScreen extends StatefulWidget {
  final Drill drill;
  const ActiveSessionScreen({super.key, required this.drill});
  @override
  State<ActiveSessionScreen> createState() => _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends State<ActiveSessionScreen> {
  int currentSet = 1;
  int currentStep = 0;
  bool resting = false;
  int remaining = 0;
  Timer? timer;
  Drill get d => widget.drill;

  void nextStep() {
    if (currentStep < d.steps(langNotifier.value).length - 1) {
      setState(() => currentStep++);
    } else {
      finishSet();
    }
  }

  void finishSet() {
    HapticFeedback.mediumImpact();
    if (currentSet >= d.sets) {
      finishDrill();
    } else {
      startRest();
    }
  }

  void startRest() {
    timer?.cancel();
    setState(() { resting = true; remaining = d.breakTime; });
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remaining > 1) {
        setState(() => remaining--);
      } else {
        endRest();
      }
    });
  }

  void endRest() {
    timer?.cancel();
    if (!mounted) return;
    HapticFeedback.lightImpact();
    setState(() { resting = false; currentSet++; currentStep = 0; });
  }

  void finishDrill() {
    progress.complete(d);
    showDialog(
      context: context, barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: C.card,
        title: Text(tr('finished'), textAlign: TextAlign.center),
        content: Text('${tr('finishedMsg')} +${d.xp} ${tr('xp')}',
            textAlign: TextAlign.center, style: const TextStyle(color: C.amber, fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
            child: Text(tr('ok'), style: const TextStyle(color: C.green, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() { timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([langNotifier, progress]),
      builder: (context, _) {
        final lang = langNotifier.value;
        final isFav = progress.favs.contains(d.id);
        final reqKey = d.equipmentType == 'ball' ? 'ballReq'
            : (d.equipmentType == 'dumbbell' ? 'dumbReq' : 'noneReq');
        return Scaffold(
          appBar: AppBar(
            title: Text(d.title(lang), style: const TextStyle(fontSize: 15)),
            backgroundColor: C.card,
            actions: [
              IconButton(
                icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: Colors.redAccent),
                onPressed: () => progress.toggleFav(d.id),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: resting ? buildRest() : buildDrill(lang, reqKey),
          ),
        );
      },
    );
  }

  Widget buildRest() {
    final value = d.breakTime == 0 ? 0.0 : remaining / d.breakTime;
    final mm = (remaining ~/ 60).toString().padLeft(2, '0');
    final ss = (remaining % 60).toString().padLeft(2, '0');
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(tr('rest'), textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: C.amber)),
          const SizedBox(height: 28),
          SizedBox(
            width: 190, height: 190,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 190, height: 190,
                  child: CircularProgressIndicator(
                      value: value, strokeWidth: 10, backgroundColor: Colors.white12, color: C.amber),
                ),
                Text('$mm:$ss', style: const TextStyle(fontSize: 46, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: C.green,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: endRest,
            child: Text(tr('skip'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget buildDrill(String lang, String reqKey) {
    final steps = d.steps(lang);
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: C.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: C.green.op(0.4), width: 2),
          ),
          child: Column(
            children: [
              Text(tr('coachLabel'),
                  style: const TextStyle(color: C.green, fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              InstructorView(
                category: d.category,
                stepIndex: currentStep,
                totalSteps: steps.length,
                height: deviceConfig.isTV ? 300 : 220,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: C.card, borderRadius: BorderRadius.circular(14)),
          child: Column(
            children: [
              Text('${tr('setWord')} $currentSet ${tr('of')} ${d.sets}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (currentSet - 1 + (currentStep + 1) / steps.length) / d.sets,
                color: C.green, backgroundColor: Colors.white12, minHeight: 6,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8, runSpacing: 8,
          children: [
            _pill('${d.sets} ${tr('sets')}'),
            _pill('${d.reps} ${tr('reps')}'),
            _pill('${d.duration} ${tr('min')}'),
            _pill(tr(d.difficultyKey)),
          ],
        ),
        const SizedBox(height: 12),
        Text(tr(reqKey), textAlign: TextAlign.center,
            style: const TextStyle(color: C.green, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 14),
        Row(
          children: [
            Text('${tr('steps')} (${currentStep + 1}/${steps.length})',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const Spacer(),
            if (currentStep > 0)
              TextButton(
                onPressed: () => setState(() => currentStep--),
                child: const Text('السابق', style: TextStyle(color: Colors.white70)),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: C.green.op(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: C.green.op(0.4)),
          ),
          child: Row(
            children: [
              CircleAvatar(radius: 16, backgroundColor: C.green,
                  child: Text('${currentStep + 1}',
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
              const SizedBox(width: 12),
              Expanded(child: Text(steps[currentStep],
                  style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4))),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: currentStep < steps.length - 1 ? C.green : C.amber,
            foregroundColor: currentStep < steps.length - 1 ? Colors.white : Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: Icon(currentStep < steps.length - 1 ? Icons.arrow_forward_rounded : Icons.check_rounded),
          label: Text(
            currentStep < steps.length - 1 ? 'الخطوة التالية' : tr('finishSet'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onPressed: nextStep,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _pill(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    decoration: BoxDecoration(color: C.green.op(0.15), borderRadius: BorderRadius.circular(20)),
    child: Text(text, style: const TextStyle(color: C.green, fontWeight: FontWeight.w600)),
  );
}

// ═══════════════════ INSTRUCTOR (MANNEQUIN) ═══════════════════
class InstructorView extends StatefulWidget {
  final String category;
  final int stepIndex;
  final int totalSteps;
  final double height;
  const InstructorView({
    super.key, required this.category, required this.stepIndex,
    required this.totalSteps, this.height = 220,
  });
  @override
  State<InstructorView> createState() => _InstructorViewState();
}

class _InstructorViewState extends State<InstructorView> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => SizedBox(
        height: widget.height,
        child: CustomPaint(
          size: Size.infinite,
          painter: _MannequinPainter(
            t: _ctrl.value, step: widget.stepIndex,
            total: widget.totalSteps, category: widget.category,
          ),
        ),
      ),
    );
  }
}

class _MannequinPainter extends CustomPainter {
  final double t;
  final int step;
  final int total;
  final String category;
  _MannequinPainter({required this.t, required this.step, required this.total, required this.category});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 20;
    final s = math.min(size.width, size.height) / 200.0;

    final pose = _poseFor(category, step);
    final bob = math.sin(t * math.pi) * 2 * s;
    final swing = math.sin(t * math.pi) * 0.25;

    final headR = 16 * s;
    Offset head = Offset(cx, cy - 70 * s + bob);
    Offset neck = Offset(cx, cy - 52 * s + bob);
    Offset hip = Offset(cx, cy + 8 * s);
    Offset lShoulder = Offset(cx - 16 * s, cy - 48 * s + bob);
    Offset rShoulder = Offset(cx + 16 * s, cy - 48 * s + bob);
    Offset lHip = Offset(cx - 12 * s, cy + 8 * s);
    Offset rHip = Offset(cx + 12 * s, cy + 8 * s);

    final armSwing = pose.armSwing + swing * pose.armSwingAmp;
    Offset lElbow = lShoulder + Offset(math.sin(armSwing) * 22 * s, math.cos(armSwing) * 22 * s);
    Offset lHand = lElbow + Offset(
        math.sin(armSwing + pose.forearmBend) * 20 * s,
        math.cos(armSwing + pose.forearmBend) * 20 * s);
    final armSwingR = pose.armSwingR + swing * pose.armSwingAmp;
    Offset rElbow = rShoulder + Offset(-math.sin(armSwingR) * 22 * s, math.cos(armSwingR) * 22 * s);
    Offset rHand = rElbow + Offset(
        -math.sin(armSwingR + pose.forearmBend) * 20 * s,
        math.cos(armSwingR + pose.forearmBend) * 20 * s);

    final legPhase = math.sin(t * math.pi * 2) * pose.legSwingAmp;
    Offset lKnee = lHip + Offset(math.sin(pose.legSpread + legPhase) * 30 * s, 30 * s);
    Offset lFoot = lKnee + Offset(math.sin(pose.legSpread + legPhase) * 5 * s, 30 * s);
    Offset rKnee = rHip + Offset(-math.sin(pose.legSpread - legPhase) * 30 * s, 30 * s);
    Offset rFoot = rKnee + Offset(-math.sin(pose.legSpread - legPhase) * 5 * s, 30 * s);

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 80 * s), width: 60 * s, height: 12 * s),
      Paint()..color = Colors.black.withValues(alpha: 0.35),
    );

    final linePaint = Paint()
      ..color = C.green.withValues(alpha: 0.4)..strokeWidth = 2 * s;
    canvas.drawLine(Offset(cx - 80 * s, cy + 80 * s), Offset(cx + 80 * s, cy + 80 * s), linePaint);

    final jointPaint = Paint()..color = C.amber;
    canvas.drawCircle(head, headR, Paint()..color = C.amber);
    final eye = Paint()..color = Colors.black;
    canvas.drawCircle(head + Offset(-5 * s, -2 * s), 1.8 * s, eye);
    canvas.drawCircle(head + Offset(5 * s, -2 * s), 1.8 * s, eye);

    final jointStroke = Paint()
      ..color = C.amber..strokeWidth = 4 * s..strokeCap = StrokeCap.round;
    canvas.drawLine(head + Offset(0, headR), neck, jointStroke);

    final torsoPaint = Paint()
      ..color = C.green..strokeWidth = 10 * s..strokeCap = StrokeCap.round;
    canvas.drawLine(neck, hip, torsoPaint);

    final limbStroke = Paint()
      ..color = C.green..strokeWidth = 6 * s..strokeCap = StrokeCap.round;
    canvas.drawLine(lShoulder, lElbow, limbStroke);
    canvas.drawLine(lElbow, lHand, limbStroke);
    canvas.drawCircle(lHand, 3 * s, jointPaint);
    canvas.drawLine(rShoulder, rElbow, limbStroke);
    canvas.drawLine(rElbow, rHand, limbStroke);
    canvas.drawCircle(rHand, 3 * s, jointPaint);
    canvas.drawLine(lHip, lKnee, limbStroke);
    canvas.drawLine(lKnee, lFoot, limbStroke);
    canvas.drawCircle(lFoot, 4 * s, jointPaint);
    canvas.drawLine(rHip, rKnee, limbStroke);
    canvas.drawLine(rKnee, rFoot, limbStroke);
    canvas.drawCircle(rFoot, 4 * s, jointPaint);

    if (pose.hasBall) {
      final ballPos = Offset(cx - 45 * s, cy + 60 * s);
      canvas.drawCircle(ballPos, 10 * s, Paint()..color = Colors.white);
      canvas.drawCircle(ballPos, 10 * s,
          Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1.5 * s);
    }
    if (pose.hasDumbbell) {
      final dPos = lHand;
      final dPaint = Paint()
        ..color = const Color(0xFFB45309)..strokeWidth = 5 * s..strokeCap = StrokeCap.round;
      canvas.drawLine(dPos + Offset(-8 * s, 0), dPos + Offset(8 * s, 0), dPaint);
      canvas.drawCircle(dPos + Offset(-8 * s, 0), 4 * s, Paint()..color = const Color(0xFF78350F));
      canvas.drawCircle(dPos + Offset(8 * s, 0), 4 * s, Paint()..color = const Color(0xFF78350F));
    }
  }

  _Pose _poseFor(String cat, int step) {
    final idx = step % 4;
    switch (cat) {
      case 'goalkeeper':
        return [
          _Pose(armSwing: -1.2, armSwingR: -1.2, armSwingAmp: 0.3, legSpread: 0.3, hasBall: true),
          _Pose(armSwing: -2.2, armSwingR: -2.2, armSwingAmp: 0.15, legSpread: 0.4, hasBall: true),
          _Pose(armSwing: -1.5, armSwingR: 1.5, armSwingAmp: 0.5, legSpread: 0.6),
          _Pose(armSwing: -0.5, armSwingR: -0.5, armSwingAmp: 0.2, legSpread: 0.2, hasBall: true),
        ][idx];
      case 'defense':
        return [
          _Pose(armSwing: -0.8, armSwingR: -0.8, armSwingAmp: 0.4, legSpread: 0.2, hasBall: true),
          _Pose(armSwing: -1.5, armSwingR: -1.5, armSwingAmp: 0.3, legSpread: 0.3, hasDumbbell: true),
          _Pose(armSwing: 0.5, armSwingR: 0.5, armSwingAmp: 0.6, legSpread: 0.5),
          _Pose(armSwing: -0.3, armSwingR: -0.3, armSwingAmp: 0.3, legSpread: 0.2),
        ][idx];
      case 'shooting':
        return [
          _Pose(armSwing: 0.5, armSwingR: -0.5, armSwingAmp: 0.8, legSpread: 0.1, hasBall: true),
          _Pose(armSwing: -1.0, armSwingR: -1.0, armSwingAmp: 0.5, legSpread: 0.4, hasBall: true),
          _Pose(armSwing: -0.2, armSwingR: 0.2, armSwingAmp: 0.7, legSpread: 0.6),
          _Pose(armSwing: 0.3, armSwingR: 0.3, armSwingAmp: 0.4, legSpread: 0.3, hasBall: true),
        ][idx];
      default:
        return [
          _Pose(armSwing: -0.6, armSwingR: -0.6, armSwingAmp: 0.5, legSpread: 0.3, hasBall: true),
          _Pose(armSwing: 0.4, armSwingR: 0.4, armSwingAmp: 0.7, legSpread: 0.4, hasBall: true),
          _Pose(armSwing: -1.2, armSwingR: 1.2, armSwingAmp: 0.4, legSpread: 0.5),
          _Pose(armSwing: 0.2, armSwingR: 0.2, armSwingAmp: 0.5, legSpread: 0.2, hasBall: true),
        ][idx];
    }
  }

  @override
  bool shouldRepaint(_MannequinPainter o) =>
      o.t != t || o.step != step || o.category != category;
}

class _Pose {
  final double armSwing, armSwingR, armSwingAmp, forearmBend, legSpread, legSwingAmp;
  final bool hasBall, hasDumbbell;
  const _Pose({
    this.armSwing = -0.5, this.armSwingR = -0.5, this.armSwingAmp = 0.3,
    this.forearmBend = 0.5, this.legSpread = 0.3, this.legSwingAmp = 0.15,
    this.hasBall = false, this.hasDumbbell = false,
  });
}

// ═══════════════════ NUTRITION ═══════════════════
class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(tr('nutritionTitle')),
          backgroundColor: C.card,
          bottom: TabBar(
            isScrollable: true, indicatorColor: C.green,
            tabs: [
              Tab(text: tr('defense')),
              Tab(text: tr('goalkeeper')),
              Tab(text: tr('attack')),
              Tab(text: tr('shooting')),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _NutritionList(data: _defenseData),
            _NutritionList(data: _goalkeeperData),
            _NutritionList(data: _attackData),
            _NutritionList(data: _shootingData),
          ],
        ),
      ),
    );
  }
}

class _NItem {
  final String icon, ar, en, descAr, descEn;
  final Color color;
  const _NItem(this.icon, this.ar, this.en, this.descAr, this.descEn, this.color);
}

class _NutritionList extends StatelessWidget {
  final List<_NItem> data;
  const _NutritionList({required this.data});
  @override
  Widget build(BuildContext context) {
    final isEn = langNotifier.value == 'en';
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: data.length,
      itemBuilder: (_, i) {
        final d = data[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: C.card, borderRadius: BorderRadius.circular(16),
            border: Border.all(color: d.color.withValues(alpha: 0.4)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: d.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                child: Text(d.icon, style: const TextStyle(fontSize: 26)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isEn ? d.en : d.ar,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: d.color)),
                    const SizedBox(height: 6),
                    Text(isEn ? d.descEn : d.descAr,
                        style: const TextStyle(color: Colors.white70, height: 1.5, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

const _defenseData = <_NItem>[
  _NItem('🥩', 'بروتين عالي', 'High Protein',
      'المدافع محتاج عضلات قوية. ركّز على صدور الدجاج، اللحمة الحمراء، البيض، السمك. 1.6-2 جرام لكل كيلو من وزنك يومياً.',
      'Defenders need strong muscles. Focus on chicken, lean red meat, eggs, fish. 1.6-2g/kg daily.',
      Color(0xFF3B82F6)),
  _NItem('🍚', 'كارب معقد قبل الماتش', 'Complex Carbs',
      'قبل الماتش بـ 3-4 ساعات: رز، مكرونة، بطاطا. الكارب بيدي طاقة مستمرة 90 دقيقة.',
      'Pre-match 3-4h: rice, pasta, potato. Complex carbs = steady 90-min energy.',
      Color(0xFF10B981)),
  _NItem('🥬', 'حديد وفيتامين C', 'Iron & Vitamin C',
      'سبانخ + ليمون = حديد سريع الامتصاص. محتاج دم صحي لتحمل الاحتكاك.',
      'Spinach + lemon = fast iron. Need healthy blood for physical battles.',
      Color(0xFFEAB308)),
  _NItem('🍌', 'سناك قبل الماتش', 'Pre-Match Snack',
      'موزة + عسل قبل الماتش بساعة. يمنع الشد العضلي.',
      'Banana + honey 1h before. Prevents cramps.',
      Color(0xFFF59E0B)),
  _NItem('💧', 'مية وأملاح', 'Water & Electrolytes',
      '500 مل قبل بساعتين. رشفة كل 15 دقيقة. الأملاح مهمة لو بتعرق كتير.',
      '500ml 2h before. Sip every 15 min. Electrolytes if sweating heavily.',
      Color(0xFF0EA5E9)),
  _NItem('🌙', 'قبل النوم', 'Before Bed',
      'زبادي يوناني + لوز = بروتين بطيء بيبني العضلة خلال النوم.',
      'Greek yogurt + almonds = slow protein builds muscle during sleep.',
      Color(0xFF8B5CF6)),
];

const _goalkeeperData = <_NItem>[
  _NItem('⚡', 'طاقة سريعة للانقضاض', 'Quick Energy for Dives',
      'الحارس محتاج انفجارات. كارب سريع = تمر، عسل قبل التمرين بنصف ساعة.',
      'Keepers need bursts. Fast carbs = dates, honey 30 min before.',
      Color(0xFFF59E0B)),
  _NItem('👁️', 'فيتامين A لصحة العين', 'Vitamin A for Eyes',
      'جزر، بطاطا حلوة، سبانخ = نظر أفضل = تصدي أسرع.',
      'Carrots, sweet potato, spinach = better vision = faster saves.',
      Color(0xFF10B981)),
  _NItem('🐟', 'أوميجا 3', 'Omega-3',
      'سلمون، تونة 2-3 مرات أسبوعياً. يقلل الالتهاب ويحسن رد الفعل.',
      'Salmon, tuna 2-3x/week. Reduces inflammation, boosts reaction.',
      Color(0xFF3B82F6)),
  _NItem('🥛', 'كالسيوم للعظام', 'Calcium for Bones',
      'لبن، جبنة، زبادي. الحارس بيقع كتير فالعظام لازم صلبة.',
      'Milk, cheese, yogurt. Keepers fall a lot — need strong bones.',
      Color(0xFFEC4899)),
  _NItem('💧', 'ترطيب مكثف', 'Hydration Focus',
      'الجفاف بيقلل التركيز 10%. اشرب كفاية + مشروبات رياضية في الحر.',
      'Dehydration cuts focus 10%. Drink enough + sports drinks in heat.',
      Color(0xFF0EA5E9)),
  _NItem('☕', 'كافيين خفيف', 'Light Caffeine',
      'قهوة سوداء أو شاي أخضر قبل الماتش بنصف ساعة = يقظة أعلى.',
      'Black coffee or green tea 30 min before = higher alertness.',
      Color(0xFFEF4444)),
];

const _attackData = <_NItem>[
  _NItem('🍝', 'كارب = وقود الانفجار', 'Carbs = Explosion Fuel',
      'المهاجم بيركض بسرعات. رز، مكرونة، خبز أسمر. ليلة الماتش = طبق مكرونة كبير.',
      'Attacker sprints fast. Rice, pasta, brown bread. Night before = big pasta.',
      Color(0xFFEF4444)),
  _NItem('🍗', 'بروتين للعضلات', 'Protein for Muscles',
      'فراخ مشوية، لحمة، بيض. 20-30 جرام بعد التمرين = بناء أسرع.',
      'Grilled chicken, beef, eggs. 20-30g post-workout = faster muscle.',
      Color(0xFF10B981)),
  _NItem('🥜', 'دهون صحية', 'Healthy Fats',
      'أفوكادو، مكسرات، زيت زيتون. بتدعم هرمونات بناء العضلات.',
      'Avocado, nuts, olive oil. Support muscle-building hormones.',
      Color(0xFFEAB308)),
  _NItem('🍊', 'فيتامين C', 'Vitamin C',
      'برتقال، كيوي، فراولة. بيحمي العضلات وبيسرع الاستشفاء.',
      'Orange, kiwi, strawberries. Protects muscles, speeds recovery.',
      Color(0xFFF59E0B)),
  _NItem('🥤', 'مشروب استشفاء', 'Recovery Shake',
      'لبن + موزة + شوفان + عسل = كوكتيل استشفاء مثالي.',
      'Milk + banana + oats + honey = perfect recovery shake.',
      Color(0xFF8B5CF6)),
  _NItem('🥩', 'كرياتين طبيعي', 'Natural Creatine',
      'اللحمة الحمراء فيها كرياتين. 3-5 جرام مكمل يومياً لو مش بتاكل لحمة كتير.',
      'Red meat has creatine. 3-5g supplement daily if low meat intake.',
      Color(0xFF3B82F6)),
];

const _shootingData = <_NItem>[
  _NItem('🦵', 'قوة الساق', 'Leg Power',
      'بروتين 2 جرام/كيلو + كارب عالي. البطاطا، الرز، الدجاج. الساق محتاجة وقود.',
      '2g protein/kg + high carbs. Potato, rice, chicken. Legs need fuel.',
      Color(0xFF10B981)),
  _NItem('🍌', 'بوتاسيوم قبل التسديد', 'Potassium',
      'موز + مية جوز هند = منع الشد وقت التسديد القوي.',
      'Banana + coconut water = prevent cramps during power shots.',
      Color(0xFFF59E0B)),
  _NItem('🥛', 'كالسيوم للعظام', 'Calcium',
      'التسديد بيرجّع قوة كبيرة على الرجل والكاحل. لبن + جبنة.',
      'Shooting strains leg and ankle. Milk + cheese for strong bones.',
      Color(0xFF3B82F6)),
  _NItem('💧', 'ترطيب قبل التسديد', 'Hydration',
      'جفاف 2% = ضعف قوة 10%. اشرب 500 مل قبل بساعتين.',
      '2% dehydration = 10% strength loss. Drink 500ml 2h before.',
      Color(0xFF0EA5E9)),
  _NItem('🌰', 'ماغنيسيوم', 'Magnesium',
      'لوز، سبانخ، شوكولاتة داكنة. يريح العضلات ويقلل التعب.',
      'Almonds, spinach, dark chocolate. Relaxes muscles, reduces fatigue.',
      Color(0xFF8B5CF6)),
  _NItem('🍳', 'فطار قبل التمرين', 'Pre-Training Breakfast',
      'بيض + شوفان + موز = طاقة + بروتين + بوتاسيوم.',
      'Eggs + oats + banana = energy + protein + potassium.',
      Color(0xFFEF4444)),
];

// ═══════════════════ TIPS ═══════════════════
class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(tr('tipsTitle')),
          backgroundColor: C.card,
          bottom: const TabBar(
            indicatorColor: C.green,
            tabs: [
              Tab(icon: Icon(Icons.bolt_rounded), text: 'شوط صاروخي'),
              Tab(icon: Icon(Icons.sports_handball_rounded), text: 'الحراسة'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _TipsList(items: _shootingTips),
            _TipsList(items: _keeperTips),
          ],
        ),
      ),
    );
  }
}

class _Tip {
  final String icon, titleAr, titleEn, bodyAr, bodyEn;
  const _Tip(this.icon, this.titleAr, this.titleEn, this.bodyAr, this.bodyEn);
}

class _TipsList extends StatelessWidget {
  final List<_Tip> items;
  const _TipsList({required this.items});
  @override
  Widget build(BuildContext context) {
    final isEn = langNotifier.value == 'en';
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final t = items[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: C.card, borderRadius: BorderRadius.circular(16),
            border: Border.all(color: C.green.withValues(alpha: 0.3)),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              leading: Text(t.icon, style: const TextStyle(fontSize: 28)),
              title: Text(isEn ? t.titleEn : t.titleAr,
                  style: const TextStyle(color: C.green, fontWeight: FontWeight.bold, fontSize: 15)),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                Text(isEn ? t.bodyEn : t.bodyAr,
                    style: const TextStyle(color: Colors.white70, height: 1.6, fontSize: 14)),
              ],
            ),
          ),
        );
      },
    );
  }
}

const _shootingTips = <_Tip>[
  _Tip('🎯', '1. اضرب بالرباط (Laces) مش بالوش', '1. Hit with Laces Not Instep',
      'أقوى تسديدة بتيجي من ضربة الكرة بأعلى الحذاء (الرباط). قدمك تتقفل والكاحل يتشدد. ده بيخلي الكرة تطلع زي الصاروخ.',
      'Most powerful shot = strike with laces. Lock your ankle. Ball flies like a rocket.'),
  _Tip('🦵', '2. حركة الـ Follow-Through', '2. Follow-Through',
      'بعد الضربة رجلك تكمل للأمام وللأعلى. تخيل إنك عايز تخبط سقف الغرفة. ده بينقل كل طاقتك للكرة.',
      'After strike, leg continues forward and up. Imagine kicking the ceiling. Transfers all energy to ball.'),
  _Tip('⚖️', '3. قدم الارتكاز', '3. Planting Foot',
      'قدم الارتكاز جانبية للكرة بمسافة شبر وميلها ناحية الهدف. أساس كل قوتك.',
      'Planting foot beside ball palm-width away, pointing at target. Foundation of all power.'),
  _Tip('🌀', '4. لف الحوض', '4. Hip Rotation',
      'القوة من لف الحوض والجسم. افتح كتفك البعيد ولف الحوض بقوة وقت الضربة. قوة ×3.',
      'Power from hip rotation. Open far shoulder, rotate hips explosively. 3x more power.'),
  _Tip('🎽', '5. تقوية الساق', '5. Leg Strength',
      'Squats 4×12، Lunges 3×10، Calf Raises 3×20، Box Jumps 3×8. بعد شهر = فرق رهيب.',
      'Squats 4×12, Lunges 3×10, Calf Raises 3×20, Box Jumps 3×8. One month = huge difference.'),
  _Tip('🎯', '6. الزاوية البعيدة', '6. Far Corner',
      'أقوى تسديدة لو راحت للحارس مش هتفرق. صوّب دايماً على الزاوية البعيدة أو تحت العارضة.',
      'Most powerful shot useless if keeper catches it. Always aim far corner or under crossbar.'),
  _Tip('🏃', '7. التسديد أثناء الجري', '7. Shooting While Running',
      'التسديدة الحقيقية مش من ثبات. اقترب بخطوتين سريعتين، ثبت، وسدّد بدون توقف. زاوية 45° مثالية.',
      'Real shots aren\'t from standstill. Two fast steps, plant, shoot without stopping. 45° approach ideal.'),
  _Tip('🧠', '8. عينك على الكرة', '8. Eyes on Ball',
      'لحظة الضربة عينك على الكرة. الهدف في دماغك. لو بصّيت على الهدف = الكرة تروح بعيد.',
      'At contact moment, eyes on ball. Target in your mind. Looking at goal = ball flies off.'),
];

const _keeperTips = <_Tip>[
  _Tip('🧤', '1. وضعية الاستعداد', '1. Ready Position',
      'قدماك بعرض كتفك، ركبتيك مثنية، وزنك على مقدمة القدم، يديك جانبيك، عينك على المهاجم.',
      'Feet shoulder-width, knees bent, weight on balls, hands at sides, eyes on attacker.'),
  _Tip('⚡', '2. خطوة صغيرة قبل الانقضاض', '2. Small Step Before Dive',
      'قبل ما تنقض خد خطوة صغيرة ناحية اتجاه التسديدة. بتعطيك قوة دفع للانقضاض.',
      'Before diving, small step toward shot direction. Gives explosive push-off.'),
  _Tip('👁️', '3. اقرأ رجل المهاجم', '3. Read Attacker\'s Leg',
      'بصّ على قدم الارتكاز (بتحدد الاتجاه)، فتح كتف المهاجم، اتجاه نظره. توقع التسديدة قبل ما تحصل.',
      'Look at planting foot (direction), shoulder opening, eye direction. Predict the shot.'),
  _Tip('🎯', '4. الكرات العالية', '4. High Balls',
      'اطلع بقدم واحدة، ارفع الركبة التانية، التقف بالكفين (W شكل)، اضم للصدر قبل النزول.',
      'Jump off one foot, raise other knee, catch with W-hands, secure to chest before landing.'),
  _Tip('💪', '5. تمرين القفز', '5. Jump Training',
      'Box Jumps 4×8، Squat Jumps 3×12، Single Leg Hops 3×10، Broad Jumps 3×6. قفزة +10-15 سم بعد شهر.',
      'Box Jumps 4×8, Squat Jumps 3×12, Single Leg Hops 3×10, Broad Jumps 3×6. +10-15cm in a month.'),
  _Tip('🔄', '6. رد الفعل السريع', '6. Fast Reaction',
      'مع زميل: قف مستعد، يقذف كرة فجأة، اتحرك باتجاهها بأقصى سرعة. 15×3.',
      'With partner: ready stance, sudden throw, move at max speed. 15×3.'),
  _Tip('⚖️', '7. توزيع الوزن', '7. Weight Distribution',
      'وزنك على مقدمة القدمين مش الكعب. على الكعب = حركة بطيئة ومش قادر تنقض.',
      'Weight on balls of feet not heels. On heels = slow, can\'t dive.'),
  _Tip('🎽', '8. تمارين المرونة', '8. Flexibility',
      'Split Stretch 5 دقايق يومياً، Hip Flexor، Hamstring، Shoulder Rotation. مرونة = انقضاضات أعرض وأأمن.',
      'Split Stretch 5 min daily, Hip Flexor, Hamstring, Shoulder Rotation. Flexibility = wider, safer dives.'),
];
