import 'package:colourballs/model/active_ball_state.dart';
import 'package:colourballs/model/ball.dart';
import 'package:colourballs/model/ball_colour.dart';
import 'package:colourballs/model/game_model.dart';
import 'package:colourballs/model/tube.dart';
import 'package:flutter/material.dart';

/// Displays the tubes and the balls, and reacts to user taps.
class GameplayView extends StatefulWidget {
  final GameModel gameModel;
  final Size viewSize;

  const GameplayView(
    this.gameModel,
    this.viewSize, {
    Key? key,
  }) : super(key: key);

  @override
  State<GameplayView> createState() => _GameplayViewState();
}

class _GameplayViewState extends State<GameplayView>
    with SingleTickerProviderStateMixin {
  final Duration _ballMovementDurationFast = const Duration(milliseconds: 300);
  final Duration _ballMovementDurationSlow = const Duration(milliseconds: 1500);
  final Duration _gameCompletedFlashDuration =
      const Duration(milliseconds: 1000);

  late AnimationController _animationController;
  late Animation<double> _activeBallXAnimation;
  late Animation<double> _activeBallYAnimation;
  late Animation<double> _gameCompletedTubeAnimation;

  double _activeBallXTransitionCompletedFractionUnit = 0;
  double _activeBallYTransitionCompletedFractionUnit = 0;
  Offset _activeBallCenterOffsetForStartPosition = Offset.zero;
  Ball? _activeBall;
  ActiveBallState? _activeBallState;
  Tube? _sourceTube;
  Tube? _targetTube;
  double _tubeOpacity = 0.2;
  bool _tubesAreFlashing = false;

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: _ballMovementDurationFast);

    _activeBallXAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _activeBallXAnimation.addListener(() => setState(() =>
        _activeBallXTransitionCompletedFractionUnit =
            _activeBallXAnimation.value));

    _activeBallYAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _activeBallYAnimation.addListener(() => setState(() =>
        _activeBallYTransitionCompletedFractionUnit =
            _activeBallYAnimation.value));

    _gameCompletedTubeAnimation = Tween<double>(begin: 0.2, end: 0.4).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _gameCompletedTubeAnimation.addListener(() {
      if (_tubesAreFlashing) {
        setState(() => _tubeOpacity = _gameCompletedTubeAnimation.value);
      }
    });
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapUp: (details) => _handleViewTapped(details.localPosition),
        child: CustomPaint(
          painter: GameplayViewPainter(
            widget.gameModel,
            _activeBall,
            _activeBallXTransitionCompletedFractionUnit,
            _activeBallYTransitionCompletedFractionUnit,
            _activeBallCenterOffsetForStartPosition,
            _activeBallState,
            _targetTube,
            _tubeOpacity,
          ),
        ),
      );

  void _handleViewTapped(Offset localTapPosition) {
    if (!_shouldHandleTaps) {
      return;
    }

    Tube? tappedTube = _getTappedTube(localTapPosition);
    if (tappedTube == null) {
      // The tap did not hit any tube, so don't do anything.
      return;
    }

    if (_activeBallState == null) {
      _handleTubeSelectedToPopTopBall(tappedTube);
    } else {
      _handleTubeSelectedToPushActiveBall(_sourceTube!, tappedTube);
    }
  }

  void _handleTubeSelectedToPopTopBall(Tube sourceTube) {
    if (sourceTube.isEmpty) {
      return;
    }

    _animationController.reset();

    _activeBallCenterOffsetForStartPosition =
        _getBallCenterOffsetForTopBallInTube(
            sourceTube, widget.gameModel, widget.viewSize);

    _sourceTube = sourceTube;
    _activeBall = sourceTube.popTopBall;
    _activeBallState = ActiveBallState.beingPopped;

    _animationController
        .forward()
        .whenCompleteOrCancel(() => _activeBallState = ActiveBallState.popped);
  }

  void _handleTubeSelectedToPushActiveBall(Tube sourceTube, Tube targetTube) {
    if (targetTube.isFull || _activeBall == null) {
      return;
    }
    _moveActiveBallToJustAboveTargetTube(_activeBall!, sourceTube, targetTube);
  }

  void _moveActiveBallToJustAboveTargetTube(
      Ball activeBall, Tube sourceTube, Tube targetTubeWithSomeFreeSpace) {
    _activeBallXTransitionCompletedFractionUnit = 0;
    _activeBallCenterOffsetForStartPosition = Offset(
        _getTubeCenterX(sourceTube, widget.gameModel, widget.viewSize),
        _getPoppedBallCenterY(widget.viewSize));
    _animationController.reset();
    _activeBallState = ActiveBallState.beingMovedToJustAboveTargetTube;
    _targetTube = targetTubeWithSomeFreeSpace;
    if (_allTubesWouldBeCompletedIfActiveBallWerePushed) {
      _animationController.duration = _ballMovementDurationSlow;
      _activeBallYAnimation = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
              parent: _animationController, curve: Curves.bounceOut));
    } else {
      _animationController.duration = _ballMovementDurationFast;
      _activeBallYAnimation = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
              parent: _animationController, curve: Curves.easeInBack));
    }
    _sourceTube = null;
    _activeBallYAnimation.addListener(() => setState(() =>
        _activeBallYTransitionCompletedFractionUnit =
            _activeBallYAnimation.value));
    _animationController.forward().whenCompleteOrCancel(
        () => _pushBallIntoTube(activeBall, targetTubeWithSomeFreeSpace));
  }

  void _pushBallIntoTube(Ball ball, Tube targetTubeWithSomeFreeSpace) {
    _animationController.duration = _ballMovementDurationFast;
    _activeBallYAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _animationController, curve: Curves.linearToEaseOut));
    _activeBallYAnimation.addListener(() => setState(() =>
        _activeBallYTransitionCompletedFractionUnit =
            _activeBallYAnimation.value));
    _activeBallYTransitionCompletedFractionUnit = 0;
    _activeBallCenterOffsetForStartPosition = Offset(
        _getTubeCenterX(
            targetTubeWithSomeFreeSpace, widget.gameModel, widget.viewSize),
        _getPoppedBallCenterY(widget.viewSize));
    _animationController.reset();
    _activeBallState = ActiveBallState.beingPushed;
    _targetTube = targetTubeWithSomeFreeSpace;
    _animationController.forward().whenCompleteOrCancel(() {
      targetTubeWithSomeFreeSpace.pushBall(ball);
      _activeBall = null;
      _targetTube = null;
      _activeBallYTransitionCompletedFractionUnit = 0;
      _activeBallState = null;
      if (_gameIsCompleted) {
        _handleGameCompleted();
      }
    });
  }

  bool get _shouldHandleTaps =>
      !_gameIsCompleted &&
      !_tubesAreFlashing &&
      (_activeBallState == null || _activeBallState!.isNotMoving);

  Tube? _getTappedTube(Offset localTapPosition) {
    if (localTapPosition.dy < _getTubeInnerTopY(widget.viewSize) ||
        localTapPosition.dy > _getTubeInnerBottomY(widget.viewSize)) {
      return null;
    }

    int tubeIndex = ((localTapPosition.dx / widget.viewSize.width) *
            widget.gameModel.tubesCount)
        .toInt();

    return widget.gameModel.tubes[tubeIndex];
  }

  bool get _gameIsCompleted => _allTubesAreCompleted();

  bool _allTubesAreCompleted({Tube? tubeToIgnore}) => widget.gameModel.tubes
      .where((tube) => tube != tubeToIgnore && tube.isNotEmpty)
      .every((tube) => tube.isCompleted);

  bool get _allTubesWouldBeCompletedIfActiveBallWerePushed =>
      _targetTube != null && _activeBall != null
          ? _allTubesAreCompleted(tubeToIgnore: _targetTube) &&
              _tubeWouldBeCompletedIfBallWerePushedToIt(
                  _targetTube!, _activeBall!)
          : false;

  bool _tubeWouldBeCompletedIfBallWerePushedToIt(Tube tube, Ball ball) =>
      tube.wouldBeFullWithOneMoreBall &&
      tube.ballColourIfAllSame == ball.ballColour;

  void _handleGameCompleted() {
    _animationController.reset();
    _animationController.duration =
        _getScaledDuration(_gameCompletedFlashDuration, 0.5);
    _tubesAreFlashing = true;
    _animationController.forward().whenCompleteOrCancel(() =>
        _animationController
            .reverse()
            .whenCompleteOrCancel(() => _tubesAreFlashing = false));
  }

  Duration _getScaledDuration(Duration duration, double scalingFactor) =>
      Duration(microseconds: (duration.inMicroseconds * scalingFactor).floor());
}

/// Paints the current state of the game.
class GameplayViewPainter extends CustomPainter {
  final GameModel _gameModel;
  final Ball? _activeBall;
  final double _activeBallXTransitionCompletedFractionUnit;
  final double _activeBallYTransitionCompletedFractionUnit;
  final Offset _activeBallCenterOffsetForStartPosition;
  final ActiveBallState? _activeBallStage;
  final Tube? _targetTube;
  final double _tubeOpacity;

  Size _viewSize = Size.zero;

  GameplayViewPainter(
    this._gameModel,
    this._activeBall,
    this._activeBallXTransitionCompletedFractionUnit,
    this._activeBallYTransitionCompletedFractionUnit,
    this._activeBallCenterOffsetForStartPosition,
    this._activeBallStage,
    this._targetTube,
    this._tubeOpacity,
  );

  @override
  void paint(Canvas canvas, Size size) {
    _viewSize = size;

    _paintActiveBall(canvas);
    _paintTubesWithBalls(canvas);
  }

  void _paintTubesWithBalls(Canvas canvas) => _gameModel.tubes.asMap().forEach(
      (tubeIndex, tube) => _paintTubeWithBalls(tube, tubeIndex, canvas));

  void _paintTubeWithBalls(Tube tube, int tubeIndex, Canvas canvas) {
    _paintSettledBallsForTube(tube, tubeIndex, canvas);
    _paintTube(tubeIndex, canvas);
  }

  void _paintTube(int tubeIndex, Canvas canvas) {
    double tubeCenterX =
        _getTubeCenterXForTubeIndex(tubeIndex, _gameModel, _viewSize);

    Paint tubePaint = Paint()
      ..color = const Color(0xffffffff).withOpacity(_tubeOpacity)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
        RRect.fromLTRBAndCorners(
          tubeCenterX - (_getTubeOuterWidth(_gameModel, _viewSize) / 2),
          _tubeOuterTopY,
          tubeCenterX + (_getTubeOuterWidth(_gameModel, _viewSize) / 2),
          _tubeOuterBottomY,
          bottomLeft:
              Radius.circular(_getTubeOuterWidth(_gameModel, _viewSize) / 2),
          bottomRight:
              Radius.circular(_getTubeOuterWidth(_gameModel, _viewSize) / 2),
        ),
        tubePaint);
  }

  void _paintSettledBallsForTube(Tube tube, int tubeIndex, Canvas canvas) {
    double ballsCenterX =
        _getTubeCenterXForTubeIndex(tubeIndex, _gameModel, _viewSize);
    tube.balls.asMap().forEach((ballIndex, ball) =>
        _paintSettledBall(ball, ballIndex, ballsCenterX, tubeIndex, canvas));
  }

  void _paintSettledBall(
    Ball ball,
    int ballIndex,
    double ballCenterX,
    int tubeIndex,
    Canvas canvas,
  ) =>
      _paintBall(
          ball,
          Offset(
              ballCenterX,
              _getTubeInnerBottomY(_viewSize) -
                  (_getBallDiameter(_gameModel, _viewSize) / 2) -
                  (ballIndex * _getBallDiameter(_gameModel, _viewSize))),
          canvas);

  void _paintActiveBall(Canvas canvas) {
    if (_activeBall == null) {
      return;
    }
    if (_activeBallStage == ActiveBallState.beingPopped ||
        _activeBallStage == ActiveBallState.popped) {
      _paintBallBeingPopped(_activeBall!, canvas);
    } else if (_activeBallStage ==
            ActiveBallState.beingMovedToJustAboveTargetTube &&
        _targetTube != null) {
      _paintBallBeingMovedToJustAboveTargetTube(
          _activeBall!, _targetTube!, canvas);
    } else if (_activeBallStage == ActiveBallState.beingPushed &&
        _targetTube != null) {
      _paintBallBeingPushedIntoTargetTube(_activeBall!, _targetTube!, canvas);
    }
  }

  void _paintBallBeingPopped(Ball ball, Canvas canvas) => _paintBall(
      ball, _ballCenterOffsetForCurrentPositionOfBallBeingPopped, canvas);

  void _paintBallBeingMovedToJustAboveTargetTube(
          Ball ball, Tube targetTube, Canvas canvas) =>
      _paintBall(
          ball,
          _getBallCenterOffsetForCurrentPositionOfBallBeingMovedToJustAboveTargetTube(
              targetTube),
          canvas);

  void _paintBallBeingPushedIntoTargetTube(
      Ball ball, Tube targetTube, Canvas canvas) {
    Offset ballCenterOffset =
        _getBallCenterOffsetForCurrentPositionOfBallBeingPushedIntoTargetTube(
            targetTube);
    _paintBall(ball, ballCenterOffset, canvas);
  }

  void _paintBall(Ball ball, Offset centerOffset, Canvas canvas) =>
      canvas.drawCircle(
          centerOffset,
          _getBallDiameter(_gameModel, _viewSize) / 2,
          _getBallPaint(ball, centerOffset));

  Paint _getBallPaint(Ball ball, Offset offset) {
    RadialGradient gradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      radius: 0.6,
      colors: <Color>[
        _getBaseColorForBallColour(ball.ballColour),
        _darken(_getBaseColorForBallColour(ball.ballColour), 40),
      ],
    );
    return Paint()
      ..shader = gradient.createShader(Rect.fromCenter(
          center: offset,
          width: _getBallDiameter(_gameModel, _viewSize),
          height: _getBallDiameter(_gameModel, _viewSize)));
  }

  Color _darken(Color color, [int percent = 10]) {
    double factor = 1 - percent / 100;
    return Color.fromARGB(
      color.alpha,
      (color.red * factor).round(),
      (color.green * factor).round(),
      (color.blue * factor).round(),
    );
  }

  Color _getBaseColorForBallColour(BallColour ballColour) {
    switch (ballColour) {
      case BallColour.colour1:
        return const Color(0xff55a630);
      case BallColour.colour2:
        return const Color(0xffeb5e28);
      case BallColour.colour3:
        return const Color(0xff9d4edd);
      case BallColour.colour4:
        return const Color(0xffffd166);
      case BallColour.colour5:
        return const Color(0xff5390d9);
      case BallColour.colour6:
        return const Color(0xffe71d36);
      default:
        return const Color(0xffff8fab);
    }
  }

  Offset get _ballCenterOffsetForCurrentPositionOfBallBeingPopped {
    Offset ballCenterOffsetForEndPosition =
        _getBallCenterOffsetForEndPositionOfBallBeingPopped(
            _activeBallCenterOffsetForStartPosition);

    double activeBallCenterTotalYDeltaForTranslation =
        _activeBallCenterOffsetForStartPosition.dy -
            ballCenterOffsetForEndPosition.dy;
    double activeBallCenterYForCurrentPosition =
        _activeBallCenterOffsetForStartPosition.dy -
            (activeBallCenterTotalYDeltaForTranslation *
                _activeBallYTransitionCompletedFractionUnit);
    return Offset(_activeBallCenterOffsetForStartPosition.dx,
        activeBallCenterYForCurrentPosition);
  }

  Offset
      _getBallCenterOffsetForCurrentPositionOfBallBeingMovedToJustAboveTargetTube(
          Tube targetTube) {
    Offset ballCenterOffsetForEndPosition =
        _getBallCenterOffsetForEndPositionOfBallBeingMovedToJustAboveTargetTube(
            targetTube);

    double activeBallCenterTotalXDeltaForTranslation =
        _activeBallCenterOffsetForStartPosition.dx -
            ballCenterOffsetForEndPosition.dx;

    double activeBallCenterTotalYDeltaForTranslation =
        _activeBallCenterOffsetForStartPosition.dy -
            ballCenterOffsetForEndPosition.dy;

    return Offset(
        (_activeBallCenterOffsetForStartPosition.dx -
            (activeBallCenterTotalXDeltaForTranslation *
                _activeBallXTransitionCompletedFractionUnit)),
        (_activeBallCenterOffsetForStartPosition.dy -
            (activeBallCenterTotalYDeltaForTranslation *
                _activeBallYTransitionCompletedFractionUnit)));
  }

  Offset _getBallCenterOffsetForCurrentPositionOfBallBeingPushedIntoTargetTube(
      Tube targetTube) {
    Offset ballCenterOffsetForStartPosition =
        _getBallCenterOffsetForBallJustAboveTube(targetTube);

    Offset ballCenterOffsetForEndPosition =
        _getBallCenterOffsetForEndPositionOfBallBeingPushedIntoTargetTube(
            targetTube);

    double ballCenterTotalYDeltaForTranslation =
        ballCenterOffsetForStartPosition.dy - ballCenterOffsetForEndPosition.dy;

    return Offset(
        ballCenterOffsetForStartPosition.dx,
        (ballCenterOffsetForStartPosition.dy -
            (ballCenterTotalYDeltaForTranslation *
                _activeBallYTransitionCompletedFractionUnit)));
  }

  Offset _getBallCenterOffsetForEndPositionOfBallBeingPopped(
          Offset ballCenterOffsetForStartPosition) =>
      Offset(ballCenterOffsetForStartPosition.dx,
          _getPoppedBallCenterY(_viewSize));

  Offset
      _getBallCenterOffsetForEndPositionOfBallBeingMovedToJustAboveTargetTube(
              Tube targetTube) =>
          _getBallCenterOffsetForBallJustAboveTube(targetTube);

  Offset _getBallCenterOffsetForEndPositionOfBallBeingPushedIntoTargetTube(
          Tube targetTube) =>
      _getBallCenterOffsetForNextBallInTube(targetTube, _gameModel, _viewSize);

  Offset _getBallCenterOffsetForNextBallInTube(
          Tube tube, GameModel gameModel, Size viewSize) =>
      _getBallCenterOffsetForTopBallInTube(tube, gameModel, viewSize)
          .translate(0, -_getBallDiameter(gameModel, viewSize));

  Offset _getBallCenterOffsetForBallJustAboveTube(Tube tube) {
    double ballCenterY = _getTubeInnerTopY(_viewSize) -
        (0.5 * _getBallDiameter(_gameModel, _viewSize));
    return Offset(_getTubeCenterX(tube, _gameModel, _viewSize), ballCenterY);
  }

  double get _tubeOuterTopY => _getTubeInnerTopY(_viewSize) - _tubeThickness;

  double get _tubeOuterBottomY =>
      _getTubeInnerBottomY(_viewSize) + _tubeThickness;

  double _getTubeOuterWidth(GameModel gameModel, Size viewSize) =>
      _getTubeInnerWidth(gameModel, viewSize) + (_tubeThickness * 2);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// Common code.

const double _tubeThickness = 6;

double _getTubeInnerTopY(Size viewSize) => viewSize.height * 5 / 16;

double _getTubeInnerBottomY(Size viewSize) => viewSize.height - _tubeThickness;

double _getTubeCenterX(Tube tube, GameModel gameModel, Size viewSize) =>
    _getTubeCenterXForTubeIndex(
        gameModel.tubes.indexOf(tube), gameModel, viewSize);

double _getTubeCenterXForTubeIndex(
        int tubeIndex, GameModel gameModel, Size viewSize) =>
    (viewSize.width / gameModel.tubesCount) * (tubeIndex + 0.5);

double _getTubeInnerWidth(GameModel gameModel, Size viewSize) =>
    (_getTubeInnerBottomY(viewSize) - _getTubeInnerTopY(viewSize)) /
    gameModel.tubeBallsCapacity;

double _getBallDiameter(GameModel gameModel, Size viewSize) =>
    _getTubeInnerWidth(gameModel, viewSize);

double _getPoppedBallCenterY(Size viewSize) => viewSize.height * 1 / 16;

Offset _getBallCenterOffsetForTopBallInTube(
    Tube tube, GameModel gameModel, Size viewSize) {
  double topBallCenterX = _getTubeCenterX(tube, gameModel, viewSize);
  double topBallCenterY = _getTubeInnerBottomY(viewSize) -
      (tube.balls.length * _getBallDiameter(gameModel, viewSize)) +
      (_getBallDiameter(gameModel, viewSize) * 0.5);
  return Offset(topBallCenterX, topBallCenterY);
}
