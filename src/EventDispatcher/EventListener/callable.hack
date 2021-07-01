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
 * Helper function to create an event listener,
 * from a callable.
 *
 * @see Nuxed\EventDispatcher\EventListener\CallableEventListener
 */
function callable<<<__Enforceable>> reify T as Event\IEvent>(
  (function(T): Awaitable<T>) $listener,
): IEventListener<T> {
  return new CallableEventListener($listener);
}
