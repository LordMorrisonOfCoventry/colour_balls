import 'package:colourballs/model/ball.dart';
import 'package:colourballs/model/ball_colour.dart';

/// The model for a tube.
/// Holds a list of [Ball]s which the tube currently contains, and
/// [ballsCapacity], which is the amount of balls the tube can hold.
class Tube {
  final List<Ball> balls;
  final int ballsCapacity;

  Tube(this.balls, this.ballsCapacity);

  Ball? get popTopBall => isNotEmpty ? balls.removeLast() : null;

  bool pushBall(Ball ball) {
    if (isFull) {
      return false;
    }
    balls.add(ball);
    return true;
  }

  bool get isEmpty => balls.isEmpty;

  bool get isNotEmpty => !isEmpty;

  bool get isFull => balls.length == ballsCapacity;

  bool get wouldBeFullWithOneMoreBall => balls.length == (ballsCapacity - 1);

  bool get isCompleted => isFull && _allBallsHaveSameColour;

  BallColour? get ballColourIfAllSame =>
      (isNotEmpty && _allBallsHaveSameColour) ? balls.first.ballColour : null;

  bool get _allBallsHaveSameColour =>
      balls.every((ball) => ball.ballColour == balls.first.ballColour);
}
