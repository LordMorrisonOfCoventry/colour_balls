import 'package:colourballs/model/tube.dart';

/// The main model for the game.
/// This contains a list of tubes and the capacity of the tubes.
/// Note: Each tube in the list must have the same capacity, and this must also
/// be the same as the value held by [tubeBallsCapacity].
class GameModel {
  final List<Tube> tubes;
  final int tubeBallsCapacity;

  GameModel(this.tubes, this.tubeBallsCapacity);

  int get tubesCount => tubes.length;
}

/// A provider for [GameModel]s.
/// The main implementation of this will provide a game model which just gives
/// randomly mixed tubes, but it can also be implemented to provide test game
/// models. E.g. with tubes representing a nearly completed game.
abstract class GameModelProvider {
  GameModel getNewGameModel({required int tubeBallsCapacity});
}
