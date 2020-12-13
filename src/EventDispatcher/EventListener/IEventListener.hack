namespace Nuxed\EventDispatcher\EventListener;

use namespace Nuxed\EventDispatcher\Event;

/**
 * Defines a listener for an event.
 */
interface IEventListener<T as Event\IEvent> {
  /**
   * Process the given event, and return it.
   */
  public function process(T $event): Awaitable<T>;
}
