import 'package:flutter/material.dart';

const _navy = Color(0xFF12234D);
const _muted = Color(0xFF73809D);
const _canvas = Color(0xFFF3F7FC);
const _line = Color(0xFFE6ECF5);
const _blue = Color(0xFF286BEA);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _canvas,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 950;
            return Row(
              children: [
                Expanded(child: _DashboardContent(compact: compact)),
                _Sidebar(compact: compact),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(compact ? 20 : 38, 24, compact ? 20 : 38, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TopBar(compact: compact),
          const SizedBox(height: 24),
          const _FilterBar(),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 900 ? 3 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _metrics.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: compact ? 1.55 : 1.85,
                ),
                itemBuilder: (context, index) => _MetricCard(metric: _metrics[index]),
              );
            },
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 720) {
                return const Column(
                  children: [
                    _ChartCard(title: 'Membership revenue trend', values: [0.08, 0.08, 0.1, 0.9, 0.08, 0.1, 0.78, 0.08, 0.08]),
                    SizedBox(height: 18),
                    _ChartCard(title: 'New members trend', values: [0.04, 0.04, 0.04, 0.04, 0.04, 0.45, 0.9, 0.04, 0.04]),
                  ],
                );
              }
              return const Row(
                children: [
                  Expanded(child: _ChartCard(title: 'Membership revenue trend', values: [0.08, 0.08, 0.1, 0.9, 0.08, 0.1, 0.78, 0.08, 0.08])),
                  SizedBox(width: 18),
                  Expanded(child: _ChartCard(title: 'New members trend', values: [0.04, 0.04, 0.04, 0.04, 0.04, 0.45, 0.9, 0.04, 0.04])),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dashboard', style: TextStyle(color: _muted, fontSize: 13, fontWeight: FontWeight.w600)),
              SizedBox(height: 5),
              Text('Live gym performance and follow-ups', style: TextStyle(color: _navy, fontSize: 24, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        if (!compact) ...[
          Container(
            width: 190,
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: _line)),
            child: const Row(
              children: [
                Icon(Icons.search, color: _muted, size: 20),
                SizedBox(width: 10),
                Text('Search', style: TextStyle(color: _muted, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _RoundButton(icon: Icons.notifications_none_rounded),
          const SizedBox(width: 10),
          const CircleAvatar(backgroundColor: Color(0xFFE8F0FF), child: Text('P', style: TextStyle(color: _blue, fontWeight: FontWeight.bold))),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Priya Kapoor', style: TextStyle(color: _navy, fontWeight: FontWeight.bold, fontSize: 12)),
              Text('Admin / Owner', style: TextStyle(color: _muted, fontSize: 10)),
            ],
          ),
        ],
      ],
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _line)),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          const _FilterField(label: 'From', value: 'mm/dd/yyyy', icon: Icons.calendar_today_outlined),
          const _FilterField(label: 'To', value: 'mm/dd/yyyy', icon: Icons.calendar_today_outlined),
          const _FilterField(label: 'Branch', value: 'All'),
          const _FilterField(label: 'Plan', value: 'All'),
          const _FilterField(label: 'Trainer', value: 'All'),
          SizedBox(
            height: 42,
            child: FilledButton.icon(
              onPressed: null,
              icon: const Icon(Icons.filter_alt_outlined, size: 18),
              label: const Text('Apply'),
              style: FilledButton.styleFrom(disabledBackgroundColor: _blue, disabledForegroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11))),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterField extends StatelessWidget {
  const _FilterField({required this.label, required this.value, this.icon});

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 142,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 7),
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(color: _canvas, borderRadius: BorderRadius.circular(9)),
            child: Row(
              children: [
                Expanded(child: Text(value, style: const TextStyle(color: _navy, fontSize: 12, fontWeight: FontWeight.w600))),
                Icon(icon ?? Icons.keyboard_arrow_down_rounded, size: 18, color: _muted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric {
  const _Metric(this.title, this.value, this.icon, this.color);

  final String title;
  final String value;
  final IconData icon;
  final Color color;
}

const _metrics = [
  _Metric('Total Members', '5', Icons.groups_2_outlined, Color(0xFFE7F0FF)),
  _Metric('Active Members', '4', Icons.person_outline, Color(0xFFE7F0FF)),
  _Metric('Expired Members', '1', Icons.person_off_outlined, Color(0xFFFFE8E8)),
  _Metric('New Members This Month', '0', Icons.person_add_alt_1_outlined, Color(0xFFE7F0FF)),
  _Metric('Membership Renewals', '2', Icons.autorenew_rounded, Color(0xFFFFF3D7)),
  _Metric("Today's Check-ins", '0', Icons.login_rounded, Color(0xFFE7F0FF)),
  _Metric('Pending Payments', '₹ 9,190', Icons.error_outline_rounded, Color(0xFFFFE8E8)),
  _Metric('Upcoming Classes', '3', Icons.calendar_month_outlined, Color(0xFFE7F0FF)),
  _Metric('Trainer Sessions Today', '0', Icons.event_available_outlined, Color(0xFFFFF3D7)),
  _Metric('New Attendance Members', '5', Icons.show_chart_rounded, Color(0xFFFFE8E8)),
  _Metric('Expiring Plans in 7 Days', '1', Icons.timer_outlined, Color(0xFFFFF3D7)),
  _Metric('Monthly Revenue', '₹ 0', Icons.currency_rupee_rounded, Color(0xFFE7F0FF)),
];

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final _Metric metric;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _line)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(radius: 17, backgroundColor: metric.color, child: Icon(metric.icon, size: 19, color: _blue)),
          Text(metric.title, style: const TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w600)),
          Text(metric.value, style: const TextStyle(color: _navy, fontSize: 23, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.values});

  final String title;
  final List<double> values;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _line)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: _navy, fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Expanded(child: CustomPaint(painter: _ChartPainter(values), child: const SizedBox.expand())),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  const _ChartPainter(this.values);

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 28.0;
    const bottom = 26.0;
    final chart = Rect.fromLTWH(left, 8, size.width - left, size.height - bottom - 8);
    final gridPaint = Paint()..color = _line..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = chart.top + chart.height * i / 3;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), gridPaint);
    }
    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      points.add(Offset(chart.left + chart.width * i / (values.length - 1), chart.bottom - values[i] * chart.height));
    }
    final fillPath = Path()..moveTo(points.first.dx, chart.bottom);
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final control = (points[i - 1].dx + points[i].dx) / 2;
      linePath.cubicTo(control, points[i - 1].dy, control, points[i].dy, points[i].dx, points[i].dy);
      fillPath.lineTo(points[i].dx, points[i].dy);
    }
    fillPath
      ..lineTo(points.last.dx, chart.bottom)
      ..close();
    canvas.drawPath(fillPath, Paint()..color = const Color(0x22286BEA));
    canvas.drawPath(linePath, Paint()..color = _blue..strokeWidth = 2.5..style = PaintingStyle.stroke);
    final dotPaint = Paint()..color = _blue;
    for (final point in points) {
      canvas.drawCircle(point, 3.5, dotPaint);
    }
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    const labels = ['Jun 23', 'Jun 24', 'Jun 25', 'Jun 26', 'Jun 27', 'Jun 28', 'Jun 29', 'Jun 30', 'Jul 01'];
    for (var i = 0; i < labels.length; i++) {
      textPainter.text = TextSpan(text: labels[i], style: const TextStyle(color: _muted, fontSize: 9));
      textPainter.layout();
      textPainter.paint(canvas, Offset(points[i].dx - 16, chart.bottom + 7));
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) {
    if (values.length != oldDelegate.values.length) return true;
    for (var i = 0; i < values.length; i++) {
      if (values[i] != oldDelegate.values[i]) return true;
    }
    return false;
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? 76 : 248,
      decoration: const BoxDecoration(color: Colors.white, border: Border(left: BorderSide(color: _line))),
      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 20, vertical: 24),
      child: Column(
        crossAxisAlignment: compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: compact ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Container(width: 38, height: 38, decoration: BoxDecoration(color: _blue, borderRadius: BorderRadius.circular(11)), child: const Icon(Icons.fitness_center, color: Colors.white, size: 21)),
              if (!compact) ...[
                const SizedBox(width: 10),
                const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('FitCore', style: TextStyle(color: _navy, fontWeight: FontWeight.w800, fontSize: 15)),
                  Text('Wellness Club', style: TextStyle(color: _muted, fontWeight: FontWeight.w600, fontSize: 11)),
                ]),
              ],
            ],
          ),
          const SizedBox(height: 34),
          if (!compact) const Text('MAIN MENU', style: TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          _NavItem(icon: Icons.grid_view_rounded, label: 'Dashboard', selected: true, compact: compact),
          _NavItem(icon: Icons.groups_outlined, label: 'Members', compact: compact),
          _NavItem(icon: Icons.description_outlined, label: 'Member Documents', compact: compact),
          _NavItem(icon: Icons.card_membership_outlined, label: 'Membership Plans', compact: compact),
          _NavItem(icon: Icons.autorenew_rounded, label: 'Subscriptions & Renewals', compact: compact),
          const SizedBox(height: 24),
          if (!compact) const Text('FINANCE', style: TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          _NavItem(icon: Icons.receipt_long_outlined, label: 'Payments, Invoices & Receipts', compact: compact),
          const Spacer(),
          _NavItem(icon: Icons.settings_outlined, label: 'Settings', compact: compact),
          _NavItem(icon: Icons.help_outline_rounded, label: 'Help center', compact: compact),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, this.selected = false, required this.compact});

  final IconData icon;
  final String label;
  final bool selected;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(color: selected ? const Color(0xFFEAF2FF) : Colors.transparent, borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        dense: true,
        visualDensity: const VisualDensity(vertical: -2),
        contentPadding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10),
        leading: Icon(icon, size: 19, color: selected ? _blue : _muted),
        title: compact ? null : Text(label, style: TextStyle(color: selected ? _blue : _muted, fontSize: 12, fontWeight: selected ? FontWeight.w800 : FontWeight.w600)),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: _line)),
      child: Icon(icon, size: 19, color: _muted),
    );
  }
}
