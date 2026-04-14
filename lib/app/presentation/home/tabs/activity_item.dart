part of '../home_screen.dart';

// ── ACTIVITY ITEM — Shared between sections ─────────────────────────────────

class _ActivityItem extends StatefulWidget {
  const _ActivityItem({
    super.key,
    required this.activity,
    required this.instance,
    required this.isCompleted,
    required this.isPending,
    required this.isOverdue,
    this.isNextUp = false,
    this.onQuickComplete,
    this.onCompleteWithProof,
    required this.onSkip,
  });

  final dynamic activity;
  final dynamic instance;
  final bool isCompleted;
  final bool isPending;
  final bool isOverdue;
  final bool isNextUp;
  final Future<void> Function()? onQuickComplete;
  final Future<void> Function()? onCompleteWithProof;
  final VoidCallback onSkip;

  @override
  State<_ActivityItem> createState() => _ActivityItemState();
}

class _ActivityItemState extends State<_ActivityItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  _ProcessingAction _processing = _ProcessingAction.none;

  bool get _isProcessing => _processing != _ProcessingAction.none;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleComplete() async {
    if (_isProcessing || widget.isCompleted) return;
    HapticFeedback.lightImpact();
    setState(() => _processing = _ProcessingAction.quickComplete);
    _controller.forward().then((_) => _controller.reverse());
    try {
      await widget.onQuickComplete?.call();
    } finally {
      if (mounted) setState(() => _processing = _ProcessingAction.none);
    }
  }

  Future<void> _handleCaptureComplete() async {
    if (_isProcessing) return;
    HapticFeedback.mediumImpact();
    setState(() => _processing = _ProcessingAction.captureComplete);
    try {
      await widget.onCompleteWithProof?.call();
    } finally {
      if (mounted) setState(() => _processing = _ProcessingAction.none);
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.isOverdue
        ? AppColors.error.withValues(alpha: 0.4)
        : widget.isCompleted
            ? AppColors.primary.withValues(alpha: 0.3)
            : AppColors.surfaceContainerHigh;

    if (widget.isNextUp) return _buildNextUpLayout(context, borderColor);

    final isCheckboxLoading = _processing == _ProcessingAction.quickComplete;
    final isCameraLoading = _processing == _ProcessingAction.captureComplete;

    return ScaleTransition(
      scale: _scale,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: AppSizes.space12),
        padding: const EdgeInsets.all(AppSizes.space16),
        decoration: BoxDecoration(
          color: widget.isCompleted
              ? AppColors.primary.withValues(alpha: 0.05)
              : AppColors.surfaceContainerLow,
          borderRadius: AppSizes.borderRadiusMd,
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: (widget.isPending || widget.isOverdue) && !widget.isCompleted && !_isProcessing
                  ? _handleComplete : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: widget.isCompleted ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.isCompleted
                        ? AppColors.primary
                        : widget.isOverdue ? AppColors.error : AppColors.outlineVariant,
                    width: 2,
                  ),
                ),
                child: isCheckboxLoading
                    ? const SizedBox(
                        width: 14, height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : widget.isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
              ),
            ),
            const SizedBox(width: AppSizes.space16),
            Expanded(
              child: GestureDetector(
                onDoubleTap: widget.isPending && !widget.isCompleted && !_isProcessing && widget.onCompleteWithProof != null
                    ? _handleCaptureComplete : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.activity.title,
                            style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600,
                              color: widget.isCompleted
                                  ? AppColors.onSurfaceVariant : AppColors.onSurface,
                              decoration: widget.isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        if (widget.isPending && !widget.isCompleted && widget.onCompleteWithProof != null)
                          GestureDetector(
                            onTap: _isProcessing ? null : _handleCaptureComplete,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: isCameraLoading
                                    ? LinearGradient(
                                        colors: [AppColors.primary.withValues(alpha: 0.5), AppColors.primaryContainer.withValues(alpha: 0.5)],
                                      )
                                    : const LinearGradient(
                                        colors: [AppColors.primary, AppColors.primaryContainer],
                                      ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: isCameraLoading
                                  ? const SizedBox(
                                      width: 18, height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.camera_alt, size: 14, color: Colors.white),
                                      ],
                                    ),
                            ),
                          ),
                      ],
                    ),
                    if (widget.activity.category != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.activity.category!,
                        style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (widget.activity.currentStreak > 0) ...[
              const SizedBox(width: 8),
              Row(
                children: [
                  Icon(Icons.local_fire_department, size: 14, color: widget.isOverdue ? AppColors.error : AppColors.primary),
                  const SizedBox(width: 2),
                  Text(
                    '${widget.activity.currentStreak}',
                    style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700,
                      color: widget.isOverdue ? AppColors.error : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNextUpLayout(BuildContext context, Color borderColor) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.space12),
        padding: const EdgeInsets.all(AppSizes.space20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSizes.borderRadiusMd,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2.0),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            )
          ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.activity.title,
                    style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                if (widget.activity.currentStreak > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_fire_department, size: 16, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.activity.currentStreak}',
                          style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            if (widget.activity.category != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.activity.category!,
                style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    label: 'Complete now',
                    icon: Icons.check,
                    isPrimary: false,
                    isLoading: _processing == _ProcessingAction.quickComplete,
                    onTap: _handleComplete,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    label: 'Complete + proof',
                    icon: Icons.camera_alt,
                    isPrimary: true,
                    isLoading: _processing == _ProcessingAction.captureComplete,
                    onTap: _handleCaptureComplete,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required bool isPrimary,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _isProcessing ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary ? null : AppColors.surface,
          gradient: isPrimary
              ? const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryContainer],
                )
              : null,
          border: isPrimary ? null : Border.all(color: AppColors.outlineVariant),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isPrimary && !isLoading ? [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ] : [],
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isPrimary ? Colors.white : AppColors.primary,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 16, color: isPrimary ? Colors.white : AppColors.onSurface),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      label, 
                      style: TextStyle(
                        color: isPrimary ? Colors.white : AppColors.onSurface,
                        fontWeight: FontWeight.w700, fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Which action is currently being processed in an [_ActivityItem].
enum _ProcessingAction { none, quickComplete, captureComplete }

