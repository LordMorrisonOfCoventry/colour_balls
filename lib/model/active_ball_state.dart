/// The state of the currently active ball.
/// This means the ball which is in the process of being moved.
/// Initially all of the balls in a tube are settled (not active). If the user
/// taps this tube, the top ball is assigned a state of [beingPopped] and starts
/// moving out of the tube. When the ball reaches its uppermost position it is
/// assigned a state of [popped]. Then the user clicks on a tube (the target
/// tube) where they want the ball to go. The ball is then assigned a state of
/// [beingMovedToJustAboveTargetTube] and is moved to just above the target
/// tube. When the ball reaches this new position, it is assigned a state of
/// [beingPushed] and is moved into its new settled position in the target tube.
enum ActiveBallState {
  beingPopped(isMoving: true),
  popped(isMoving: false),
  beingMovedToJustAboveTargetTube(isMoving: true),
  beingPushed(isMoving: true);

  final bool isMoving;

  const ActiveBallState({required this.isMoving});

  bool get isNotMoving => !isMoving;
}
