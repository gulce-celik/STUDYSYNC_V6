import 'dart:async' show unawaited;

import 'package:flutter/material.dart';

import '../data/reference_api.dart';
import '../data/registration_mock_data.dart';

/// Figma / React `Onboarding.tsx` — department → year → courses, then pop or finish.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 1;
  String _selectedDepartmentId = '';
  int? _selectedYear;
  final Set<String> _selectedCourseCodes = {};
  bool _coursesOpen = false;
  List<RegistrationDepartment> _departments = List.of(RegistrationMockData.departments);

  void _toast(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  Future<void> _pickDepartment() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Text('Select Department', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              ),
              ..._departments.map((d) {
                return ListTile(
                  title: Text(d.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: _selectedDepartmentId == d.id ? const Icon(Icons.check_circle, color: Color(0xFF2563EB)) : null,
                  onTap: () {
                    setState(() => _selectedDepartmentId = d.id);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _complete() {
    if (_selectedCourseCodes.isEmpty) {
      _toast('Select at least one course.');
      return;
    }
    _toast('Setup completed.');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    String? deptName;
    for (final d in _departments) {
      if (d.id == _selectedDepartmentId) deptName = d.name;
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2563EB), Color(0xFF9333EA), Color(0xFFEC4899)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded, color: Colors.white),
                        ),
                      ],
                    ),
                    const Text('Welcome! 👋', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text("Let's set up your profile", style: TextStyle(color: Colors.blue.shade100, fontSize: 11)),
                    const SizedBox(height: 12),
                    Row(
                      children: List.generate(3, (i) {
                        return Expanded(
                          child: Container(
                            height: 4,
                            margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                            decoration: BoxDecoration(
                              color: _step > i ? Colors.white : Colors.white.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: _step == 1
                        ? _stepDept(deptName)
                        : _step == 2
                            ? _stepYear()
                            : _stepCourses(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepDept(String? deptName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _hdr(Icons.school_rounded, const Color(0xFFDBEAFE), const Color(0xFF2563EB), 'Select Your Department', 'Which program are you enrolled in?'),
        const SizedBox(height: 14),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: () {
              FocusScope.of(context).unfocus();
              unawaited(_pickDepartment());
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      deptName ?? 'Select Department',
                      style: TextStyle(fontWeight: FontWeight.w600, color: deptName == null ? Colors.grey : Colors.black87),
                    ),
                  ),
                  Icon(Icons.expand_more, color: Colors.grey.shade600),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _selectedDepartmentId.isEmpty ? null : () => setState(() => _step = 2),
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2563EB), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }

  Widget _stepYear() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _hdr(Icons.school_rounded, const Color(0xFFE9D5FF), const Color(0xFF9333EA), 'Select Your Year', 'Which year are you currently in?'),
        const SizedBox(height: 14),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.35,
          children: RegistrationMockData.yearLevels.map((y) {
            final sel = _selectedYear == y.id;
            return Material(
              color: sel ? const Color(0xFFF3E8FF) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () => setState(() => _selectedYear = y.id),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: sel ? const Color(0xFF9333EA) : const Color(0xFFE5E7EB), width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${y.id}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: sel ? const Color(0xFF9333EA) : Colors.black87)),
                      Text(y.name, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _step = 1),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text('Back', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: _selectedYear == null ? null : () => setState(() => _step = 3),
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF9333EA), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _stepCourses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _hdr(Icons.menu_book_rounded, const Color(0xFFFCE7F3), const Color(0xFFDB2777), 'Select Your Courses', "Choose courses you're taking this semester"),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFBFDBFE))),
          child: Text('${_selectedCourseCodes.length} course(s) selected', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1E40AF))),
        ),
        const SizedBox(height: 10),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: () => setState(() => _coursesOpen = !_coursesOpen),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE5E7EB), width: 2)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Select Courses', style: TextStyle(fontWeight: FontWeight.w600)),
                  Icon(_coursesOpen ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
        ),
        if (_coursesOpen)
          Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxHeight: 240),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(14)),
            child: ListView(
              shrinkWrap: true,
              children: RegistrationMockData.courses.map((c) {
                final on = _selectedCourseCodes.contains(c.code);
                return ListTile(
                  dense: true,
                  title: Text(c.code, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                  subtitle: Text(c.name, style: const TextStyle(fontSize: 10)),
                  trailing: on ? const Icon(Icons.check_circle, color: Color(0xFFDB2777), size: 20) : null,
                  onTap: () => setState(() {
                    if (on) {
                      _selectedCourseCodes.remove(c.code);
                    } else {
                      _selectedCourseCodes.add(c.code);
                    }
                  }),
                );
              }).toList(),
            ),
          ),
        if (_selectedCourseCodes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _selectedCourseCodes.map((c) => Chip(label: Text(c, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)))).toList(),
            ),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _step = 2),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text('Back', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF9333EA), Color(0xFFEC4899)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: FilledButton(
                  onPressed: _selectedCourseCodes.isEmpty ? null : _complete,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Complete', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _hdr(IconData icon, Color bg, Color fg, String t, String s) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
          child: Icon(icon, color: fg, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              Text(s, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    unawaited(_loadDepartments());
  }

  Future<void> _loadDepartments() async {
    try {
      final remote = await ReferenceApi().getDepartments();
      if (!mounted || remote.isEmpty) return;
      setState(() => _departments = remote);
    } catch (_) {
      // Keep local fallback list.
    }
  }
}
