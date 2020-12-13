namespace Nuxed\DevTools\Games\Snake;

use namespace HH\Lib\Str;

final class CollisionException extends \RuntimeException {
  public function __construct(private Coordinate $coordinate) {
    parent::__construct(
      Str\format('Collision at %d/%d', $coordinate->x, $coordinate->y),
    );
  }

  public function getCoordinate(): Coordinate {
    return $this->coordinate;
  }
}
