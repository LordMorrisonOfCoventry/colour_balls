import 'package:colourballs/model/ball.dart';
import 'package:colourballs/model/ball_colour.dart';
import 'package:colourballs/model/game_model.dart';
import 'package:colourballs/model/tube.dart';

/// Provides a [GameModel] which represents a fully completed game.
/// Mostly used as a sub provider by other implementations of
/// [GameModelProvider] which want to provide nearly completed game models for
/// testing purposes.
class CompletedGameModelProvider implements GameModelProvider {
  @override
  GameModel getNewGameModel({required int tubeBallsCapacity}) {
    List<Ball> allBalls = [];
    for (BallColour ballColour in BallColour.values) {
      allBalls.addAll(List<Ball>.filled(tubeBallsCapacity, Ball(ballColour)));
    }
    Tube tube1 = _getTube(0, allBalls, tubeBallsCapacity);
    Tube tube2 = _getTube(1, allBalls, tubeBallsCapacity);
    Tube tube3 = _getTube(2, allBalls, tubeBallsCapacity);
    Tube tube4 = _getTube(3, allBalls, tubeBallsCapacity);
    Tube tube5 = _getTube(4, allBalls, tubeBallsCapacity);
    Tube tube6 = _getTube(5, allBalls, tubeBallsCapacity);
    Tube tube7 = _getTube(6, allBalls, tubeBallsCapacity);
    Tube tube8 = Tube([], tubeBallsCapacity);

    return GameModel(
      [tube1, tube2, tube3, tube4, tube5, tube6, tube7, tube8],
      tubeBallsCapacity,
    );
  }

  Tube _getTube(int tubeIndex, List<Ball> allBalls, int tubeBallsCapacity) =>
      Tube(_getBallsForTube(tubeIndex, allBalls, tubeBallsCapacity),
          tubeBallsCapacity);

  List<Ball> _getBallsForTube(
          int tubeIndex, List<Ball> allBalls, int tubeBallsCapacity) =>
      allBalls.sublist(tubeBallsCapacity * tubeIndex,
          (tubeBallsCapacity * tubeIndex) + tubeBallsCapacity);
}
