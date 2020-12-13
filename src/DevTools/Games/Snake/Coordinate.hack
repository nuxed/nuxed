namespace Nuxed\DevTools\Games\Snake;

final class Coordinate {
  public function __construct(public int $x, public int $y) {}

  public function equals(Coordinate $goal): bool {
    return $goal->x === $this->x && $goal->y === $this->y;
  }
}
