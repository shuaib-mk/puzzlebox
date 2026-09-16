enum LudoColor { red, green, yellow, blue }

class LudoToken {
  final int id; // 0 to 3
  final LudoColor color;
  int stepPosition; // -1 = in home yard, 0..50 = main track, 51..55 = home stretch, 56 = finished/home

  LudoToken({
    required this.id,
    required this.color,
    this.stepPosition = -1,
  });

  bool get isInYard => stepPosition == -1;
  bool get isFinished => stepPosition == 56;
  bool get isInTrack => stepPosition >= 0 && stepPosition <= 50;
  bool get isInHomeStretch => stepPosition >= 51 && stepPosition <= 55;
}
