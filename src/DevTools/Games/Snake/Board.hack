namespace Nuxed\DevTools\Games\Snake;

use namespace HH\Lib;
use namespace HH\Lib\{C, Str, Dict, Vec, PseudoRandom};
use namespace Nuxed\Console\Output;

final class Board {
  const int GROWTH_RATE = 6;

  private int $score = 0;
  private dict<int, vec<int>> $board = dict[];

  private int $width;
  private int $height;

  <<__LateInit>> private Snake $snake;
  <<__LateInit>> private Coordinate $goal;

  private bool $newGoal = false;

  public function __construct(int $width, int $height) {
    $this->width = $width;
    $this->height = $height;
  }

  public function getScore(): int {
    return $this->score;
  }

  public function addSnake(Snake $snake): void {
    $this->snake = $snake;
  }

  public async function init(Output\IOutput $output): Awaitable<void> {
    for ($i = 0; $i < $this->width; $i++) {
      $this->board[$i] = Vec\fill($this->height, 0);
    }

    $border = Str\repeat('=', $this->width - 2);
    $space = Str\repeat(' ', $this->width - 2);
    $lastOperation = async {
      await $output->getCursor()->move(0, 0);
      await $output->erase(Output\Sequence\Erase::DISPLAY);

      await $output->writeln('<background>|'.$border.'|</background>');
    };

    for ($i = 0; $i < $this->height - 2; $i++) {
      $lastOperation = async {
        await $lastOperation;
        await $output->writeln('<background>│'.$space.'│</background>');
      };
    }

    $lastOperation = async {
      await $output->write('<background>|'.$border.'|</background>');

      $this->createGoal();
    };

    await $lastOperation;
  }

  public async function print(
    Output\IOutput $output,
    string $lines,
    Coordinate $topLeft,
    string $font = 'background',
  ): Awaitable<void> {
    $y = $topLeft->y;
    foreach (Str\split($lines, "\n") as $line) {
      await $output->getCursor()->move($topLeft->x, $y);
      $y++;
      await $output->write("<$font>$line</>");
    }
  }

  public async function tick(Output\IOutput $output): Awaitable<void> {
    if ($this->newGoal) {
      await $output->getCursor()->move($this->goal->x, $this->goal->y);
      await $output->write('<goal>*</>');
      $this->newGoal = false;
    }

    await $this->snake->tick($output);
  }

  public function enter(Coordinate $coordinate): int {
    if (!$this->allowed($coordinate)) {
      throw new CollisionException($coordinate);
    }
    $this->board[$coordinate->x][$coordinate->y] = 1;

    if ($coordinate->equals($this->goal)) {
      $this->createGoal();
      $this->score++;

      return self::GROWTH_RATE;
    }

    return 0;
  }

  public function leave(Coordinate $coordinate): void {
    $this->board[$coordinate->x][$coordinate->y] = 0;
  }

  public function allowed(Coordinate $coordinate): bool {
    if (
      $coordinate->x <= 1 ||
      $coordinate->y < 1 ||
      $coordinate->x >= $this->width ||
      $coordinate->y >= $this->height - 1
    ) {
      return false;
    }
    if (1 === $this->board[$coordinate->x][$coordinate->y]) {
      return false;
    }

    return true;
  }

  private function createGoal(): void {
    do {
      $this->goal = new Coordinate(
        PseudoRandom\int(1, $this->width - 1),
        PseudoRandom\int(1, $this->height - 1),
      );
    } while (!$this->allowed($this->goal));

    $this->newGoal = true;

  }
}
