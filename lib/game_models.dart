enum TileType { normal, bomb, multiplier }

enum CellSpecialType { none, locked, emp, diagonal, doubleEnergy, doubleScore }

class TileData {
  final int value;
  final TileType type;

  TileData({required this.value, required this.type});
}

class CellData {
  int value;
  bool isMultiplier;
  CellSpecialType specialType;
  String? floatingText;

  CellData({
    this.value = 0,
    this.isMultiplier = false,
    this.specialType = CellSpecialType.none,
    this.floatingText,
  });
}
