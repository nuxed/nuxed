/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Test\EventDispatcher\ListenerProvider;

use namespace HH\Lib\{C, Dict, Vec};
use namespace Facebook\HackTest;
use namespace Nuxed\Test\EventDispatcher\Fixture;
use namespace Nuxed\EventDispatcher\ListenerProvider;
use function Facebook\FBExpect\expect;

class PrioritizedListenerProviderTest extends HackTest\HackTest {
  public async function testListenAndGetListeners(): Awaitable<void> {
    $listenerProvider = new ListenerProvider\PrioritizedListenerProvider();
    $listeners = vec[
      new Fixture\OrderCanceledEventListener('foo'),
      new Fixture\OrderCanceledEventListener('baz'),
      new Fixture\OrderCanceledEventListener('qux'),
    ];
    foreach ($listeners as $priority => $listener) {
      $listenerProvider->listen<Fixture\OrderCanceledEvent>(
        $listener,
        $priority,
      );
    }
    $listenerProvider->listen<Fixture\OrderCreatedEvent>(
      new Fixture\OrderCreatedEventListener(),
    );

    $i = 0;
    foreach (
      $listenerProvider->getListeners<Fixture\OrderCanceledEvent>() await as
        $listener
    ) {
      expect($listeners[$i])->toBeSame($listener);
      $i++;
    }

    expect($i)->toBeSame(3);
  }

  public async function testDuplicateListeners(): Awaitable<void> {
    $listenerProvider = new ListenerProvider\PrioritizedListenerProvider();
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

  public async function testOrder(): Awaitable<void> {
    $data = dict[
      'foo' => vec[1, 58, 79],
      'bar' => vec[55, 79, 79],
      'baz' => vec[78, 71, 10],
      'qux' => vec[2, 7, 78],
    ];

    $handlers = dict[];

    $listenerProvider = new ListenerProvider\PrioritizedListenerProvider();
    foreach ($data as $handler => $priorities) {
      foreach ($priorities as $prioritiy) {
        $listener = new Fixture\OrderCanceledEventListener($handler);
        $listenerProvider->listen<Fixture\OrderCanceledEvent>(
          $listener,
          $prioritiy,
        );
        $prioritiyOrderHandlers = $handlers[$prioritiy] ?? vec[];
        $prioritiyOrderHandlers[] = $handler;
        $handlers[$prioritiy] = $prioritiyOrderHandlers;
      }
    }

    $handlers = Dict\sort_by_key($handlers)
      |> vec($$)
      |> Vec\flatten($$);
    $i = 0;
    foreach (
      $listenerProvider->getListeners<Fixture\OrderCanceledEvent>() await as
        $listener
    ) {
      $listener as Fixture\OrderCanceledEventListener;
      expect($listener->append)->toBeSame($handlers[$i]);
      $i++;
    }

    expect($i)->toBeSame(C\count($handlers));
  }
}
