import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:word_map_app/l10n/app_localizations.dart';

class HomeSupportBanner extends StatefulWidget {
  const HomeSupportBanner({
    super.key,
    required this.onSupport,
    required this.onDismissed,
    this.autoHideDuration = const Duration(seconds: 10),
  });

  final Future<void> Function() onSupport;
  final VoidCallback onDismissed;
  final Duration autoHideDuration;

  @override
  State<HomeSupportBanner> createState() => _HomeSupportBannerState();
}

class _HomeSupportBannerState extends State<HomeSupportBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  Timer? _autoTimer;
  bool _dismissing = false;
  bool _started = false;
  bool _reducedMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _started = true;
      _show();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mq = MediaQuery.maybeOf(context);
    final reduced = (mq?.disableAnimations ?? false) || (mq?.accessibleNavigation ?? false);
    if (_reducedMotion != reduced) {
      _reducedMotion = reduced;
      _controller.duration = _reducedMotion
          ? Duration.zero
          : const Duration(milliseconds: 280);
    }
  }

  Future<void> _show() async {
    if (!mounted || !_started) return;
    await _controller.forward();
    _autoTimer?.cancel();
    _autoTimer = Timer(widget.autoHideDuration, () async {
      await _dismiss();
    });
  }

  Future<void> _dismiss() async {
    if (_dismissing) return;
    _dismissing = true;
    _autoTimer?.cancel();
    if (!mounted) return;
    await _controller.reverse();
    if (!mounted) return;
    widget.onDismissed();
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final lottieSize = width < 340 ? 104.0 : 120.0;
        final bodyMaxLines = width < 320 ? 2 : 3;

        return SlideTransition(
          position: _slide,
          child: FadeTransition(
            opacity: _fade,
            child: Material(
              color: Colors.transparent,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  PositionedDirectional(
                    start: -10,
                    top: -(lottieSize * 0.72),
                    child: SizedBox(
                      width: lottieSize,
                      height: lottieSize,
                      child: IgnorePointer(
                        child: Lottie.asset(
                          'assets/lottie/waving.json',
                          repeat: true,
                          animate: !_reducedMotion,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          cs.surface.withValues(alpha: 0.99),
                          cs.surfaceContainerHighest.withValues(alpha: 0.92),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: cs.shadow.withValues(alpha: 0.10),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.50),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  loc.homeSupportTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () async => await _dismiss(),
                                tooltip: loc.homeSupportCloseTooltip,
                                visualDensity: VisualDensity.compact,
                                constraints: const BoxConstraints.tightFor(
                                  width: 40,
                                  height: 40,
                                ),
                                icon: const Icon(Icons.close_rounded),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            loc.homeSupportBody,
                            maxLines: bodyMaxLines,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              height: 1.20,
                              color: theme.textTheme.bodySmall?.color?.withValues(
                                alpha: 0.88,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: FilledButton.tonalIcon(
                                onPressed: () async {
                                  _autoTimer?.cancel();
                                  await _dismiss();
                                  await widget.onSupport();
                                },
                                icon: const Icon(
                                  LucideIcons.gem,
                                  size: 18,
                                ),
                                label: Text(loc.homeSupportSupportButton),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  textStyle: theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
