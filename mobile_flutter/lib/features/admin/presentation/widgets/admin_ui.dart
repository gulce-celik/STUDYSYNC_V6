import 'package:flutter/material.dart';

/// Admin console — navy/slate palette (distinct from student purple-pink hero).
abstract final class AdminUi {
  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F172A), Color(0xFF1E3A8A), Color(0xFF1E40AF)],
  );

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E3A8A), Color(0xFF1E40AF), Color(0xFF312E81)],
  );

  static const accentGradient = LinearGradient(
    colors: [Color(0xFF1E40AF), Color(0xFF4338CA)],
  );

  static const scaffoldBg = Color(0xFFF1F5F9);
  static const cardRadius = 16.0;

  static InputBorder inputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 2),
    );
  }
}

class AdminKpiCard extends StatelessWidget {
  const AdminKpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AdminUi.cardRadius),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, maxLines: 1, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          ),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, height: 1.2, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

/// Sun–Sat chips; short labels to avoid horizontal overflow.
class AdminWeekDayPicker extends StatelessWidget {
  const AdminWeekDayPicker({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _short = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const _full = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: List.generate(7, (i) {
          final selected = i == selectedIndex;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: i == 0 ? 0 : 4),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onSelected(i),
                  borderRadius: BorderRadius.circular(10),
                  child: Ink(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: selected ? AdminUi.accentGradient : null,
                      color: selected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: selected ? Colors.transparent : const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _short[i],
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: selected ? Colors.white : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _full[i],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: selected ? const Color(0xFFDBEAFE) : const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class AdminBarChart extends StatelessWidget {
  const AdminBarChart({
    super.key,
    required this.values,
    required this.labels,
    this.highlightIndex,
  });

  final List<int> values;
  final List<String> labels;
  final int? highlightIndex;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();
    final max = values.reduce((a, b) => a > b ? a : b).clamp(1, 100);
    return SizedBox(
      height: 118,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(values.length, (i) {
          final v = values[i];
          final h = (v / max) * 64;
          final hot = highlightIndex == i;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '$v',
                    maxLines: 1,
                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 2),
                  Flexible(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 280),
                        height: h.clamp(6.0, 64.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: hot
                              ? AdminUi.accentGradient
                              : const LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [Color(0xFF93C5FD), Color(0xFFDBEAFE)],
                                ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    labels[i].length > 3 ? labels[i].substring(0, 3) : labels[i],
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: hot ? FontWeight.w800 : FontWeight.w600,
                      color: hot ? const Color(0xFF1E40AF) : const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class AdminDonutStat extends StatelessWidget {
  const AdminDonutStat({
    super.key,
    required this.percent,
    required this.label,
    this.onDarkBackground = false,
  });

  final int percent;
  final String label;

  /// Use on navy hero cards so the center label stays readable.
  final bool onDarkBackground;

  @override
  Widget build(BuildContext context) {
    final ringBg = onDarkBackground ? Colors.white.withValues(alpha: 0.22) : const Color(0xFFE2E8F0);
    final ringFg = onDarkBackground ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF);
    final percentStyle = TextStyle(
      fontWeight: FontWeight.w800,
      fontSize: 16,
      color: onDarkBackground ? Colors.white : const Color(0xFF0F172A),
      height: 1.1,
    );
    final labelStyle = TextStyle(
      fontSize: 9,
      fontWeight: FontWeight.w700,
      color: onDarkBackground ? const Color(0xFFDBEAFE) : Colors.grey.shade600,
    );

    return Container(
      width: 88,
      height: 88,
      padding: const EdgeInsets.all(4),
      decoration: onDarkBackground
          ? BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
            )
          : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: CircularProgressIndicator(
              value: (percent.clamp(0, 100)) / 100,
              strokeWidth: 7,
              backgroundColor: ringBg,
              color: ringFg,
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$percent%', style: percentStyle),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: labelStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AdminSectionTitle extends StatelessWidget {
  const AdminSectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Row(
        children: [
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class AdminSurfaceCard extends StatelessWidget {
  const AdminSurfaceCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AdminUi.cardRadius),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }
}
