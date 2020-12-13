namespace Nuxed\Test\EventDispatcher\Fixture;

use namespace Nuxed\Contract\EventDispatcher\EventListener;

final class OrderCanceledEventListener
  implements EventListener\IEventListener<OrderCanceledEvent> {

  public function __construct(
    public string $append,
    private bool $handle = false,
  ) {}

  public async function process(
    OrderCanceledEvent $event,
  ): Awaitable<OrderCanceledEvent> {
    $event->orderId .= $this->append;
    if ($this->handle) {
      $event->handled = true;
    }

    return $event;
  }
}
