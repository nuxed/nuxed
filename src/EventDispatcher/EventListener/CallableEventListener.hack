/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\EventDispatcher\EventListener;

use namespace Nuxed\EventDispatcher\Event;

/**
 * Decorator defines a callable listener for an event.
 */
final class CallableEventListener<T as Event\IEvent>
  implements IEventListener<T> {
  public function __construct(private (function(T): Awaitable<T>) $listener) {}

  /**
   * {@inheritdoc}
   */
  public function process(T $event): Awaitable<T> {
    return ($this->listener)($event);
  }
}
