/// The difficulty of the game, based on the number of balls per tube.
enum GameDifficulty {
  easy(ballsPerTube: 8),
  medium(ballsPerTube: 10),
  hard(ballsPerTube: 12);

  final int ballsPerTube;

  const GameDifficulty({required this.ballsPerTube});
}
