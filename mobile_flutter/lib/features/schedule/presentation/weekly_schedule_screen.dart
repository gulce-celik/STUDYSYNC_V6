import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/planner/ai_study_controller.dart';
import '../../../core/session/auth_session.dart';
import '../../auth/data/registration_mock_data.dart';
import '../data/schedule_api.dart';
import '../data/schedule_mock_data.dart';

/// Figma / React `WeeklySchedule.tsx` ile hizalı haftalık ızgara.
class WeeklyScheduleScreen extends StatefulWidget {
  const WeeklyScheduleScreen({super.key});

  @override
  State<WeeklyScheduleScreen> createState() => _WeeklyScheduleScreenState();
}

class _WeeklyScheduleScreenState extends State<WeeklyScheduleScreen> {
  late List<ScheduleBlock> _blocks;
  final _scheduleApi = ScheduleApi();
  bool _loadingRemote = true;
  bool _usedFallback = false;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _blocks = List.from(ScheduleMockData.initialBlocks());
    _purgePastExams();
    AiStudyController.instance.updateSchedule(_blocks);
    _loadFromBackend();
  }

  Future<void> _loadFromBackend() async {
    setState(() {
      _loadingRemote = true;
      _usedFallback = false;
    });
    try {
      final remote = await _scheduleApi.getWeekly();
      if (!mounted) return;
      setState(() {
        if (remote.isNotEmpty) {
          _blocks = remote;
        } else {
          _blocks = List.from(ScheduleMockData.initialBlocks());
          _usedFallback = true;
        }
        _purgePastExams();
        AiStudyController.instance.updateSchedule(_blocks);
        _loadingRemote = false;
      });
    } on DioException {
      if (!mounted) return;
      setState(() {
        _blocks = List.from(ScheduleMockData.initialBlocks());
        _purgePastExams();
        AiStudyController.instance.updateSchedule(_blocks);
        _usedFallback = true;
        _loadingRemote = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _blocks = List.from(ScheduleMockData.initialBlocks());
        _purgePastExams();
        AiStudyController.instance.updateSchedule(_blocks);
        _usedFallback = true;
        _loadingRemote = false;
      });
    }
  }

  Future<void> _syncToBackend() async {
    setState(() => _syncing = true);
    try {
      await _scheduleApi.putWeekly(_blocks);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Schedule saved on server')));
    } on DioException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not sync — check backend and login token')),
      );
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  ScheduleBlock? _blockAt(String day, String time) {
    for (final b in _blocks) {
      if (b.day == day && b.timeSlot == time) return b;
    }
    return null;
  }

  Color _cellColor(ScheduleBlockType? t) {
    switch (t) {
      case ScheduleBlockType.lesson:
        return const Color(0xFFEF4444);
      case ScheduleBlockType.club:
        return const Color(0xFFA855F7);
      case ScheduleBlockType.busy:
        return const Color(0xFFEAB308);
      case ScheduleBlockType.exam:
        return const Color(0xFF0EA5E9);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  void _purgePastExams() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _blocks = _blocks.where((b) {
      if (b.type != ScheduleBlockType.exam || b.examDate == null) return true;
      final d = DateTime(b.examDate!.year, b.examDate!.month, b.examDate!.day);
      return !d.isBefore(today);
    }).toList();
  }

  void _openSheet(String day, String time) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: 24 + MediaQuery.of(ctx).padding.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('$day $time', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                const Text('Select block type', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                const SizedBox(height: 12),
                _typeTile(
                title: 'Lesson',
                subtitle: 'Class schedule',
                color: const Color(0xFFEF4444),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _openLessonDialog(day, time);
                },
              ),
              _typeTile(
                title: 'Club',
                subtitle: 'Club activity',
                color: const Color(0xFFA855F7),
                onTap: () {
                  _setBlock(day, time, ScheduleBlockType.club, 'Club');
                  Navigator.pop(ctx);
                },
              ),
              _typeTile(
                title: 'Busy',
                subtitle: 'Personal time',
                color: const Color(0xFFEAB308),
                onTap: () {
                  _setBlock(day, time, ScheduleBlockType.busy, 'Busy');
                  Navigator.pop(ctx);
                },
              ),
              _typeTile(
                title: 'Exam',
                subtitle: 'Course exam slot',
                color: const Color(0xFF0EA5E9),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _openExamDialog(day, time);
                },
              ),
              ListTile(
                leading: const Icon(Icons.clear_rounded),
                title: const Text('Clear'),
                subtitle: const Text('Remove block'),
                onTap: () {
                  setState(() {
                    _blocks.removeWhere((b) => b.day == day && b.timeSlot == time);
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Slot cleared')));
                },
              ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _typeTile({
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color, child: const Icon(Icons.event, color: Colors.white, size: 20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
        onTap: onTap,
      ),
    );
  }

  void _setBlock(String day, String time, ScheduleBlockType type, String label) {
    setState(() {
      _blocks.removeWhere((b) => b.day == day && b.timeSlot == time);
      _blocks.add(ScheduleBlock(day: day, timeSlot: time, type: type, label: label));
      _purgePastExams();
    });
    AiStudyController.instance.updateSchedule(_blocks);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$day $time → $label')));
  }

  Future<void> _openLessonDialog(String day, String time) async {
    final enrolled = AuthSession.instance.enrolledCourseCodes;
    final userCourses = enrolled.isNotEmpty
        ? RegistrationMockData.courses.where((c) => enrolled.contains(c.code)).toList()
        : RegistrationMockData.courses.toList();
    String? selectedCourse = userCourses.isNotEmpty ? userCourses.first.code : null;
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Lesson'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedCourse,
                      decoration: const InputDecoration(labelText: 'Course', border: OutlineInputBorder()),
                      items: userCourses
                          .map((c) => DropdownMenuItem(value: c.code, child: Text(c.code)))
                          .toList(),
                      onChanged: (v) => setDialogState(() => selectedCourse = v),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                FilledButton(
                  onPressed: () {
                    final code = selectedCourse;
                    if (code == null || code.isEmpty) return;
                    setState(() {
                      _blocks.removeWhere((b) => b.day == day && b.timeSlot == time);
                      _blocks.add(
                        ScheduleBlock(
                          day: day,
                          timeSlot: time,
                          type: ScheduleBlockType.lesson,
                          label: code,
                          courseCode: code,
                        ),
                      );
                      _purgePastExams();
                    });
                    AiStudyController.instance.updateSchedule(_blocks);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$day $time → Lesson ($code)')),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _openExamDialog(String day, String time) async {
    final enrolled = AuthSession.instance.enrolledCourseCodes;
    final userCourses = enrolled.isNotEmpty
        ? RegistrationMockData.courses.where((c) => enrolled.contains(c.code)).toList()
        : RegistrationMockData.courses.toList();
    String? selectedCourse = userCourses.isNotEmpty ? userCourses.first.code : null;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Exam'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                    initialValue: selectedCourse,
                    decoration: const InputDecoration(labelText: 'Course', border: OutlineInputBorder()),
                    items: userCourses
                        .map((c) => DropdownMenuItem(value: c.code, child: Text(c.code)))
                        .toList(),
                    onChanged: (v) => setDialogState(() => selectedCourse = v),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: selectedDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked == null) return;
                      setDialogState(() => selectedDate = picked);
                    },
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text(
                      'Exam Date: ${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                    ),
                  ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                FilledButton(
                  onPressed: () {
                    final code = selectedCourse;
                    if (code == null || code.isEmpty) return;
                    setState(() {
                      _blocks.removeWhere((b) => b.day == day && b.timeSlot == time);
                      _blocks.add(
                        ScheduleBlock(
                          day: day,
                          timeSlot: time,
                          type: ScheduleBlockType.exam,
                          label: 'EXAM-$code',
                          courseCode: code,
                          examDate: selectedDate,
                        ),
                      );
                      _purgePastExams();
                    });
                    AiStudyController.instance.updateSchedule(_blocks);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$day $time → Exam ($code)')),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1220) : Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: isDark ? const Color(0xFF111827) : Colors.white,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 12, 8),
                child: Row(
                  children: [
                    IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.maybePop(context)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Weekly Schedule', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                          const Text('Mark your busy hours', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    ),
                    if (_syncing)
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    else
                      IconButton(
                        tooltip: 'Save to server',
                        icon: const Icon(Icons.cloud_upload_outlined),
                        onPressed: _loadingRemote ? null : _syncToBackend,
                      ),
                    IconButton(
                      tooltip: 'Reload from server',
                      icon: const Icon(Icons.refresh_rounded),
                      onPressed: _loadingRemote ? null : _loadFromBackend,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: const Color(0xFFEFF6FF),
            child: Wrap(
              spacing: 10,
              runSpacing: 6,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _legendDot(const Color(0xFFEF4444), 'Lesson'),
                _legendDot(const Color(0xFFA855F7), 'Club'),
                _legendDot(const Color(0xFFEAB308), 'Busy'),
                _legendDot(const Color(0xFF0EA5E9), 'Exam'),
                _legendDot(const Color(0xFFF3F4F6), 'Free'),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFFFFFBEB),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFFD97706)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tap any time slot to mark it. Add Exam with course+date; expired exams auto-clear and AI avoids exam slots.',
                    style: TextStyle(fontSize: 10, height: 1.35, color: Color(0xFF92400E)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final slots = ScheduleMockData.weeklyTimeSlots;
                final days = ScheduleMockData.weekDays;
                const headerRowHeight = 42.0;
                final maxH = constraints.maxHeight;
                final maxW = constraints.maxWidth;
                final bodyH = (maxH - headerRowHeight).clamp(0.0, double.infinity);
                final rowH = slots.isEmpty ? 40.0 : bodyH / slots.length;

                final nCols = 1 + days.length;
                final minColW = 52.0;
                var colW = maxW / nCols;
                final needsHScroll = colW < minColW;
                if (needsHScroll) colW = minColW;
                final tableW = needsHScroll ? colW * nCols : maxW;

                final labelFont = (rowH * 0.22).clamp(7.0, 11.0);
                final headerFont = (headerRowHeight * 0.22).clamp(9.0, 12.0);
                final timeFont = (rowH * 0.2).clamp(7.0, 10.0);

                Widget gridTable() {
                  return Table(
                    defaultColumnWidth: FixedColumnWidth(colW),
                    border: TableBorder.all(color: const Color(0xFFE5E7EB)),
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(color: Color(0xFFF9FAFB)),
                        children: [
                          _headerCell('Time', headerRowHeight, headerFont),
                          ...days.map((d) => _headerCell(d, headerRowHeight, headerFont)),
                        ],
                      ),
                      ...slots.map((time) {
                        return TableRow(
                          children: [
                            _timeCellSized(time, rowH, timeFont),
                            ...days.map((day) {
                              final b = _blockAt(day, time);
                              return GestureDetector(
                                onTap: () => _openSheet(day, time),
                                child: Container(
                                  height: rowH,
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                  color: _cellColor(b?.type),
                                  child: b?.label != null
                                      ? Text(
                                          b!.label!,
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: labelFont,
                                            fontWeight: FontWeight.w800,
                                            height: 1.05,
                                            color: b.type == ScheduleBlockType.lesson ||
                                                    b.type == ScheduleBlockType.club ||
                                                    b.type == ScheduleBlockType.busy
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        )
                                      : null,
                                ),
                              );
                            }),
                          ],
                        );
                      }),
                    ],
                  );
                }

                final content = SizedBox(
                  width: tableW,
                  height: maxH,
                  child: gridTable(),
                );

                if (needsHScroll) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: content,
                  );
                }
                return content;
              },
            ),
          ),
        ],
      ),
    );
  }

  static Widget _headerCell(String t, double height, double fontSize) {
    return SizedBox(
      height: height,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            t,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
          ),
        ),
      ),
    );
  }

  static Widget _timeCellSized(String t, double height, double fontSize) {
    return Container(
      height: height,
      color: Colors.white,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        t,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600, color: const Color(0xFF6B7280)),
      ),
    );
  }

  static Widget _legendDot(Color c, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: c,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: c == const Color(0xFFF3F4F6) ? const Color(0xFFE5E7EB) : c.darken()),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 9)),
      ],
    );
  }
}

extension on Color {
  Color darken() {
    return Color.lerp(this, Colors.black, 0.12) ?? this;
  }
}
