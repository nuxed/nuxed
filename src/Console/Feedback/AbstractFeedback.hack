namespace Nuxed\Console\Feedback;

use namespace Nuxed\Console;
use namespace HH\Lib\{Math, Str, Vec};

/**
 * `AbstractFeedback` class handles core functionality for calculating and
 * displaying the progress information.
 */
abstract class AbstractFeedback implements IFeedback {
  /**
   * Characters used in displaying the feedback in the output.
   */
  protected vec<string> $characterSequence = vec[];

  protected ?(int, int) $position = null;

  /**
   * The current cycle out of the given total.
   */
  protected int $current = 0;

  /**
   * The format the feedback indicator will be displayed as.
   */
  protected string $format = '{:prefix}{:feedback}{:suffix}';

  /**
   * The current iteration of the feedback used to calculate the speed.
   */
  protected int $iteration = 0;

  /**
   * The max length of the characters in the character sequence.
   */
  protected int $maxLength = 1;

  /**
   * The template used to prefix the output.
   */
  protected string $prefix = '{:message}  {:percent}% [';

  /**
   * The current speed of the feedback.
   */
  protected float $speed = 0.0;

  /**
   * The time the feedback started.
   */
  protected int $start = -1;

  /**
   * The template used to suffix the output.
   */
  protected string $suffix = '] {:elapsed} / {:estimated}';

  /**
   * The current tick used to calculate the speed.
   */
  protected int $tick = -1;

  /**
   * The feedback running time.
   */
  protected int $timer = -1;

  /**
   * Create a new instance of the `Feedback`.
   */
  public function __construct(
    /**
     * The `Output` used for displaying the feedback information.
     */
    protected Console\Output\IOutput $output,

    /**
     * The total number of cycles expected for the feedback to take until finished.
     */
    protected int $total = 0,

    /**
     * The message to be displayed with the feedback.
     */
    protected string $message = '',

    /**
     * The interval (in miliseconds) between updates of the indicator.
     */
    protected int $interval = 100,
  ) {}

  /**
   * {@inheritdoc}
   */
  public async function advance(int $increment = 1): Awaitable<void> {
    $this->current = Math\minva($this->total, $this->current + $increment);

    if ($this->shouldUpdate()) {
      await $this->display();
    }

    if ($this->current === $this->total) {
      await $this->display(true);
    }
  }

  /**
   * Build and return all variables that are accepted when building the prefix
   * and suffix for the output.
   */
  protected function buildOutputVariables(): KeyedContainer<string, string> {
    $message = $this->message;
    $percent = Str\pad_right(
      (string)Math\floor($this->getPercentageComplete() * 100),
      3,
    );
    $estimated = $this->formatTime((int)$this->estimateTimeRemaining());
    $elapsed = Str\pad_right(
      $this->formatTime($this->getElapsedTime()),
      Str\length($estimated),
    );

    $variables = dict[
      'message' => $message,
      'percent' => $percent,
      'elapsed' => $elapsed,
      'estimated' => $estimated,
    ];

    return $variables;
  }

  /**
   * Method used to format and output the display of the feedback.
   */
  abstract protected function display(bool $finish = false): Awaitable<void>;

  /**
   * Given the speed and currently elapsed time, calculate the estimated time
   * remaining.
   */
  protected function estimateTimeRemaining(): float {
    $speed = $this->getSpeed();
    if ($speed is null || 0.0 === $speed || !$this->getElapsedTime()) {
      return 0.0;
    }

    return Math\round($this->total / $speed);
  }

  /**
   * {@inheritdoc}
   */
  public async function finish(): Awaitable<void> {
    if ($this->current === $this->total) {
      return;
    }

    $this->current = $this->total;
    await $this->display(true);
  }

  /**
   * Format the given time for output.
   */
  protected function formatTime(int $time): string {
    return ((string)Math\floor($time / 60)).
      ':'.
      Str\pad_left(((string)($time % 60)), 2, '0');
  }

  /**
   * Retrieve the current elapsed time.
   */
  protected function getElapsedTime(): int {
    if ($this->start < 0) {
      return 0;
    }

    return (\time() - $this->start);
  }

  /**
   * Retrieve the percentage complete based on the current cycle and the total
   * number of cycles.
   */
  protected function getPercentageComplete(): float {
    if ($this->total === 0) {
      return 1.0;
    }

    return (float)($this->current / $this->total);
  }

  /**
   * Get the current speed of the feedback.
   */
  protected function getSpeed(): float {
    if ($this->start < 0) {
      return 0.0;
    }

    if ($this->tick < 0) {
      $this->tick = $this->start;
    }

    $now = \microtime(true) as num;
    $span = $now - $this->tick;

    if ($span > 1) {
      $this->iteration++;
      $this->tick = (int)$now;
      $this->speed = (float)(($this->current / $this->iteration) / $span);
    }

    return $this->speed;
  }

  /**
   * Retrieve the total number of cycles the feedback should take.
   */
  protected function getTotal(): int {
    return $this->total;
  }

  /**
   * Set the characters used in the output.
   */
  public function setCharacterSequence(Container<string> $characters): this {
    $this->characterSequence = vec<string>($characters);
    $this->setMaxLength();

    return $this;
  }

  /**
   * Set the display position (column, row).
   *
   * Implementation should not change position unless this method
   * is called.
   *
   * When changing positions, the implementation should always save the cursor
   * position, then restore it.
   */
  public function setPosition(?(int, int) $position): void {
    $this->position = $position;
  }

  /**
   * {@inheritdoc}
   */
  public function setInterval(int $interval): this {
    $this->interval = $interval;

    return $this;
  }

  /**
   * Set the maximum length of the available character sequence characters.
   *
   * @return $this
   */
  protected function setMaxLength(): this {
    $this->maxLength = Math\max(Vec\map<string, int>(
      $this->characterSequence,
      (string $k): int ==> Str\length($k),
    )) as nonnull;

    return $this;
  }

  /**
   * {@inheritdoc}
   */
  public function setMessage(string $message): this {
    $this->message = $message;

    return $this;
  }

  /**
   * {@inheritdoc}
   */
  public function setPrefix(string $prefix): this {
    $this->prefix = $prefix;

    return $this;
  }

  /**
   * {@inheritdoc}
   */
  public function setSuffix(string $sufix): this {
    $this->suffix = $sufix;

    return $this;
  }

  /**
   * {@inheritdoc}
   */
  public function setTotal(int $total): this {
    $this->total = $total;

    return $this;
  }

  /**
   * Determine if the feedback should update its output based on the current
   * time, start time, and set interval.
   */
  protected function shouldUpdate(): bool {
    $now = \microtime(true) * 1000;

    if ($this->timer < 0) {
      $this->timer = (int)$now;
      $this->start = (int)($this->timer / 1000);

      return true;
    }

    if (($now - $this->timer) > $this->interval) {
      $this->timer = (int)$now;

      return true;
    }

    return false;
  }

  protected function insert(
    string $format,
    KeyedContainer<string, string> $variables,
  ): string {
    foreach ($variables as $key => $value) {
      $format = Str\replace($format, Str\format('{:%s}', $key), $value);
    }

    return $format;
  }
}
