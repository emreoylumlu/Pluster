import 'package:flutter/material.dart';
import '../game_models.dart';
import '../localization.dart';
import 'tutorial_step.dart';
import 'tutorial_sandbox_grid.dart';
import 'tutorial_manager.dart';

/// Full-screen semi-transparent overlay that shows interactive tutorial steps.
/// Used for both first-launch onboarding and contextual feature tutorials.
class TutorialOverlay extends StatefulWidget {
  /// The tutorial steps to display.
  final List<TutorialStep> steps;

  /// Current app language for localization.
  final AppLanguage language;

  /// Whether this is a first-launch tutorial (multi-step) or contextual (single step).
  final bool isFirstLaunch;

  /// The tile type that triggered this tutorial (for contextual tutorials).
  final TileType? triggerTileType;

  /// Called when the tutorial is completed or skipped.
  final VoidCallback onComplete;

  const TutorialOverlay({
    super.key,
    required this.steps,
    required this.language,
    this.isFirstLaunch = true,
    this.triggerTileType,
    required this.onComplete,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  bool _stepCompleted = false;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  TutorialStep get _step => widget.steps[_currentStep];
  bool get _isLastStep => _currentStep >= widget.steps.length - 1;

  void _onTilePlaced() {
    setState(() {
      _stepCompleted = true;
    });

    // Log step completed
    if (widget.isFirstLaunch) {
      TutorialManager.instance.onTutorialStepCompleted(
        _currentStep,
        _step.titleKey,
      );
    } else if (widget.triggerTileType != null) {
      TutorialManager.instance.onFeatureTutorialShown(widget.triggerTileType!);
    } else if (_step.featureKey != null) {
      TutorialManager.instance.markFeatureKeySeen(_step.featureKey!);
    }
  }

  void _nextStep() {
    if (_isLastStep) {
      _completeAllSteps();
      return;
    }

    _slideController.reset();
    setState(() {
      _currentStep++;
      _stepCompleted = false;
    });
    _slideController.forward();
  }

  void _skip() {
    if (widget.isFirstLaunch) {
      TutorialManager.instance.onTutorialSkipped(_currentStep);
    } else if (widget.triggerTileType != null) {
      TutorialManager.instance.onFeatureTutorialShown(widget.triggerTileType!);
    } else if (_step.featureKey != null) {
      TutorialManager.instance.markFeatureKeySeen(_step.featureKey!);
    }
    widget.onComplete();
  }

  void _completeAllSteps() {
    if (widget.isFirstLaunch) {
      TutorialManager.instance.markFirstLaunchComplete();
    } else if (widget.triggerTileType != null) {
      TutorialManager.instance.onFeatureTutorialShown(widget.triggerTileType!);
    } else if (_step.featureKey != null) {
      TutorialManager.instance.markFeatureKeySeen(_step.featureKey!);
    }
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(widget.language);
    final screenSize = MediaQuery.of(context).size;

    return FadeTransition(
      opacity: _fadeController,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: screenSize.width,
          height: screenSize.height,
          color: const Color(0xFF070C1A).withValues(alpha: 0.94),
          child: SafeArea(
            child: Column(
              children: [
                // Top header bar (Skip button and dots indicator)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      if (widget.steps.length > 1)
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _buildStepIndicator(),
                          ),
                        )
                      else
                        const Spacer(),
                      _buildSkipButton(loc),
                    ],
                  ),
                ),

                // Scrollable main content
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      key: ValueKey('scroll_step_$_currentStep'),
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title & Description Card
                          SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.04),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _slideController,
                              curve: Curves.easeOutCubic,
                            )),
                            child: _buildDescriptionCard(loc),
                          ),

                          const SizedBox(height: 14),

                          // Sandbox Grid
                          SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.04),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _slideController,
                              curve: Curves.easeOutCubic,
                            )),
                            child: TutorialSandboxGrid(
                              key: ValueKey('sandbox_step_$_currentStep'),
                              initialGrid: _step.gridState,
                              tileToPlace: _step.tileToPlace,
                              targetRow: _step.targetRow,
                              targetCol: _step.targetCol,
                              showEnergyComparison: _step.showEnergyComparison,
                              language: widget.language,
                              specialCells: _step.specialCells,
                              onTilePlaced: _onTilePlaced,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Drag hint or Result text
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _stepCompleted
                                ? _buildResultText(loc)
                                : _buildDragHint(loc),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Next / Got It button pinned at bottom
                if (_stepCompleted)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
                    child: _buildNextButton(loc),
                  )
                else
                  const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton(AppLocalizations loc) {
    return TextButton(
      onPressed: _skip,
      style: TextButton.styleFrom(
        foregroundColor: Colors.white54,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      ),
      child: Text(
        loc.text('tut_skip'),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.steps.length, (i) {
        final isActive = i == _currentStep;
        final isCompleted = i < _currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 22 : 7,
          height: 7,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive
                ? const Color(0xFF00E5FF)
                : isCompleted
                    ? const Color(0xFF00E676)
                    : Colors.white24,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }

  Widget _buildDescriptionCard(AppLocalizations loc) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              loc.text(_step.titleKey),
              style: const TextStyle(
                color: Color(0xFF00E5FF),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loc.text(_step.descriptionKey),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 14,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragHint(AppLocalizations loc) {
    return Text(
      loc.text('tut_try_it'),
      key: const ValueKey('drag_hint'),
      style: TextStyle(
        color: const Color(0xFF00E5FF).withValues(alpha: 0.8),
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildResultText(AppLocalizations loc) {
    final resultKey = _step.resultKey;
    if (resultKey == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        loc.text(resultKey),
        key: const ValueKey('result_text'),
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF00E676),
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildNextButton(AppLocalizations loc) {
    final buttonText = _isLastStep
        ? loc.text('tut_got_it')
        : loc.text('tut_next');

    return Container(
      constraints: const BoxConstraints(maxWidth: 340),
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isLastStep ? _completeAllSteps : _nextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00E5FF),
          foregroundColor: const Color(0xFF070C1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: const Color(0xFF00E5FF).withValues(alpha: 0.5),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            buttonText,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
