namespace Nuxed\DevTools\Games\Snake;

use namespace HH\Lib\{C, Vec};
use namespace Nuxed\Console\Output;

final class Snake {
  private Board $board;

  private Direction $direction = Direction::RIGHT;

  private Coordinate $head;

  private vec<Coordinate> $tail;

  private int $grow = 2;

  public function __construct(Board $board, Coordinate $start) {
    $this->board = $board;
    $this->head = clone $start;
    $this->tail = vec[clone $start];
  }

  public function setDirection(Direction $direction): void {
    if (
      Direction::UP === $this->direction && Direction::DOWN === $direction ||
      Direction::DOWN === $this->direction && Direction::UP === $direction ||
      Direction::LEFT === $this->direction && Direction::RIGHT === $direction ||
      Direction::RIGHT === $this->direction && Direction::LEFT === $direction
    ) {
      // ignore direction reversal which would lead to immediate self-collision
      return;
    }

    $this->direction = $direction;
  }

  public async function tick(Output\IOutput $output): Awaitable<void> {
    switch ($this->direction) {
      case Direction::UP:
        $this->head->y--;
        break;
      case Direction::RIGHT:
        $this->head->x++;
        break;
      case Direction::DOWN:
        $this->head->y++;
        break;
      case Direction::LEFT:
        $this->head->x--;
        break;
    }

    $this->grow += $this->board->enter($this->head);

    await $output->getCursor()->move($this->head->x, $this->head->y);
    await $output->write('<snake>█</>');
    $this->tail[] = clone $this->head;
    if ($this->grow > 0) {
      $this->grow--;
    } else {
      $coord = C\firstx($this->tail);
      $this->tail = Vec\slice($this->tail, 1);
      $this->board->leave($coord);
      await $output->getCursor()->move($coord->x, $coord->y);
      await $output->write('<background> </>');
    }
  }

  public function addGrow(int $amount): void {
    $this->grow += $amount;
  }
}
