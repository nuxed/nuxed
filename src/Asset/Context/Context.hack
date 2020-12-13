namespace Nuxed\Asset\Context;

final class Context implements IContext {
  private function __construct(
    private string $basePath,
    private bool $secure,
  ) {}

  public static function create(string $base_path, bool $secure): Context {
    return new Context($base_path, $secure);
  }

  /**
   * {@inheritdoc}
   */
  public function getBasePath(): string {
    return $this->basePath;
  }

  /**
   * {@inheritdoc}
   */
  public function isSecure(): bool {
    return $this->secure;
  }
}
