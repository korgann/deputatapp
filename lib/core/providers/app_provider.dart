import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/deputy_model.dart';
import '../models/question_model.dart';
import '../models/post_model.dart';
import '../models/poll_model.dart';
import '../models/meeting_model.dart';
import '../models/notification_model.dart';
import '../utils/profanity_filter.dart';
import '../utils/deputy_binder.dart';

class AppProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _smsCode;

  final List<DeputyModel> _deputies = _initDeputies();
  final List<QuestionModel> _questions = _initQuestions();
  final List<PostModel> _posts = _initPosts();
  final List<PollModel> _polls = _initPolls();
  final List<MeetingModel> _meetings = [];
  final List<NotificationModel> _notifications = _initNotifications();

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  List<DeputyModel> get deputies => List.unmodifiable(_deputies);
  List<QuestionModel> get questions => List.unmodifiable(_questions);
  List<PostModel> get posts => List.unmodifiable(_posts);
  List<PollModel> get polls => List.unmodifiable(_polls);
  List<MeetingModel> get meetings => List.unmodifiable(_meetings);
  List<NotificationModel> get notifications => List.unmodifiable(_notifications);

  int get unreadNotificationsCount => _notifications.where((n) => !n.isRead).length;

  List<DeputyModel> get myDeputies {
    if (_currentUser == null || _currentUser!.isDeputy) return [];
    return DeputyBinder.getDeputiesForUser(
      city: _currentUser!.city,
      region: _currentUser!.region,
      districtNumber: int.tryParse(_currentUser!.district.replaceAll(RegExp(r'[^0-9]'), '')) ?? 6,
      allDeputies: _deputies,
    );
  }

  List<QuestionModel> get myQuestions {
    if (_currentUser == null) return [];
    if (_currentUser!.isDeputy) {
      return _questions.where((q) => q.deputyId == _currentUser!.id).toList();
    }
    return _questions.where((q) => q.voterId == _currentUser!.id).toList();
  }

  List<MeetingModel> get myMeetings {
    if (_currentUser == null) return [];
    if (_currentUser!.isDeputy) {
      return _meetings.where((m) => m.deputyId == _currentUser!.id).toList();
    }
    return _meetings.where((m) => m.voterId == _currentUser!.id).toList();
  }

  List<DeputyModel> get deputiesByRating {
    final sorted = List<DeputyModel>.from(_deputies);
    sorted.sort((a, b) => b.ratingScore.compareTo(a.ratingScore));
    return sorted;
  }

  List<DeputyModel> getTop10Deputies() => deputiesByRating.take(10).toList();

  List<DeputyModel> searchDeputies(String query) {
    if (query.isEmpty) return _deputies;
    final lower = query.toLowerCase();
    return _deputies.where((d) =>
      d.name.toLowerCase().contains(lower) ||
      d.party.toLowerCase().contains(lower) ||
      d.region.toLowerCase().contains(lower) ||
      d.city.toLowerCase().contains(lower),
    ).toList();
  }

  List<QuestionModel> getQuestionsForDeputy(String deputyId) {
    return _questions.where((q) => q.deputyId == deputyId).toList();
  }

  List<PostModel> getPostsForDeputy(String deputyId) {
    return _posts.where((p) => p.deputyId == deputyId).toList();
  }

  // AUTH
  String sendSmsCode(String phone) {
    _smsCode = '1234'; // Mock SMS code
    return _smsCode!;
  }

  bool verifySmsCode(String code) => code == _smsCode;

  UserRole? detectRoleByIin(String iin) {
    if (iin.length != 12) return null;
    // Deputies have IIN starting with '99' (mock rule)
    if (iin.startsWith('99')) return UserRole.deputy;
    return UserRole.voter;
  }

  Future<bool> registerVoter({
    required String name,
    required String phone,
    required String iin,
    required String address,
    required String region,
    required String city,
    required String district,
    required String pin,
  }) async {
    _setLoading(true);
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = UserModel(
      id: 'voter_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      phone: phone,
      iin: iin,
      address: address,
      role: UserRole.voter,
      region: region,
      city: city,
      district: district,
      pinCode: pin,
    );
    _addNotification(
      title: 'Добро пожаловать в ДепутатApp!',
      message: 'Теперь вы можете задавать вопросы депутатам и участвовать в опросах.',
      type: NotificationType.general,
    );
    _setLoading(false);
    return true;
  }

  Future<bool> registerDeputy({
    required String name,
    required String phone,
    required String iin,
    required String address,
    required String region,
    required String city,
    required int districtNumber,
    required String party,
    required String position,
    required String organization,
    required String pin,
  }) async {
    _setLoading(true);
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = UserModel(
      id: 'deputy_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      phone: phone,
      iin: iin,
      address: address,
      role: UserRole.deputy,
      region: region,
      city: city,
      district: 'Округ №$districtNumber',
      pinCode: pin,
      party: party,
      position: position,
      organization: organization,
      districtNumber: districtNumber,
    );
    final deputy = DeputyModel(
      id: _currentUser!.id,
      name: name,
      party: party,
      region: region,
      city: city,
      districtNumber: districtNumber,
      position: position,
      organization: organization,
      level: DeputyLevel.city,
      phone: phone,
      avatarInitials: _getInitials(name),
    );
    _deputies.add(deputy);
    _setLoading(false);
    return true;
  }

  Future<bool> login({required String phone, required String iin, required String pin}) async {
    _setLoading(true);
    await Future.delayed(const Duration(milliseconds: 800));
    // Mock login: check if phone matches any known pattern
    if (phone.length >= 10 && iin.length == 12 && pin.length == 4) {
      final role = detectRoleByIin(iin) ?? UserRole.voter;
      if (role == UserRole.deputy) {
        final deputy = _deputies.isNotEmpty ? _deputies.first : null;
        _currentUser = UserModel(
          id: deputy?.id ?? 'deputy_demo',
          name: deputy?.name ?? 'Ержан Рахимов',
          phone: phone,
          iin: iin,
          address: 'г. Семей, ул. Ауэзова, 1',
          role: UserRole.deputy,
          region: deputy?.region ?? 'Абай область',
          city: deputy?.city ?? 'Семей',
          district: 'Округ №${deputy?.districtNumber ?? 6}',
          pinCode: pin,
          party: deputy?.party ?? 'AMANAT',
          position: deputy?.position ?? 'Депутат городского маслихата',
          organization: deputy?.organization ?? 'ГКП "Транзитеплоком"',
          districtNumber: deputy?.districtNumber ?? 6,
        );
      } else {
        _currentUser = UserModel(
          id: 'voter_demo',
          name: 'Канат Алибаев',
          phone: phone,
          iin: iin,
          address: 'г. Семей, ул. Карменова, 27',
          role: UserRole.voter,
          region: 'Абай область',
          city: 'Семей',
          district: 'Округ №6',
          pinCode: pin,
        );
      }
      _setLoading(false);
      return true;
    }
    _setLoading(false);
    return false;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // QUESTIONS
  void askQuestion({
    required String deputyId,
    required String deputyName,
    required String text,
  }) {
    if (_currentUser == null) return;
    final filtered = ProfanityFilter.filter(text);
    final question = QuestionModel(
      id: 'q_${DateTime.now().millisecondsSinceEpoch}',
      voterId: _currentUser!.id,
      voterName: _currentUser!.name,
      deputyId: deputyId,
      deputyName: deputyName,
      text: filtered,
      createdAt: DateTime.now(),
    );
    _questions.insert(0, question);

    // Notify deputy
    _addNotification(
      title: 'Новый вопрос',
      message: '${_currentUser!.name} задал вам вопрос',
      type: NotificationType.newQuestion,
      targetUserId: deputyId,
    );
    notifyListeners();
  }

  void answerQuestion({
    required String questionId,
    required String answer,
    required bool isCompleted,
  }) {
    final idx = _questions.indexWhere((q) => q.id == questionId);
    if (idx == -1) return;
    final q = _questions[idx];
    final filtered = ProfanityFilter.filter(answer);
    q.answer = filtered;
    q.status = QuestionStatus.answered;
    q.isCompleted = isCompleted;

    // Update deputy rating
    final dIdx = _deputies.indexWhere((d) => d.id == q.deputyId);
    if (dIdx != -1) {
      _deputies[dIdx].totalQuestions++;
      if (isCompleted) _deputies[dIdx].completedQuestions++;
    }

    _addNotification(
      title: 'Депутат ответил на ваш вопрос',
      message: '${q.deputyName} ответил на вопрос: "${q.text.length > 40 ? q.text.substring(0, 40) + '...' : q.text}"',
      type: NotificationType.newAnswer,
      targetUserId: q.voterId,
    );
    notifyListeners();
  }

  void likeQuestion(String questionId) {
    final idx = _questions.indexWhere((q) => q.id == questionId);
    if (idx != -1) {
      _questions[idx].likes++;
      notifyListeners();
    }
  }

  // POSTS
  void createPost({required String title, required String content, List<String> tags = const []}) {
    if (_currentUser == null || !_currentUser!.isDeputy) return;
    final filtered = ProfanityFilter.filter(content);
    final post = PostModel(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      deputyId: _currentUser!.id,
      deputyName: _currentUser!.name,
      title: title,
      content: filtered,
      createdAt: DateTime.now(),
      tags: tags,
    );
    _posts.insert(0, post);
    notifyListeners();
  }

  void likePost(String postId) {
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx != -1) {
      _posts[idx].likes++;
      notifyListeners();
    }
  }

  // POLLS
  void createPoll({
    required String question,
    required List<String> options,
    required DateTime deadline,
  }) {
    if (_currentUser == null || !_currentUser!.isDeputy) return;
    final poll = PollModel(
      id: 'poll_${DateTime.now().millisecondsSinceEpoch}',
      deputyId: _currentUser!.id,
      deputyName: _currentUser!.name,
      question: question,
      options: options.asMap().entries.map((e) =>
        PollOption(id: 'opt_${e.key}', text: e.value)
      ).toList(),
      createdAt: DateTime.now(),
      deadline: deadline,
    );
    _polls.insert(0, poll);
    _addNotification(
      title: 'Новый опрос',
      message: '${_currentUser!.name} создал опрос: "$question"',
      type: NotificationType.newPoll,
    );
    notifyListeners();
  }

  void votePoll({required String pollId, required String optionId}) {
    if (_currentUser == null) return;
    final pIdx = _polls.indexWhere((p) => p.id == pollId);
    if (pIdx == -1) return;
    final poll = _polls[pIdx];
    if (poll.votedUserIds.contains(_currentUser!.id)) return;
    final oIdx = poll.options.indexWhere((o) => o.id == optionId);
    if (oIdx != -1) {
      poll.options[oIdx].votes++;
      poll.votedUserIds = [...poll.votedUserIds, _currentUser!.id];
    }
    notifyListeners();
  }

  // MEETINGS
  void bookMeeting({
    required String deputyId,
    required String deputyName,
    required DateTime date,
    required String time,
    required String purpose,
  }) {
    if (_currentUser == null) return;
    final meeting = MeetingModel(
      id: 'mtg_${DateTime.now().millisecondsSinceEpoch}',
      voterId: _currentUser!.id,
      voterName: _currentUser!.name,
      deputyId: deputyId,
      deputyName: deputyName,
      date: date,
      time: time,
      purpose: purpose,
    );
    _meetings.add(meeting);
    _addNotification(
      title: 'Приём записан',
      message: 'Встреча с $deputyName запланирована на ${_formatDate(date)} в $time',
      type: NotificationType.meetingReminder,
    );
    notifyListeners();
  }

  // NOTIFICATIONS
  void markNotificationRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx].isRead = true;
      notifyListeners();
    }
  }

  void markAllNotificationsRead() {
    for (final n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void _addNotification({
    required String title,
    required String message,
    required NotificationType type,
    String? targetUserId,
  }) {
    final userId = targetUserId ?? _currentUser?.id ?? 'all';
    _notifications.insert(0, NotificationModel(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      title: title,
      message: message,
      type: type,
      createdAt: DateTime.now(),
    ));
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return name.isNotEmpty ? name[0] : '?';
  }

  String _formatDate(DateTime date) => '${date.day}.${date.month}.${date.year}';

  // MOCK DATA INITIALIZERS
  static List<DeputyModel> _initDeputies() {
    return [
      DeputyModel(
        id: 'dep_001',
        name: 'Ержан Рахимов',
        party: 'AMANAT',
        region: 'Абай область',
        city: 'Семей',
        districtNumber: 6,
        position: 'Депутат городского маслихата',
        organization: 'ГКП "Транзитеплоком"',
        level: DeputyLevel.city,
        phone: '+7 701 234 56 78',
        bio: 'Депутат городского маслихата города Семей. Занимается вопросами городской инфраструктуры и жилищно-коммунального хозяйства.',
        avatarInitials: 'ЕР',
        totalQuestions: 45,
        completedQuestions: 38,
        voterRating: 4.5,
        monthlyScore: 92,
        annualScore: 885,
      ),
      DeputyModel(
        id: 'dep_002',
        name: 'Айгерим Нурова',
        party: 'Ak Zhol',
        region: 'Алматинская область',
        city: 'Алматы',
        districtNumber: 3,
        position: 'Депутат областного маслихата',
        organization: 'КазНПУ',
        level: DeputyLevel.regional,
        phone: '+7 702 345 67 89',
        bio: 'Депутат областного маслихата Алматинской области. Специализируется на вопросах образования и молодёжной политики.',
        avatarInitials: 'АН',
        totalQuestions: 62,
        completedQuestions: 55,
        voterRating: 4.7,
        monthlyScore: 95,
        annualScore: 920,
      ),
      DeputyModel(
        id: 'dep_003',
        name: 'Кайрат Жумадилов',
        party: 'AMANAT',
        region: 'Астана',
        city: 'Астана',
        districtNumber: 1,
        position: 'Депутат Курултая',
        organization: 'АО "КазМунайГаз"',
        level: DeputyLevel.kurultai,
        phone: '+7 703 456 78 90',
        bio: 'Депутат Курултая от города Астана. Активно работает над законопроектами в сфере экономики и промышленности.',
        avatarInitials: 'КЖ',
        totalQuestions: 89,
        completedQuestions: 71,
        voterRating: 4.3,
        monthlyScore: 88,
        annualScore: 850,
      ),
      DeputyModel(
        id: 'dep_004',
        name: 'Алия Жибекова',
        party: 'Халық партиясы',
        region: 'Алматинская область',
        city: 'Алматы',
        districtNumber: 5,
        position: 'Депутат районного маслихата',
        organization: 'Карасайский район',
        level: DeputyLevel.district,
        phone: '+7 704 567 89 01',
        bio: 'Депутат районного маслихата. Работает по вопросам здравоохранения и социальной защиты населения.',
        avatarInitials: 'АЖ',
        totalQuestions: 33,
        completedQuestions: 30,
        voterRating: 4.8,
        monthlyScore: 97,
        annualScore: 940,
      ),
      DeputyModel(
        id: 'dep_005',
        name: 'Сергей Иванов',
        party: 'AMANAT',
        region: 'Карагандинская область',
        city: 'Темиртау',
        districtNumber: 2,
        position: 'Депутат городского маслихата',
        organization: 'АО "АрселорМиттал Темиртау"',
        level: DeputyLevel.city,
        phone: '+7 705 678 90 12',
        bio: 'Депутат городского маслихата г. Темиртау. Специализируется на промышленной безопасности и экологии.',
        avatarInitials: 'СИ',
        totalQuestions: 28,
        completedQuestions: 20,
        voterRating: 3.9,
        monthlyScore: 78,
        annualScore: 760,
      ),
      DeputyModel(
        id: 'dep_006',
        name: 'Дамир Сейткали',
        party: 'Ауыл',
        region: 'Абай область',
        city: 'Семей',
        districtNumber: 6,
        position: 'Депутат областного маслихата',
        organization: 'Департамент сельского хозяйства',
        level: DeputyLevel.regional,
        phone: '+7 706 789 01 23',
        bio: 'Депутат областного маслихата Абай области. Защищает интересы сельского населения.',
        avatarInitials: 'ДС',
        totalQuestions: 41,
        completedQuestions: 36,
        voterRating: 4.4,
        monthlyScore: 90,
        annualScore: 870,
      ),
      DeputyModel(
        id: 'dep_007',
        name: 'Мадина Касымова',
        party: 'AMANAT',
        region: 'Астана',
        city: 'Астана',
        districtNumber: 4,
        position: 'Депутат Маслихата города',
        organization: 'Акимат г. Астана',
        level: DeputyLevel.city,
        phone: '+7 707 890 12 34',
        bio: 'Депутат городского маслихата Астаны. Занимается вопросами градостроительства и городского планирования.',
        avatarInitials: 'МК',
        totalQuestions: 57,
        completedQuestions: 50,
        voterRating: 4.6,
        monthlyScore: 93,
        annualScore: 905,
      ),
      DeputyModel(
        id: 'dep_008',
        name: 'Нуржан Бекенов',
        party: 'Халық партиясы',
        region: 'Абай область',
        city: 'Семей',
        districtNumber: 6,
        position: 'Депутат Курултая',
        organization: 'Сенат РК',
        level: DeputyLevel.kurultai,
        phone: '+7 708 901 23 45',
        bio: 'Депутат Курултая от Абай области. Работает над законопроектами в сфере цифровизации и инноваций.',
        avatarInitials: 'НБ',
        totalQuestions: 73,
        completedQuestions: 65,
        voterRating: 4.5,
        monthlyScore: 91,
        annualScore: 880,
      ),
    ];
  }

  static List<QuestionModel> _initQuestions() {
    return [
      QuestionModel(
        id: 'q_001',
        voterId: 'voter_demo',
        voterName: 'Канат Алибаев',
        deputyId: 'dep_001',
        deputyName: 'Ержан Рахимов',
        text: 'Уже несколько недель в нашем районе нет света, а также не работает светофор на перекрёстке Абая-Карменова. Когда это будет исправлено?',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        answer: 'Благодарю за обращение! Мы передали информацию в городской акимат. Вопрос решается, ожидаем замену трансформатора в течение недели. Светофор также включён в план ремонта.',
        status: QuestionStatus.answered,
        isCompleted: true,
        likes: 12,
        category: 'Коммунальные услуги',
      ),
      QuestionModel(
        id: 'q_002',
        voterId: 'voter_001',
        voterName: 'Асель Нурмагамбетова',
        deputyId: 'dep_001',
        deputyName: 'Ержан Рахимов',
        text: 'Можно ли установить знаки парковки во дворе дома по ул. Ауэзова, 15? Машины паркуются на газонах.',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        answer: 'Вы можете установить знаки парковки. Ваш вопрос будет решён в течение недели.',
        status: QuestionStatus.answered,
        isCompleted: true,
        likes: 8,
        category: 'Благоустройство',
      ),
      QuestionModel(
        id: 'q_003',
        voterId: 'voter_002',
        voterName: 'Жанар Сейткали',
        deputyId: 'dep_002',
        deputyName: 'Айгерим Нурова',
        text: 'Когда откроется новая школа в микрорайоне Думан? Дети вынуждены ездить в другой район.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        status: QuestionStatus.inProgress,
        likes: 24,
        category: 'Образование',
      ),
      QuestionModel(
        id: 'q_004',
        voterId: 'voter_003',
        voterName: 'Болат Ахметов',
        deputyId: 'dep_003',
        deputyName: 'Кайрат Жумадилов',
        text: 'Какие меры принимаются для улучшения экологической обстановки в городе? Качество воздуха сильно ухудшилось.',
        createdAt: DateTime.now().subtract(const Duration(hours: 18)),
        status: QuestionStatus.pending,
        likes: 35,
        category: 'Экология',
      ),
      QuestionModel(
        id: 'q_005',
        voterId: 'voter_demo',
        voterName: 'Канат Алибаев',
        deputyId: 'dep_006',
        deputyName: 'Дамир Сейткали',
        text: 'Планируется ли ремонт дороги на ул. Карменова? Ямы очень глубокие, особенно опасно зимой.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        status: QuestionStatus.pending,
        likes: 19,
        category: 'Дороги',
      ),
    ];
  }

  static List<PostModel> _initPosts() {
    return [
      PostModel(
        id: 'post_001',
        deputyId: 'dep_001',
        deputyName: 'Ержан Рахимов',
        title: 'Отчёт о работе за июнь 2026 года',
        content: 'Уважаемые избиратели! Хочу поделиться результатами работы за прошедший месяц.\n\n✅ Решены 38 из 45 поступивших обращений\n✅ Проведено 3 выездных приёма граждан\n✅ Организован ремонт 2 детских площадок\n✅ Добились выделения средств на освещение ул. Карменова\n\nВсе обращения граждан рассматриваются в установленные сроки. Продолжаю работу!',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        likes: 87,
        comments: 12,
        tags: ['отчёт', 'июнь', 'работа'],
      ),
      PostModel(
        id: 'post_002',
        deputyId: 'dep_002',
        deputyName: 'Айгерим Нурова',
        title: 'Новый законопроект об образовании',
        content: 'На сессии областного маслихата был рассмотрен проект по повышению доступности дополнительного образования для детей из малообеспеченных семей. Предлагается выделить дополнительное финансирование кружков и секций в школах.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        likes: 124,
        comments: 28,
        tags: ['образование', 'закон', 'дети'],
      ),
      PostModel(
        id: 'post_003',
        deputyId: 'dep_003',
        deputyName: 'Кайрат Жумадилов',
        title: '6 октября - Республиканский референдум по строительству АЭС',
        content: 'Напоминаю, что 6 октября пройдёт республиканский референдум. Каждый гражданин имеет право высказать своё мнение о строительстве атомной электростанции. Участвуйте в голосовании! Избирательные участки будут открыты с 7:00 до 20:00.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        likes: 256,
        comments: 64,
        tags: ['референдум', 'АЭС', 'голосование'],
      ),
      PostModel(
        id: 'post_004',
        deputyId: 'dep_004',
        deputyName: 'Алия Жибекова',
        title: 'Открытие нового медицинского центра',
        content: 'Рады сообщить, что в нашем районе открылся новый медицинский центр. Теперь жители смогут получать качественную медицинскую помощь без очередей. Работаем для вас!',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        likes: 193,
        comments: 41,
        tags: ['здравоохранение', 'медицина', 'открытие'],
      ),
    ];
  }

  static List<PollModel> _initPolls() {
    return [
      PollModel(
        id: 'poll_001',
        deputyId: 'dep_003',
        deputyName: 'Кайрат Жумадилов',
        question: 'Поддерживаете ли вы строительство атомной электростанции в Казахстане?',
        options: [
          PollOption(id: 'opt_1', text: 'Да, поддерживаю', votes: 1240),
          PollOption(id: 'opt_2', text: 'Нет, не поддерживаю', votes: 870),
          PollOption(id: 'opt_3', text: 'Затрудняюсь ответить', votes: 310),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        deadline: DateTime.now().add(const Duration(days: 8)),
        votedUserIds: [],
      ),
      PollModel(
        id: 'poll_002',
        deputyId: 'dep_001',
        deputyName: 'Ержан Рахимов',
        question: 'Какая проблема наиболее актуальна в нашем округе?',
        options: [
          PollOption(id: 'opt_1', text: 'Состояние дорог', votes: 342),
          PollOption(id: 'opt_2', text: 'Освещение улиц', votes: 218),
          PollOption(id: 'opt_3', text: 'Детские площадки', votes: 189),
          PollOption(id: 'opt_4', text: 'Общественный транспорт', votes: 276),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        deadline: DateTime.now().add(const Duration(days: 25)),
        votedUserIds: [],
      ),
      PollModel(
        id: 'poll_003',
        deputyId: 'dep_002',
        deputyName: 'Айгерим Нурова',
        question: 'Нужна ли новая школа в микрорайоне Думан?',
        options: [
          PollOption(id: 'opt_1', text: 'Да, срочно нужна', votes: 589),
          PollOption(id: 'opt_2', text: 'Можно подождать', votes: 74),
          PollOption(id: 'opt_3', text: 'Лучше расширить существующие', votes: 112),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        deadline: DateTime.now().add(const Duration(days: 27)),
        votedUserIds: [],
      ),
    ];
  }

  static List<NotificationModel> _initNotifications() {
    return [
      NotificationModel(
        id: 'notif_001',
        userId: 'voter_demo',
        title: 'Ответ на ваш вопрос',
        message: 'Ержан Рахимов ответил на ваш вопрос об освещении. Проблема решается.',
        type: NotificationType.newAnswer,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      NotificationModel(
        id: 'notif_002',
        userId: 'voter_demo',
        title: 'Новый опрос',
        message: 'Кайрат Жумадилов создал опрос: "Поддерживаете ли вы строительство АЭС?"',
        type: NotificationType.newPoll,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
      NotificationModel(
        id: 'notif_003',
        userId: 'dep_001',
        title: 'Новый вопрос',
        message: 'Канат Алибаев задал вам вопрос об освещении улиц',
        type: NotificationType.newQuestion,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        isRead: true,
      ),
    ];
  }
}
