/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\EventDispatcher\Event;

/**
 * An Event whose processing may be interrupted when the event has been handled.
 *
 * A Dispatcher implementation MUST check to determine an Event
 * is marked as stopped after each listener is called. If it is then it should
 * return immediately without calling any further Listeners.
 */
interface IStoppableEvent extends IEvent {
  /**
   * Is propagation stopped?
   *
   * This will typically only be used by the Dispatcher to determine if the
   * previous listener halted propagation.
   *
   * @return bool
   *   True if the Event is complete and no further listeners should be called.
   *   False to continue calling listeners.
   */
  public function isPropagationStopped(): bool;
}
