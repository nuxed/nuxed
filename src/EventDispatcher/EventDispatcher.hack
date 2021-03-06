/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\EventDispatcher;

use namespace HH\Lib;

final class EventDispatcher implements IEventDispatcher {
  public function __construct(
    private ListenerProvider\IListenerProvider $listenerProvider,
  ) {}

  /**
   * Provide all relevant listeners with an event to process.
   *
   * @template T as IEvent
   *
   * @return T The Event that was passed, now modified by listeners.
   */
  public async function dispatch<<<__Enforceable>> reify T as Event\IEvent>(
    T $event,
  ): Awaitable<T> {
    if ($event is Event\IStoppableEvent && $event->isPropagationStopped()) {
      return $event;
    }

    $listeners = $this->listenerProvider->getListeners<T>();
    // we need to provide <T> to Lib\Ref as the object will be modified.
    // $event (type: Ti) can be a subtype of T, and $listener->process() can return
    // another subtype of T (type: To), which would result in a type error, because
    // we cannot assign type To to Lib\Ref::$value of type Ti.
    $event = new Lib\Ref<T>($event);
    foreach ($listeners await as $listener) {
      if (
        $event->value is Event\IStoppableEvent &&
        $event->value->isPropagationStopped()
      ) {
        return $event->value;
      }

      $event->value = await $listener->process($event->value);
    }

    return $event->value;
  }
}
