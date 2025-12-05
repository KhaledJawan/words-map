import 'package:flutter/material.dart';

class BouncyExpandableLevelButton extends StatefulWidget {
  const BouncyExpandableLevelButton({
    super.key,
    required this.levelLabel,
    required this.subOptions,
    required this.onOptionSelected,
  });

  final String levelLabel;
  final List<String> subOptions;
  final void Function(String level, String option) onOptionSelected;

  @override
  State<BouncyExpandableLevelButton> createState() =>
      _BouncyExpandableLevelButtonState();
}

class _BouncyExpandableLevelButtonState
    extends State<BouncyExpandableLevelButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  bool _isExpanded = false;
  String? _lastSelectedOption;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _scale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
        reverseCurve: Curves.easeInCubic,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _handleOptionTap(String option) {
    widget.onOptionSelected(widget.levelLabel, option);
    setState(() {
      _lastSelectedOption = option;
      _isExpanded = false;
      _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutBack,
        padding: EdgeInsets.symmetric(
          horizontal: _isExpanded ? 18 : 14,
          vertical: _isExpanded ? 16 : 8,
        ),
        width: _isExpanded ? 260 : 90,
        decoration: BoxDecoration(
          color: _isExpanded ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(_isExpanded ? 24 : 999),
          border: Border.all(
            color: Colors.black,
            width: 1.4,
          ),
          boxShadow: _isExpanded
              ? [
                  BoxShadow(
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                    color: Colors.black.withOpacity(0.30),
                  ),
                ]
              : [],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: _toggle,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: -1,
                  child: child,
                ),
              );
            },
            child: _isExpanded
                ? _buildExpandedContent()
                : _buildCollapsedContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsedContent() {
    return Column(
      key: const ValueKey('collapsed'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.levelLabel,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        if (_lastSelectedOption != null) ...[
          const SizedBox(height: 2),
          Text(
            _lastSelectedOption!,
            style: TextStyle(
              fontSize: 11,
              color: Colors.black.withOpacity(0.6),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildExpandedContent() {
    return Column(
      key: const ValueKey('expanded'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              widget.levelLabel,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _toggle,
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white70,
                size: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: widget.subOptions.map((option) {
            return InkWell(
              onTap: () => _handleOptionTap(option),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.35),
                    width: 1,
                  ),
                ),
                child: Text(
                  option,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
