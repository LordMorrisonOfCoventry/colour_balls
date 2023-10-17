import 'package:colourballs/model/ball.dart';
import 'package:colourballs/model/test/completed_game_model_provider.dart';
import 'package:colourballs/model/game_model.dart';
import 'package:colourballs/model/tube.dart';

/// Provides a [GameModel] which represents a game that is only one move away
/// from being completed. This can be used for testing purposes.
class OneMoveAwayGameModelProvider implements GameModelProvider {
  @override
  GameModel getNewGameModel({required int tubeBallsCapacity}) {
    GameModel gameModel = CompletedGameModelProvider()
        .getNewGameModel(tubeBallsCapacity: tubeBallsCapacity);

    Tube firstTube = gameModel.tubes.first;
    Ball topBallFromFirstTube = firstTube.popTopBall!;
    Tube lastTube = gameModel.tubes.last;
    lastTube.pushBall(topBallFromFirstTube);

    return gameModel;
  }
}
