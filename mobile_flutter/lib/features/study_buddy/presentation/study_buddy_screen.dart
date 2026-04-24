import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/planner/ai_study_controller.dart';
import '../../reservation/data/reservation_mock_data.dart';
import '../../schedule/data/schedule_api.dart';
import '../../schedule/data/schedule_mock_data.dart';
import '../data/study_buddy_api.dart';
import '../data/study_buddy_mock_data.dart';

/// Figma Make / React `StudyBuddy.tsx` — filtre + GET /study-buddies/suggestions; boşta mock.
class StudyBuddyScreen extends StatefulWidget {
  const StudyBuddyScreen({super.key});

  @override
  State<StudyBuddyScreen> createState() => _StudyBuddyScreenState();
}

class _StudyBuddyScreenState extends State<StudyBuddyScreen> {
  final _api = StudyBuddyApi();
  final _scheduleApi = ScheduleApi();
  String _courseCode = '';
  String _slotId = 'slot-2';
  String _selectedYear = '';
  String _selectedPreference = '';
  int _minMatchScore = 0;
  String? _aiBuddySuggestion;
  String? _suggestedCourseCode;
  String? _suggestedSlotId;
  String? _upcomingExamCourse;
  DateTime? _upcomingExamDate;
  List<StudyBuddyMockRow> _results = [];
  bool _loading = false;
  bool _fromFallback = true;
  bool _showFilters = false;
  bool _showMyListing = false;

  final _myListingNote = TextEditingController();
  String _myListingCourse = '';

  final _reportReason = TextEditingController();
  StudyBuddyMockRow? _reportingBuddy;

  @override
  void initState() {
    super.initState();
    _courseCode = ReservationMockData.courses.isNotEmpty ? ReservationMockData.courses.first.code : 'CSE344';
    _myListingCourse = _courseCode;
    _results = List.of(StudyBuddyMockData.buddies);
    _prepareAiBuddySuggestion();
  }

  @override
  void dispose() {
    _myListingNote.dispose();
    _reportReason.dispose();
    super.dispose();
  }

  void _toast(String m) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  bool _passesLocalFilters(StudyBuddyMockRow row) {
    if (row.matchScore < _minMatchScore) return false;
    if (_selectedYear.isNotEmpty) {
      // Backend v1 response does not include year yet; keep row to avoid hiding valid matches.
    }
    if (_selectedPreference.isNotEmpty) {
      // Backend v1 response does not include preference yet; keep row to avoid hiding valid matches.
    }
    return true;
  }

  Future<void> _prepareAiBuddySuggestion() async {
    final controllerItems = AiStudyController.instance.suggestions;
    String? suggestionMessage;
    String? suggestedCourse;
    String? suggestedSlot;

    if (controllerItems.isNotEmpty) {
      final first = controllerItems.first;
      suggestionMessage = first.message;
      suggestedCourse = first.courseCode;
      suggestedSlot = _slotIdFromLabel(first.slotLabel);
    }

    try {
      final weekly = await _scheduleApi.getWeekly();
      if (!mounted) return;
      final upcomingExam = _nearestUpcomingExam(weekly);
      if (upcomingExam != null) {
        final examCourse = (upcomingExam.courseCode ?? _extractCourseCode(upcomingExam.label) ?? '').toUpperCase();
        final examDate = upcomingExam.examDate;
        if (examCourse.isNotEmpty && examDate != null) {
          suggestionMessage =
              'AI Suggestion: You have a $examCourse exam on ${_formatDate(examDate)}. Find a study buddy for a focused revision session.';
          suggestedCourse = examCourse;
        }
        setState(() {
          _upcomingExamCourse = examCourse.isEmpty ? null : examCourse;
          _upcomingExamDate = examDate;
          _aiBuddySuggestion = suggestionMessage;
          _suggestedCourseCode = suggestedCourse;
          _suggestedSlotId = suggestedSlot;
        });
        return;
      }
    } on DioException {
      // Keep local suggestion fallback.
    } catch (_) {
      // Keep local suggestion fallback.
    }

    setState(() {
      _aiBuddySuggestion = suggestionMessage ?? 'AI Suggestion: Try matching with a buddy for your next tough course this week.';
      _suggestedCourseCode = suggestedCourse;
      _suggestedSlotId = suggestedSlot;
    });
  }

  ScheduleBlock? _nearestUpcomingExam(List<ScheduleBlock> blocks) {
    final today = DateTime.now();
    final nowDate = DateTime(today.year, today.month, today.day);
    final exams = blocks
        .where((b) => b.type == ScheduleBlockType.exam && b.examDate != null)
        .where((b) {
          final d = b.examDate!;
          final examDate = DateTime(d.year, d.month, d.day);
          return !examDate.isBefore(nowDate);
        })
        .toList();
    if (exams.isEmpty) return null;
    exams.sort((a, b) => a.examDate!.compareTo(b.examDate!));
    return exams.first;
  }

  String? _slotIdFromLabel(String? label) {
    if (label == null || label.isEmpty) return null;
    for (final slot in ReservationMockData.timeSlots) {
      if (slot.label == label) return slot.id;
    }
    return null;
  }

  String _formatDate(DateTime d) {
    const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${monthNames[d.month - 1]}';
  }

  String? _extractCourseCode(String? label) {
    if (label == null || label.isEmpty) return null;
    final r = RegExp(r'([A-Z]{2,4})-?(\d{3})').firstMatch(label.toUpperCase());
    if (r == null) return null;
    return '${r.group(1)}${r.group(2)}';
  }

  Future<void> _search() async {
    if (_courseCode.isEmpty) {
      _toast('Select a course');
      return;
    }
    setState(() => _loading = true);
    try {
      final raw = await _api.getSuggestions(courseCode: _courseCode, slotId: _slotId);
      if (!mounted) return;
      if (raw.isEmpty) {
        setState(() {
          _results = StudyBuddyMockData.buddies
              .where((b) => b.commonCourses.any((c) => c == _courseCode))
              .where(_passesLocalFilters)
              .toList();
          if (_results.isEmpty) _results = List.of(StudyBuddyMockData.buddies);
          _fromFallback = true;
          _loading = false;
          _showFilters = false;
        });
        _toast('Server returned no matches, showing sample buddies.');
        return;
      }
      final mapped = raw.map((m) {
        final cc = m['commonCourses'];
        final ct = m['commonTopics'];
        return StudyBuddyMockRow(
          userId: m['userId']?.toString() ?? '',
          name: m['name']?.toString() ?? '',
          matchScore: (m['matchScore'] as num?)?.toInt() ?? 0,
          commonCourses: cc is List ? cc.map((e) => e.toString()).toList() : <String>[],
          commonTopics: ct is List ? ct.map((e) => e.toString()).toList() : <String>[],
        );
      }).toList();
      setState(() {
        _results = mapped.where(_passesLocalFilters).toList();
        _fromFallback = false;
        _loading = false;
        _showFilters = false;
      });
    } on DioException {
      if (!mounted) return;
      setState(() {
        _results = List.of(StudyBuddyMockData.buddies);
        _fromFallback = true;
        _loading = false;
        _showFilters = false;
      });
      _toast('Offline: showing sample buddies.');
    }
  }

  void _openReportDialog(StudyBuddyMockRow buddy) {
    _reportingBuddy = buddy;
    _reportReason.clear();
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Report User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reporting ${buddy.name}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              TextField(
                controller: _reportReason,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Describe inappropriate behavior...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (_reportReason.text.trim().isEmpty) {
                  _toast('Please enter a report reason.');
                  return;
                }
                Navigator.pop(ctx);
                _toast('Report submitted for ${buddy.name}.');
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _submitMyListing() {
    if (_myListingCourse.isEmpty) {
      _toast('Select a course for your listing.');
      return;
    }
    _toast('Listing created for $_myListingCourse.');
    setState(() {
      _showMyListing = false;
      _myListingNote.clear();
    });
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
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Study Buddy',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF111827),
                      ),
                    ),
                    Text(
                      'Find your perfect study partner',
                      style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? const [Color(0xFF1F2937), Color(0xFF111827)]
                          : const [Color(0xFFF5F3FF), Color(0xFFFDF2F8)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFE9D5FF)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How AI matching works',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '• AI matching combines common courses, topics, and study preferences.\n'
                        '• Max 4 students per group rule is enforced on reserve flow.\n'
                        '• Report inappropriate behavior via Report button.',
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.35,
                          color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF6B21A8),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'False reports may result in account restrictions.',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? const [Color(0xFF111827), Color(0xFF1E1B4B)]
                          : const [Color(0xFFEEF2FF), Color(0xFFF5F3FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFC7D2FE)),
                    boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 3))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF7C3AED)]),
                            ),
                            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'AI Suggestion',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF1E1B4B),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1D4ED8) : const Color(0xFFDBEAFE),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Buddy match',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF1E40AF),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _aiBuddySuggestion ??
                            'AI Suggestion: Want to study with someone for your next course session?',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 10),
                      FilledButton(
                        onPressed: () {
                          setState(() {
                            if (_suggestedCourseCode != null && _suggestedCourseCode!.isNotEmpty) {
                              _courseCode = _suggestedCourseCode!;
                            }
                            if (_suggestedSlotId != null && _suggestedSlotId!.isNotEmpty) {
                              _slotId = _suggestedSlotId!;
                            }
                            _showFilters = true;
                          });
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Apply suggestion to filters'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () => setState(() => _showMyListing = !_showMyListing),
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  label: const Text('Create My Study Buddy Listing'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF9333EA),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                if (_showMyListing) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFF5F3FF), Color(0xFFFCE7F3)]),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE9D5FF)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Post your listing', style: TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _myListingCourse.isEmpty ? null : _myListingCourse,
                          decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                          items: ReservationMockData.courses
                              .map((c) => DropdownMenuItem(value: c.code, child: Text('${c.code} - ${c.name}', style: const TextStyle(fontSize: 12))))
                              .toList(),
                          onChanged: (v) => setState(() => _myListingCourse = v ?? ''),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _myListingNote,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            hintText: 'Optional note...',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FilledButton(
                          onPressed: _submitMyListing,
                          child: const Text('Post Listing'),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => setState(() => _showFilters = !_showFilters),
                  icon: Icon(_showFilters ? Icons.expand_less_rounded : Icons.expand_more_rounded),
                  label: Text(_showFilters ? 'Hide Filters' : 'Show Filters'),
                ),
                if (_showFilters) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? const [Color(0xFF111827), Color(0xFF0F172A)]
                            : const [Color(0xFFF8FAFC), Color(0xFFEFF6FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFBFDBFE)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.tune_rounded, size: 18, color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB)),
                            const SizedBox(width: 6),
                            Text(
                              'Smart Filters',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF1E3A8A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text('Course', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _courseCode.isEmpty ? null : _courseCode,
                          decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                          items: ReservationMockData.courses
                              .map((c) => DropdownMenuItem(value: c.code, child: Text(c.code)))
                              .toList(),
                          onChanged: (v) => setState(() => _courseCode = v ?? ''),
                        ),
                        const SizedBox(height: 12),
                        const Text('Academic year (optional)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _selectedYear.isEmpty ? null : _selectedYear,
                          decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                          items: const [
                            DropdownMenuItem(value: '', child: Text('No preference')),
                            DropdownMenuItem(value: 'Freshman', child: Text('Freshman')),
                            DropdownMenuItem(value: 'Sophomore', child: Text('Sophomore')),
                            DropdownMenuItem(value: 'Junior', child: Text('Junior')),
                            DropdownMenuItem(value: 'Senior', child: Text('Senior')),
                          ],
                          onChanged: (v) => setState(() => _selectedYear = v ?? ''),
                        ),
                        const SizedBox(height: 12),
                        const Text('Study style (optional)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _selectedPreference.isEmpty ? null : _selectedPreference,
                          decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                          items: const [
                            DropdownMenuItem(value: '', child: Text('No preference')),
                            DropdownMenuItem(value: 'Silent study', child: Text('Silent study')),
                            DropdownMenuItem(value: 'Discussion-based study', child: Text('Discussion-based')),
                            DropdownMenuItem(value: 'Problem solving together', child: Text('Problem solving')),
                          ],
                          onChanged: (v) => setState(() => _selectedPreference = v ?? ''),
                        ),
                        const SizedBox(height: 12),
                        const Text('Availability window', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _slotId,
                          decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                          items: ReservationMockData.timeSlots
                              .map((s) => DropdownMenuItem(value: s.id, child: Text(s.id, style: const TextStyle(fontSize: 12))))
                              .toList(),
                          onChanged: (v) => setState(() => _slotId = v ?? _slotId),
                        ),
                        const SizedBox(height: 12),
                        const Text('Minimum AI match', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<int>(
                          value: _minMatchScore,
                          decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                          items: const [
                            DropdownMenuItem(value: 0, child: Text('Any score')),
                            DropdownMenuItem(value: 70, child: Text('70% and above')),
                            DropdownMenuItem(value: 80, child: Text('80% and above')),
                            DropdownMenuItem(value: 90, child: Text('90% and above')),
                          ],
                          onChanged: (v) => setState(() => _minMatchScore = v ?? 0),
                        ),
                        const SizedBox(height: 14),
                        FilledButton.icon(
                          onPressed: _loading ? null : _search,
                          icon: _loading
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.search_rounded),
                          label: const Text('Search buddies'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF9333EA),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Results (AI ranked)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    const SizedBox(width: 8),
                    Text('${_results.length} matches', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                  ],
                ),
                const SizedBox(height: 8),
                ..._results.map(
                  (b) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(b.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                                    const Text('Study partner', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(999)),
                                child: Text(
                                  'AI ${b.matchScore}%',
                                  style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF166534), fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'AI score is based on course overlap, topic similarity, and study style fit.',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (_upcomingExamCourse != null &&
                              _upcomingExamDate != null &&
                              b.commonCourses.map((e) => e.toUpperCase()).contains(_upcomingExamCourse)) ...[
                            Text(
                              'Exam overlap: You both have $_upcomingExamCourse focus before ${_formatDate(_upcomingExamDate!)}.',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8),
                              ),
                            ),
                            const SizedBox(height: 6),
                          ],
                          Text(
                            'Common courses: ${b.commonCourses.join(", ")}\n'
                            'Common topics: ${b.commonTopics.take(3).join(", ")}',
                            style: const TextStyle(fontSize: 11, height: 1.35),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () => _toast('Request sent to ${b.name}.'),
                                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                                  label: const Text('Connect'),
                                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF9333EA)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _openReportDialog(b),
                                  icon: const Icon(Icons.flag_outlined, size: 16),
                                  label: const Text('Report'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
