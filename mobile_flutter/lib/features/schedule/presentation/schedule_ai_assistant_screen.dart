import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../planner/data/guided_chat_api.dart';

class ScheduleAiTopic {
  const ScheduleAiTopic({required this.id, required this.label, required this.icon});

  final String id;
  final String label;
  final IconData icon;

  static const List<ScheduleAiTopic> all = [
    ScheduleAiTopic(id: 'exam_study', label: 'How to study for the exam', icon: Icons.school_outlined),
    ScheduleAiTopic(id: 'youtube', label: 'YouTube channels to follow', icon: Icons.play_circle_outline),
    ScheduleAiTopic(id: 'books', label: 'Book recommendations', icon: Icons.menu_book_outlined),
    ScheduleAiTopic(id: 'careers', label: 'Career & internship tips', icon: Icons.work_outline),
    ScheduleAiTopic(id: 'projects', label: 'Project ideas', icon: Icons.lightbulb_outline),
  ];
}

enum _ChatPhase { course, topic, done }

class _ChatLine {
  _ChatLine.user(this.text) : isUser = true, isTyping = false;
  _ChatLine.bot(this.text) : isUser = false, isTyping = false;
  _ChatLine.typing() : text = '', isUser = false, isTyping = true;

  final bool isUser;
  final bool isTyping;
  final String text;
}

/// Full-screen guided study chat — button-only flow, catalog courses only.
class ScheduleAiAssistantScreen extends StatefulWidget {
  const ScheduleAiAssistantScreen({super.key});

  @override
  State<ScheduleAiAssistantScreen> createState() => _ScheduleAiAssistantScreenState();
}

class _ScheduleAiAssistantScreenState extends State<ScheduleAiAssistantScreen> {
  final _api = GuidedChatApi();
  final _scroll = ScrollController();
  final _lines = <_ChatLine>[];

  _ChatPhase _phase = _ChatPhase.course;
  List<GuidedChatCourseOption> _courses = [];
  bool _loadingCourses = true;
  String? _selectedCourse;
  String? _selectedCourseName;
  String? _lastSource;
  bool _fetching = false;

  static const _blue = Color(0xFF2563EB);
  static const _purple = Color(0xFF7C3AED);

  @override
  void initState() {
    super.initState();
    _lines.add(_ChatLine.bot(
      'Hi! I\'m your Study Assistant. Pick a course from your profile or synced schedule (system catalog only), then choose a topic.',
    ));
    _loadCourses();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    try {
      final courses = await _api.fetchAllowedCourses();
      if (!mounted) return;
      setState(() {
        _courses = courses..sort((a, b) => a.code.compareTo(b.code));
        _loadingCourses = false;
      });
      if (courses.isEmpty) {
        _addBot(
          'No catalog courses found in your schedule or profile yet. Add lessons to your weekly schedule or update enrolled courses, then try again.',
        );
      } else {
        _addBot('Which course would you like help with?');
      }
      _scrollToEnd();
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingCourses = false);
      _addBot('Could not load your courses. Check your connection and try again.');
      _scrollToEnd();
    }
  }

  void _addUser(String text) {
    setState(() => _lines.add(_ChatLine.user(text)));
    _scrollToEnd();
  }

  void _addBot(String text) {
    setState(() => _lines.add(_ChatLine.bot(text)));
    _scrollToEnd();
  }

  void _addTyping() {
    setState(() => _lines.add(_ChatLine.typing()));
    _scrollToEnd();
  }

  void _removeTyping() {
    setState(() {
      if (_lines.isNotEmpty && _lines.last.isTyping) {
        _lines.removeLast();
      }
    });
  }

  void _scrollToEnd() {
    void jump() {
      if (!_scroll.hasClients) return;
      final target = _scroll.position.maxScrollExtent;
      if (target <= 0) return;
      _scroll.jumpTo(target);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      jump();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        jump();
        Future<void>.delayed(const Duration(milliseconds: 120), jump);
      });
    });
  }

  void _onCoursePicked(GuidedChatCourseOption course) {
    _selectedCourse = course.code;
    _selectedCourseName = course.name;
    final label = course.name.isNotEmpty && course.name != course.code
        ? '${course.code} — ${course.name}'
        : course.code;
    _addUser(label);
    _addBot('Great! What would you like to know about this course?');
    setState(() => _phase = _ChatPhase.topic);
  }

  Future<void> _onTopicPicked(ScheduleAiTopic topic) async {
    final course = _selectedCourse;
    if (course == null || _fetching) return;

    _addUser(topic.label);
    _addTyping();
    setState(() => _fetching = true);

    try {
      final result = await _api.ask(courseCode: course, topic: topic.id);
      if (!mounted) return;
      _removeTyping();
      _lastSource = result.source;
      _addBot(result.message);
      setState(() {
        _fetching = false;
        _phase = _ChatPhase.done;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      _removeTyping();
      _addBot(_friendlyError(e));
      setState(() => _fetching = false);
    } catch (_) {
      if (!mounted) return;
      _removeTyping();
      _addBot('Something went wrong. Please try another topic.');
      setState(() => _fetching = false);
    }
  }

  void _restart() {
    setState(() {
      _phase = _ChatPhase.course;
      _selectedCourse = null;
      _selectedCourseName = null;
      _lastSource = null;
      _fetching = false;
      _lines
        ..clear()
        ..add(_ChatLine.bot(
          'Let\'s start over. Pick a course from your schedule, then choose a topic.',
        ));
      if (_courses.isNotEmpty) {
        _lines.add(_ChatLine.bot('Which course would you like help with?'));
      }
    });
    _scrollToEnd();
  }

  static String _friendlyError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final msg = data['message']?.toString();
      if (msg != null && msg.isNotEmpty) return msg;
    }
    if (e.response?.statusCode == 400) {
      return 'This course is not available in the catalog. Pick another course.';
    }
    return 'I couldn\'t reach the server right now. Try again in a moment.';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0B1220) : const Color(0xFFF3F4F6);
    final surface = isDark ? const Color(0xFF111827) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : const Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [_blue, _purple]),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Study Assistant',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF111827),
                    ),
                  ),
                  Text(
                    'Guided tips for your courses',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (_phase != _ChatPhase.course)
            TextButton(
              onPressed: _fetching ? null : _restart,
              child: const Text('New chat', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
              cacheExtent: 800,
              itemCount: _lines.length,
              itemBuilder: (context, i) => _MessageBubble(
                line: _lines[i],
                isDark: isDark,
                showAiBadge: !_lines[i].isUser &&
                    !_lines[i].isTyping &&
                    i == _lines.length - 1 &&
                    (_lastSource == 'gemini' || _lastSource == 'cache'),
                showOfflineTip: !_lines[i].isUser &&
                    !_lines[i].isTyping &&
                    i == _lines.length - 1 &&
                    (_lastSource == 'scoring' || _lastSource == 'scoring-fallback'),
              ),
            ),
          ),
          _BottomPanel(
            isDark: isDark,
            surface: surface,
            phase: _phase,
            loadingCourses: _loadingCourses,
            fetching: _fetching,
            courses: _courses,
            selectedCourse: _selectedCourse,
            onCourse: _onCoursePicked,
            onTopic: _onTopicPicked,
            onAnotherTopic: () {
              if (_selectedCourse == null) return;
              setState(() => _phase = _ChatPhase.topic);
              _addBot('Pick another topic for $_selectedCourse${_selectedCourseName != null ? ' ($_selectedCourseName)' : ''}:');
            },
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.line,
    required this.isDark,
    required this.showAiBadge,
    required this.showOfflineTip,
  });

  final _ChatLine line;
  final bool isDark;
  final bool showAiBadge;
  final bool showOfflineTip;

  @override
  Widget build(BuildContext context) {
    if (line.isTyping) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _BotAvatar(isDark: isDark),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2937) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                  bottomLeft: Radius.circular(4),
                ),
                border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
              ),
              child: const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2563EB)),
              ),
            ),
          ],
        ),
      );
    }

    final isUser = line.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: _BotAvatar(isDark: isDark),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isUser
                        ? const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF7C3AED)])
                        : null,
                    color: isUser
                        ? null
                        : (isDark ? const Color(0xFF1F2937) : Colors.white),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    border: isUser
                        ? null
                        : Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
                  ),
                  child: isUser
                      ? Text(
                          line.text,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.45,
                            color: Colors.white,
                          ),
                        )
                      : _AiFormattedText(
                          text: line.text,
                          isDark: isDark,
                        ),
                ),
                if (showAiBadge)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome_rounded, size: 11, color: Color(0xFF7C3AED)),
                          SizedBox(width: 4),
                          Text(
                            'Powered by AI',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (showOfflineTip)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 2),
                    child: Text(
                      'Quick tip (AI unavailable — using catalog template)',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _BotAvatar extends StatelessWidget {
  const _BotAvatar({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF7C3AED)]),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14),
    );
  }
}

class _BottomPanel extends StatelessWidget {
  const _BottomPanel({
    required this.isDark,
    required this.surface,
    required this.phase,
    required this.loadingCourses,
    required this.fetching,
    required this.courses,
    required this.selectedCourse,
    required this.onCourse,
    required this.onTopic,
    required this.onAnotherTopic,
  });

  final bool isDark;
  final Color surface;
  final _ChatPhase phase;
  final bool loadingCourses;
  final bool fetching;
  final List<GuidedChatCourseOption> courses;
  final String? selectedCourse;
  final void Function(GuidedChatCourseOption) onCourse;
  final void Function(ScheduleAiTopic) onTopic;
  final VoidCallback onAnotherTopic;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: surface,
      elevation: 8,
      shadowColor: Colors.black26,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (phase == _ChatPhase.course) ...[
                if (loadingCourses)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2563EB)),
                    ),
                  )
                else if (courses.isEmpty)
                  Text(
                    'Add courses in Profile → My courses or your weekly schedule, then return here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                    ),
                  )
                else ...[
                  Text(
                    'Select your course',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: fetching ? null : () => _showCoursePicker(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Ink(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.menu_book_outlined, size: 20, color: Color(0xFF2563EB)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Tap to choose from your schedule & profile',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                ),
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ] else if (phase == _ChatPhase.topic) ...[
                ...ScheduleAiTopic.all.map((topic) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Material(
                      color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      child: ListTile(
                        dense: true,
                        leading: Icon(topic.icon, color: const Color(0xFF2563EB), size: 22),
                        title: Text(
                          topic.label,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF111827),
                          ),
                        ),
                        trailing: const Icon(Icons.north_west_rounded, size: 16, color: Color(0xFF9CA3AF)),
                        onTap: fetching ? null : () => onTopic(topic),
                      ),
                    ),
                  );
                }),
              ] else ...[
                OutlinedButton.icon(
                  onPressed: fetching ? null : onAnotherTopic,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Ask another topic'),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tap choices above — no typing needed',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showCoursePicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF111827) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final screenH = MediaQuery.sizeOf(sheetContext).height;
        final bottomInset = MediaQuery.paddingOf(sheetContext).bottom;
        final sheetH = (screenH * 0.62).clamp(320.0, screenH * 0.88);

        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: SizedBox(
            height: sheetH,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 4, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            'Select your course',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF111827),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(sheetContext),
                        color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 8),
                    itemCount: courses.length,
                    itemBuilder: (_, index) {
                      final c = courses[index];
                      final subtitle = c.name.isNotEmpty && c.name != c.code ? c.name : null;
                      return ListTile(
                        leading: const Icon(Icons.menu_book_outlined, color: Color(0xFF2563EB)),
                        title: Text(
                          c.code,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF111827),
                          ),
                        ),
                        subtitle: subtitle != null
                            ? Text(
                                subtitle,
                                style: TextStyle(
                                  color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                ),
                              )
                            : null,
                        onTap: () {
                          Navigator.pop(sheetContext);
                          onCourse(c);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Renders common AI markdown (bold, bullets) without raw asterisks.
class _AiFormattedText extends StatelessWidget {
  const _AiFormattedText({required this.text, required this.isDark});

  final String text;
  final bool isDark;

  TextStyle get _base => TextStyle(
        fontSize: 14,
        height: 1.5,
        color: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF111827),
      );

  @override
  Widget build(BuildContext context) {
    final lines = _normalizeLines(text);
    final children = <Widget>[];

    for (final trimmed in lines) {
      if (trimmed.isEmpty) {
        children.add(const SizedBox(height: 6));
        continue;
      }

      if (_isBulletLine(trimmed)) {
        children.add(_BulletLine(
          content: _stripBullet(trimmed),
          base: _base,
          isDark: isDark,
        ));
        continue;
      }

      if (trimmed.startsWith('### ')) {
        children.add(Padding(
          padding: const EdgeInsets.only(bottom: 4, top: 2),
          child: Text.rich(
            TextSpan(children: _inlineSpans(trimmed.substring(4), _base.copyWith(fontWeight: FontWeight.w800, fontSize: 15))),
          ),
        ));
        continue;
      }

      if (trimmed.startsWith('## ')) {
        children.add(Padding(
          padding: const EdgeInsets.only(bottom: 4, top: 2),
          child: Text.rich(
            TextSpan(children: _inlineSpans(trimmed.substring(3), _base.copyWith(fontWeight: FontWeight.w800, fontSize: 15))),
          ),
        ));
        continue;
      }

      children.add(Text.rich(TextSpan(children: _inlineSpans(trimmed, _base))));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  static List<String> _normalizeLines(String raw) {
    final out = <String>[];
    for (final line in raw.replaceAll('\r\n', '\n').split('\n')) {
      var t = line.trimRight();
      t = t.replaceAll(RegExp(r'\s*#{1,3}\s*$'), '').trimRight();
      final s = t.trim();
      if (RegExp(r'^#+$').hasMatch(s)) continue;
      if (s.isNotEmpty) out.add(s);
    }
    return out;
  }

  static bool _isBulletLine(String line) {
    if (line.startsWith('* ') || line.startsWith('- ') || line.startsWith('• ')) {
      return true;
    }
    if (RegExp(r'^\*\*[^*]+\*\*').hasMatch(line)) return true;
    return RegExp(r'^\d+\.\s').hasMatch(line);
  }

  static String _stripBullet(String line) {
    if (line.startsWith('* ') || line.startsWith('- ') || line.startsWith('• ')) {
      return line.substring(2).trim();
    }
    if (RegExp(r'^\d+\.\s').hasMatch(line)) {
      return line.replaceFirst(RegExp(r'^\d+\.\s'), '').trim();
    }
    return line;
  }

  static List<InlineSpan> _inlineSpans(String input, TextStyle style) {
    final spans = <InlineSpan>[];
    final parts = input.split('**');
    for (var i = 0; i < parts.length; i++) {
      var chunk = parts[i];
      if (chunk.isEmpty) continue;
      chunk = chunk.replaceAll(RegExp(r'(?<!\*)\*(?!\*)'), '');
      spans.add(TextSpan(
        text: chunk,
        style: i.isOdd ? style.copyWith(fontWeight: FontWeight.w700) : style,
      ));
    }
    if (spans.isEmpty) {
      spans.add(TextSpan(text: input.replaceAll('**', ''), style: style));
    }
    return spans;
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine({
    required this.content,
    required this.base,
    required this.isDark,
  });

  final String content;
  final TextStyle base;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 7),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF7C3AED)]),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(children: _AiFormattedText._inlineSpans(content, base)),
            ),
          ),
        ],
      ),
    );
  }
}
