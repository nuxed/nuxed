namespace Nuxed\DevTools\Games\Snake;

use namespace HH\{Asio, Lib};
use namespace HH\Lib\{C, Math, Str};
use namespace Nuxed\Console\{Input, Output};

final class Game {
  /**
   * Seconds to wait between moving the head
   */
  const float TICK_DURATION = 0.2;

  const dict<string, Direction> DIRECTIONS = dict[
    '61' => Direction::LEFT, // a
    '73' => Direction::DOWN, // s
    '64' => Direction::RIGHT, // d
    '77' => Direction::UP, // w

    '1b5b44' => Direction::LEFT, // left arrow
    '1b5b42' => Direction::DOWN, // down arrow
    '1b5b43' => Direction::RIGHT, // right arrow
    '1b5b41' => Direction::UP, // up arrow
  ];

  private Board $board;
  private Snake $snake;
  private int $height;
  private int $width;

  public function __construct(int $width, int $height) {
    $this->board = new Board($width, $height);
    $this->snake = new Snake($this->board, new Coordinate(40, 12));
    $this->board->addSnake($this->snake);
    $this->height = $height;
    $this->width = $width;
  }

  public async function run(
    Input\IInput $input,
    Output\IOutput $output,
  ): Awaitable<void> {
    await $this->board->init($output);
    await $this->intro($input, $output);

    $running = new Lib\Ref<bool>(true);
    $lastest_move = new Lib\Ref<string>('');

    $input_awaitable = async {
      $handle = $input->getHandle();
      while ($running->value) {
        $direct_input = await $handle->readAllowPartialSuccessAsync(3);
        $lastest_move->value = \bin2hex($direct_input) as string;
        if (C\contains_key(self::DIRECTIONS, $lastest_move->value)) {
          $this->snake->setDirection(self::DIRECTIONS[$lastest_move->value]);
        }
      }
    };

    $game_awaitable = async {
      while ($running->value) {
        $now = \microtime(true);

        try {
          await $this->board->tick($output);
        } catch (CollisionException $e) {
          $running->value = false;
          await $output->getCursor()
            ->move($e->getCoordinate()->x, $e->getCoordinate()->y);
          await $output->write('<crash>█</crash>');

          $y = ($e->getCoordinate()->y > 7 && $e->getCoordinate()->y < 14)
            ? 16
            : 8;

          await $this->board
            ->print(
              $output,
              Images::GAMEOVER,
              new Coordinate(
                (int)(
                  (
                    $this->width -
                    \mb_strlen(Str\split(Images::GAMEOVER, "\n")[0]) -
                    2
                  ) /
                  2
                ),
                $y,
              ),
              'crash',
            );

          await $output->getCursor()->move($this->width, $this->height + 1);
          await $input->getUserInput();
          await $output->writeln('');

          return;
        }

        await $output->getCursor()->move(4, $this->height);

        $speedup = Math\minva(1, $this->board->getScore() / 10);
        $tick_duration = self::TICK_DURATION -
          self::TICK_DURATION / 2 * $speedup;

        await $output->write(Str\format(
          '<footer> score: %d / speedup: %f / tick duration: %fms / lastest move: %s </footer>',
          $this->board->getScore(),
          (float)$speedup,
          (float)$tick_duration,
          $lastest_move->value,
        ));

        $leftover = $tick_duration - (\microtime(true) - $now);
        $leftover_time = $leftover * 1000000;

        await Asio\usleep((int)$leftover_time);
      }
    };

    concurrent {
      await $input_awaitable;
      await $game_awaitable;
    }
    ;
  }

  private async function intro(
    Input\IInput $input,
    Output\IOutput $output,
  ): Awaitable<void> {
    await $this->board
      ->print(
        $output,
        Images::SNAKE,
        new Coordinate(
          (int)(
            ($this->width - \mb_strlen(Str\split(Images::SNAKE, "\n")[0]) - 2) /
            2
          ),
          6,
        ),
        'snake',
      );

    $message =
      'Use arrow keys, or a for left, s for down, d for right and w for up.';
    await $this->board->print(
      $output,
      $message,
      new Coordinate((int)(($this->width - Str\length($message) - 2) / 2), 17),
    );

    $message = '--- Press any key to start ---';
    await $this->board->print(
      $output,
      $message,
      new Coordinate((int)(($this->width - Str\length($message) - 2) / 2), 19),
    );

    await $input->getUserInput(1);
    $lastOperation = async {
    };
    for ($i = 6; $i < 18; $i += 2) {
      $lastOperation = async {
        await $lastOperation;
        await $this->board->print(
          $output,
          Str\repeat(' ', $this->width - 3),
          new Coordinate(3, $i),
        );

        await Asio\usleep(200000);
      };
    }

    for ($i = 7; $i < 17; $i += 2) {
      $lastOperation = async {
        await $lastOperation;
        await $this->board->print(
          $output,
          Str\repeat(' ', $this->width - 3),
          new Coordinate(2, $i),
        );

        await Asio\usleep(200000);
      };
    }

    $lastOperation = async {
      await $lastOperation;
      await $this->board->print(
        $output,
        Str\repeat(' ', $this->width - 3),
        new Coordinate(2, 17),
      );
      await $this->board->print(
        $output,
        Str\repeat(' ', $this->width - 3),
        new Coordinate(2, 19),
      );
    };

    await $lastOperation;
    await Asio\usleep(1000000);
  }
}
