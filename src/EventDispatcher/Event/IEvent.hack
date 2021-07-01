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
 * Marker interface indicating an event instance.
 *
 * Event instances may contain zero methods, or as many methods as they
 * want. The interface MUST be implemented, however, to provide type-safety
 * to both listeners as well as the dispatcher.
 */
interface IEvent {}
