namespace Nuxed\EventDispatcher\ListenerProvider;

use namespace HH\Lib\C;
use namespace Nuxed\EventDispatcher\{Event, EventListener};

final class AttachableListenerProvider implements IListenerProvider {
  private dict<
    classname<Event\IEvent>,
    vec<EventListener\IEventListener<Event\IEvent>>,
  > $listeners = dict[];

  /**
   * {@inheritdoc}
   */
  public function listen<<<__Enforceable>> reify T as Event\IEvent>(
    EventListener\IEventListener<T> $listener,
  ): void {
    $event_type = T::class;
    $listeners = $this->listeners[$event_type] ?? vec[];
    if (C\contains($listeners, $listener)) {
      // duplicate detected
      return;
    }

    $listeners[] = $listener;
    /* HH_FIXME[4110] */
    $this->listeners[$event_type] = $listeners;
  }

  /**
   * {@inheritdoc}
   */
  public async function getListeners<<<__Enforceable>> reify T as Event\IEvent>(
  ): AsyncIterator<EventListener\IEventListener<T>> {
    foreach ($this->listeners as $type => $listeners) {
      if (T::class === $type || \is_subclass_of(T::class, $type)) {
        foreach ($listeners as $listener) {
          /* HH_FIXME[4110] */
          yield $listener;
        }
      }
    }
  }
}
