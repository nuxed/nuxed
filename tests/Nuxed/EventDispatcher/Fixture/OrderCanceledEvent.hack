namespace Nuxed\Test\EventDispatcher\Fixture;

use namespace Nuxed\Contract\EventDispatcher;

final class OrderCanceledEvent
  implements EventDispatcher\Event\IStoppableEvent {
  public bool $handled = false;

  public function __construct(public string $orderId) {}

  public function isPropagationStopped(): bool {
    return $this->handled;
  }
}
