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
 * Defines a listener for an event.
 */
interface IEventListener<T as Event\IEvent> {
  /**
   * Process the given event, and return it.
   */
  public function process(T $event): Awaitable<T>;
}
