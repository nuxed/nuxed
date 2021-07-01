/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Test\EventDispatcher\Fixture;

use namespace Nuxed\EventDispatcher;

final class OrderCanceledEvent
  implements EventDispatcher\Event\IStoppableEvent {
  public bool $handled = false;

  public function __construct(public string $orderId) {}

  public function isPropagationStopped(): bool {
    return $this->handled;
  }
}
