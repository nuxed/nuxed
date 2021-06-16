namespace Nuxed\Test\EventDispatcher\Fixture;

use namespace Nuxed\EventDispatcher\Event;

final class OrderCreatedEvent implements Event\IEvent {
  public function __construct(public string $orderId) {}
}
