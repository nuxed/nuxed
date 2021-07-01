/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\EventDispatcher\ListenerProvider;

use namespace Nuxed\EventDispatcher\{Event, EventListener};

/**
 * The `ListenerProviderAggregate` allows you to combine multiple listener providers,
 * to use with the same event dispatcher.
 */
final class ListenerProviderAggregate implements IListenerProvider {
  private vec<IListenerProvider> $providers = vec[];

  /**
   * {@inheritdoc}
   */
  public async function getListeners<<<__Enforceable>> reify T as Event\IEvent>(
  ): AsyncIterator<EventListener\IEventListener<T>> {
    foreach ($this->providers as $provider) {
      foreach ($provider->getListeners<T>() await as $listener) {
        yield $listener;
      }
    }
  }

  /**
   * Attach a listener provider to the listeners aggregate.
   */
  public function attach(IListenerProvider $provider): void {
    $this->providers[] = $provider;
  }
}
