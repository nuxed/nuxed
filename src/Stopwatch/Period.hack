namespace Nuxed\Stopwatch;


final class Period {
  private int $memory;

  /**
   * @param float $start         The relative time of the start of the period (in milliseconds)
   * @param float $end           The relative time of the end of the period (in milliseconds)
   */
  public function __construct(private float $start, private float $end) {
    $this->memory = \memory_get_usage(true);
  }

  /**
   * Gets the relative time of the start of the period.
   *
   * @return float The time (in milliseconds)
   */
  public function getStartTime(): float {
    return $this->start;
  }
  /**
   * Gets the relative time of the end of the period.
   *
   * @return float The time (in milliseconds)
   */
  public function getEndTime(): float {
    return $this->end;
  }

  /**
   * Gets the time spent in this period.
   *
   * @return float The period duration (in milliseconds)
   */
  public function getDuration(): float {
    return $this->end - $this->start;
  }

  /**
   * Gets the memory usage.
   *
   * @return int The memory usage (in bytes)
   */
  public function getMemory(): int {
    return $this->memory;
  }
}
