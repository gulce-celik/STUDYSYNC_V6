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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
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
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              itemCount: _lines.length,
              itemBuilder: (context, i) => _MessageBubble(
                line: _lines[i],
                isDark: isDark,
                showAiBadge: ! _lines[i].isUser &&
                    ! _lines[i].isTyping &&
                    i == _lines.length - 1 &&
                    _lastSource == 'gemini',
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
  });

  final _ChatLine line;
  final bool isDark;
  final bool showAiBadge;

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
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            _BotAvatar(isDark: isDark),
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
                  child: Text(
                    line.text,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: isUser ? Colors.white : (isDark ? const Color(0xFFE5E7EB) : const Color(0xFF111827)),
                    ),
                  ),
                ),
                if (showAiBadge)
                  const Padding(
                    padding: EdgeInsets.only(top: 4, left: 4),
                    child: Text('Powered by AI', style: TextStyle(fontSize: 10, color: Color(0xFF2563EB))),
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
                  const Center(child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ))
                else if (courses.isEmpty)
                  Text(
                    'Sync your schedule to unlock course tips.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: courses.map((c) {
                      return ActionChip(
                        avatar: const Icon(Icons.menu_book_outlined, size: 16, color: Color(0xFF2563EB)),
                        label: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(c.code, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                            if (c.name.isNotEmpty && c.name != c.code)
                              Text(
                                c.name,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                ),
                              ),
                          ],
                        ),
                        onPressed: fetching ? null : () => onCourse(c),
                      );
                    }).toList(),
                  ),
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
}
