import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

enum DDWindowClass { compact, medium, expanded }

class DDResponsiveSpec {
  const DDResponsiveSpec._({required this.width, required this.height});

  factory DDResponsiveSpec.of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return DDResponsiveSpec._(width: size.width, height: size.height);
  }

  final double width;
  final double height;

  DDWindowClass get windowClass {
    if (width >= AppSizes.breakpointTablet) {
      return DDWindowClass.expanded;
    }
    if (width >= AppSizes.breakpointMobile) {
      return DDWindowClass.medium;
    }
    return DDWindowClass.compact;
  }

  bool get isCompact => windowClass == DDWindowClass.compact;
  bool get isMediumUp => windowClass != DDWindowClass.compact;
  bool get isExpanded => windowClass == DDWindowClass.expanded;
  bool get isShort => height < 720;
  bool get useRailNavigation => width >= 720;

  double get horizontalPadding {
    switch (windowClass) {
      case DDWindowClass.compact:
        return AppSizes.space16;
      case DDWindowClass.medium:
        return AppSizes.space24;
      case DDWindowClass.expanded:
        return AppSizes.space32;
    }
  }

  EdgeInsets pagePadding({
    double top = 0,
    double bottom = 0,
    double? horizontal,
  }) {
    final resolvedHorizontal = horizontal ?? horizontalPadding;
    return EdgeInsets.fromLTRB(
      resolvedHorizontal,
      top,
      resolvedHorizontal,
      bottom,
    );
  }

  double pageMaxWidth({
    double compact = 560,
    double medium = 760,
    double expanded = 1040,
  }) {
    switch (windowClass) {
      case DDWindowClass.compact:
        return compact;
      case DDWindowClass.medium:
        return medium;
      case DDWindowClass.expanded:
        return expanded;
    }
  }

  double gridMaxExtent({
    double compact = 220,
    double medium = 240,
    double expanded = 280,
  }) {
    switch (windowClass) {
      case DDWindowClass.compact:
        return compact;
      case DDWindowClass.medium:
        return medium;
      case DDWindowClass.expanded:
        return expanded;
    }
  }
}

class DDResponsiveCenter extends StatelessWidget {
  const DDResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding = EdgeInsets.zero,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry padding;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final spec = DDResponsiveSpec.of(context);

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? spec.pageMaxWidth()),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class DDResponsiveScrollBody extends StatelessWidget {
  const DDResponsiveScrollBody({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.fillViewport = true,
  });

  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool fillViewport;

  @override
  Widget build(BuildContext context) {
    final spec = DDResponsiveSpec.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: fillViewport
                ? BoxConstraints(minHeight: constraints.maxHeight)
                : const BoxConstraints(),
            child: DDResponsiveCenter(
              maxWidth: maxWidth,
              padding:
                  padding ??
                  spec.pagePadding(
                    top: AppSizes.space16,
                    bottom: AppSizes.space24,
                  ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

SliverGridDelegate ddAdaptiveGridDelegate(
  BuildContext context, {
  double compactExtent = 220,
  double mediumExtent = 240,
  double expandedExtent = 280,
  double mainAxisSpacing = AppSizes.space12,
  double crossAxisSpacing = AppSizes.space12,
  double childAspectRatio = 1,
  double? mainAxisExtent,
}) {
  final spec = DDResponsiveSpec.of(context);

  return SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: spec.gridMaxExtent(
      compact: compactExtent,
      medium: mediumExtent,
      expanded: expandedExtent,
    ),
    mainAxisSpacing: mainAxisSpacing,
    crossAxisSpacing: crossAxisSpacing,
    childAspectRatio: childAspectRatio,
    mainAxisExtent: mainAxisExtent,
  );
}
