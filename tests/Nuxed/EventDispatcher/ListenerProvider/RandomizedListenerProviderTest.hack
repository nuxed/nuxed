/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Test\EventDispatcher\ListenerProvider;

use namespace Facebook\HackTest;
use namespace Nuxed\Test\EventDispatcher\Fixture;
use namespace Nuxed\EventDispatcher\ListenerProvider;
use function Facebook\FBExpect\expect;

class RandomizedListenerProviderTest extends HackTest\HackTest {
  public async function testListenAndGetListeners(): Awaitable<void> {
    $listenerProvider = new ListenerProvider\RandomizedListenerProvider();
    $listeners = vec[
      new Fixture\OrderCanceledEventListener('foo'),
      new Fixture\OrderCanceledEventListener('baz'),
      new Fixture\OrderCanceledEventListener('qux'),
    ];
    foreach ($listeners as $listener) {
      $listenerProvider->listen<Fixture\OrderCanceledEvent>($listener);
    }
    $listenerProvider->listen<Fixture\OrderCreatedEvent>(
      new Fixture\OrderCreatedEventListener(),
    );

    $i = 0;
    foreach (
      $listenerProvider->getListeners<Fixture\OrderCanceledEvent>() await as
        $listener
    ) {
      $i++;
    }

    expect($i)->toBeSame(3);
  }

  public async function testDuplicateListeners(): Awaitable<void> {
    $listenerProvider = new ListenerProvider\RandomizedListenerProvider();
    $listener = new Fixture\OrderCanceledEventListener('foo');
    $listenerProvider->listen<Fixture\OrderCanceledEvent>($listener);
    $listenerProvider->listen<Fixture\OrderCanceledEvent>($listener);
    $listenerProvider->listen<Fixture\OrderCanceledEvent>($listener);
    $listenerProvider->listen<Fixture\OrderCreatedEvent>(
      new Fixture\OrderCreatedEventListener(),
    );

    $i = 0;
    foreach (
      $listenerProvider->getListeners<Fixture\OrderCanceledEvent>() await as
        $eventListener
    ) {
      expect($listener)->toBeSame($eventListener);
      $i++;
    }

    expect($i)->toBeSame(1);
  }
}
