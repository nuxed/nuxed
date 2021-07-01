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

class ListenerProviderAggregateTest extends HackTest\HackTest {
  public async function testAttachAndGetListeners(): Awaitable<void> {
    $aggregate = new ListenerProvider\ListenerProviderAggregate();
    $attachableProvider = new ListenerProvider\AttachableListenerProvider();
    $randomProvider = new ListenerProvider\RandomizedListenerProvider();
    $aggregate->attach($attachableProvider);
    $aggregate->attach($randomProvider);

    $listeners = vec[
      new Fixture\OrderCanceledEventListener('foo'),
      new Fixture\OrderCanceledEventListener('baz'),
      new Fixture\OrderCanceledEventListener('qux'),
    ];
    foreach ($listeners as $listener) {
      $attachableProvider->listen<Fixture\OrderCanceledEvent>($listener);
      $randomProvider->listen<Fixture\OrderCanceledEvent>($listener);
    }
    $attachableProvider->listen<Fixture\OrderCreatedEvent>(
      new Fixture\OrderCreatedEventListener(),
    );

    $i = 0;
    foreach (
      $aggregate->getListeners<Fixture\OrderCanceledEvent>() await as $listener
    ) {
      expect($listeners)->toContain($listener);
      $i++;
    }

    expect($i)->toBeSame(6);
  }
}
