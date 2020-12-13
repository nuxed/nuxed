namespace Nuxed\Test\EventDispatcher\Fixture;

use namespace Nuxed\Contract\EventDispatcher\Event;

final class OrderCreatedEvent implements Event\IEvent {
  public function __construct(public string $orderId) {}
}
