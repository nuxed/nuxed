namespace Nuxed\DependencyInjection;

final class Tagged<<<__Enforceable>> reify T> {
  public function __construct(private Container<T> $services) {}

  public function getServices(): Container<T> {
    return $this->services;
  }
}
