import 'package:colourballs/model/game_difficulty.dart';
import 'package:flutter/material.dart';

/// Displays the controls for the app.
class ControlView extends StatelessWidget {
  final ValueChanged<GameDifficulty> newGameRequestedCallback;

  const ControlView({
    required this.newGameRequestedCallback,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Other controls here.
              _buildNewGameEasyButton(),
              const SizedBox(height: 16),
              _buildNewGameMediumButton(),
              const SizedBox(height: 16),
              _buildNewGameHardButton(),
            ],
          )
        ],
      );

  Widget _buildNewGameEasyButton() => _buildNewGameButton(GameDifficulty.easy);

  Widget _buildNewGameMediumButton() =>
      _buildNewGameButton(GameDifficulty.medium);

  Widget _buildNewGameHardButton() => _buildNewGameButton(GameDifficulty.hard);

  Widget _buildNewGameButton(GameDifficulty gameDifficulty) => Material(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        color: Colors.white.withOpacity(0.2),
        child: InkWell(
          customBorder: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16))),
          onTap: () => newGameRequestedCallback.call(gameDifficulty),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('New game'),
                const SizedBox(width: 16),
                _getDifficultyIndicator(gameDifficulty),
              ],
            ),
          ),
        ),
      );

  Widget _getDifficultyIndicator(GameDifficulty gameDifficulty) {
    switch (gameDifficulty) {
      case GameDifficulty.easy:
        return _getStarsIndicator(1, 3);
      case GameDifficulty.medium:
        return _getStarsIndicator(2, 3);
      default:
        return _getStarsIndicator(3, 3);
    }
  }

  Widget _getStarsIndicator(int starsCount, int maxPossibleStars) {
    List<Widget> starWidgets = [];

    for (int starIndex = 0; starIndex < maxPossibleStars; starIndex++) {
      starWidgets.add(_getStar(starIndex < starsCount));
    }

    return Row(children: starWidgets);
  }

  Widget _getStar(bool isVisible) => Opacity(
      opacity: isVisible ? 1 : 0,
      child: const Icon(
        Icons.star,
        color: Colors.yellow,
      ));
}
