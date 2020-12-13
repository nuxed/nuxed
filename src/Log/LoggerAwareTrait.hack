namespace Nuxed\Log;

/**
 * Describes a logger-aware instance.
 */
trait LoggerAwareTrait implements ILoggerAware {
  protected ?ILogger $logger = null;

  /**
   * Sets a logger instance on the object.
   */
  public function setLogger(ILogger $logger): void {
    $this->logger = $logger;
  }

  protected function getLogger(): ILogger {
    if ($this->logger is null) {
      $this->logger = new NullLogger();
    }

    return $this->logger;
  }
}
