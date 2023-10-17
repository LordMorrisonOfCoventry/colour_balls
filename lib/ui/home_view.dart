import 'package:colourballs/model/game_difficulty.dart';
import 'package:colourballs/model/game_model.dart';
import 'package:colourballs/ui/control_view.dart';
import 'package:colourballs/ui/gameplay_view.dart';
import 'package:flutter/material.dart';

/// The home view of the app.
/// Lays out the main widgets of the app.
class HomeView extends StatefulWidget {
  final GameModelProvider gameModelProvider;

  const HomeView(
    this.gameModelProvider, {
    Key? key,
  }) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final GameDifficulty _defaultGameDifficulty = GameDifficulty.easy;

  // View layout constraints.
  final EdgeInsets _homeViewPadding = const EdgeInsets.all(16);
  final double _gamePlayViewWidthAsFractionOfTotal = 9 / 16;
  final double _controlGamePlayGapSize = 16;

  late GameModel _gameModel;
  Key _refreshKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _gameModel = _getNewGameModel(_defaultGameDifficulty);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      key: _refreshKey,
      body: Padding(
        padding: _homeViewPadding,
        child: _buildLayoutView(context),
      ));

  Widget _buildLayoutView(BuildContext context) => Row(
        children: [
          _buildControlView(context),
          _buildControlGamePlayGap(context),
          _buildGameplayView(context)
        ],
      );

  Widget _buildControlView(BuildContext context) => SizedBox(
        width: _controlViewWidth,
        height: _controlViewHeight,
        child: ControlView(
            newGameRequestedCallback: (gameDifficulty) =>
                _handleNewGameClicked(gameDifficulty)),
      );

  Widget _buildControlGamePlayGap(BuildContext context) =>
      SizedBox(width: _controlGamePlayGapSize);

  Widget _buildGameplayView(BuildContext context) => SizedBox(
        width: _gameplayViewWidth,
        height: _gameplayViewHeight,
        child: GameplayView(
            _gameModel, Size(_gameplayViewWidth, _gameplayViewHeight)),
      );

  // Could show an 'Are you sure?' dialog here.
  void _handleNewGameClicked(GameDifficulty gameDifficulty) =>
      _startNewGame(gameDifficulty);

  void _startNewGame(GameDifficulty gameDifficulty) => setState(() {
        _gameModel = _getNewGameModel(gameDifficulty);
        _refreshKey = UniqueKey();
      });

  GameModel _getNewGameModel(GameDifficulty gameDifficulty) =>
      widget.gameModelProvider
          .getNewGameModel(tubeBallsCapacity: gameDifficulty.ballsPerTube);

  double get _controlViewWidth =>
      (_homeViewWidthWithoutPadding *
          (1 - _gamePlayViewWidthAsFractionOfTotal)) -
      _controlGamePlayGapSize;

  double get _controlViewHeight => _homeViewHeightWithoutPadding;

  double get _gameplayViewWidth =>
      _homeViewWidthWithoutPadding * _gamePlayViewWidthAsFractionOfTotal;

  double get _gameplayViewHeight => _homeViewHeightWithoutPadding;

  double get _homeViewWidthWithoutPadding =>
      _viewSize.width - _homeViewPadding.left - _homeViewPadding.right;

  double get _homeViewHeightWithoutPadding =>
      _viewSize.height - _homeViewPadding.top - _homeViewPadding.bottom;

  Size get _viewSize => MediaQuery.of(context).size;
}
