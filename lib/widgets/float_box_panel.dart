import 'package:flutter/material.dart';

enum PanelShape { rectangle, rounded }

enum DockType { inside, outside }

class FloatBoxPanel extends StatefulWidget {
  const FloatBoxPanel({
    super.key,
    required this.positionTop,
    required this.positionLeft,
    required this.backgroundColor,
    required this.contentColor,
    required this.panelShape,
    required this.borderRadius,
    required this.dockType,
    required this.dockOffset,
    required this.panelAnimDuration,
    required this.panelAnimCurve,
    required this.dockAnimDuration,
    required this.dockAnimCurve,
    required this.panelOpenOffset,
    required this.panelIcon,
    required this.size,
    required this.iconSize,
    required this.borderWidth,
    required this.borderColor,
    required this.buttons,
    required this.onPressed,
  });

  final double positionTop;
  final double positionLeft;
  final Color backgroundColor;
  final Color contentColor;
  final PanelShape panelShape;
  final BorderRadius borderRadius;
  final DockType dockType;
  final double dockOffset;
  final int panelAnimDuration;
  final Curve panelAnimCurve;
  final int dockAnimDuration;
  final Curve dockAnimCurve;
  final double panelOpenOffset;
  final IconData panelIcon;
  final double size;
  final double iconSize;
  final double borderWidth;
  final Color borderColor;
  final List<String> buttons;
  final ValueChanged<int> onPressed;

  @override
  State<FloatBoxPanel> createState() => _FloatBoxPanelState();
}

class _FloatBoxPanelState extends State<FloatBoxPanel> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = widget.panelShape == PanelShape.rounded
        ? BorderRadius.circular(widget.size / 2)
        : widget.borderRadius;

    return AnimatedPositioned(
      duration: Duration(milliseconds: widget.dockAnimDuration),
      curve: widget.dockAnimCurve,
      bottom: widget.dockType == DockType.inside ? widget.dockOffset : -2,
      right: widget.dockType == DockType.inside ? widget.dockOffset : -2,
      child: AnimatedContainer(
        duration: Duration(milliseconds: widget.panelAnimDuration),
        curve: widget.panelAnimCurve,
        padding: EdgeInsets.all(widget.borderWidth),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: radius,
          border: Border.all(
            color: widget.borderColor,
            width: widget.borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 6,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              spreadRadius: 0,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (_open)
              Padding(
                padding: EdgeInsets.only(bottom: widget.panelOpenOffset / 2),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: List.generate(widget.buttons.length, (i) {
                    return GestureDetector(
                      onTap: () {
                        widget.onPressed(i);
                        setState(() => _open = false);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Text(
                          widget.buttons[i],
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            GestureDetector(
              onTap: () => setState(() => _open = !_open),
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: widget.contentColor,
                  borderRadius: radius,
                ),
                child: Icon(
                  widget.panelIcon,
                  color: widget.backgroundColor,
                  size: widget.iconSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
