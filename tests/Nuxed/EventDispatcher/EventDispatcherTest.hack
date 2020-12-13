namespace Nuxed\Test\EventDispatcher;

use namespace HH\Lib\C;
use namespace Facebook\HackTest;
use namespace Nuxed\EventDispatcher;
use namespace Nuxed\Test\EventDispatcher\Fixture;
use function Facebook\FBExpect\expect;

class EventDispatcherTest extends HackTest\HackTest {
  public async function testStoppableEvent(): Awaitable<void> {
    $provider =
      new EventDispatcher\ListenerProvider\AttachableListenerProvider();

    $provider->listen<Fixture\OrderCanceledEvent>(
      new Fixture\OrderCanceledEventListener('foo'),
    );

    $provider->listen<Fixture\OrderCanceledEvent>(
      new Fixture\OrderCanceledEventListener('bar', true),
    );

    $provider->listen<Fixture\OrderCanceledEvent>(
      new Fixture\OrderCanceledEventListener('baz'),
    );

    $provider->listen<Fixture\OrderCanceledEvent>(
      new Fixture\OrderCanceledEventListener('qux'),
    );

    $provider->listen<Fixture\OrderCreatedEvent>(
      new Fixture\OrderCreatedEventListener(),
    );

    $dispatcher = new EventDispatcher\EventDispatcher($provider);

    $event = new Fixture\OrderCanceledEvent('foo');

    await $dispatcher->dispatch<Fixture\OrderCanceledEvent>($event);

    expect($event->orderId)->toBeSame('foofoobar');
  }

  public async function testDispatch(): Awaitable<void> {
    $provider =
      new EventDispatcher\ListenerProvider\AttachableListenerProvider();
    $provider->listen<Fixture\OrderCanceledEvent>(
      new Fixture\OrderCanceledEventListener('foo'),
    );
    $provider->listen<Fixture\OrderCanceledEvent>(
      new Fixture\OrderCanceledEventListener('bar'),
    );
    $provider->listen<Fixture\OrderCanceledEvent>(
      new Fixture\OrderCanceledEventListener('baz'),
    );
    $provider->listen<Fixture\OrderCanceledEvent>(
      new Fixture\OrderCanceledEventListener('qux'),
    );
    $dispatcher = new EventDispatcher\EventDispatcher($provider);
    $event = new Fixture\OrderCanceledEvent('foo');
    await $dispatcher->dispatch<Fixture\OrderCanceledEvent>($event);
    expect($event->orderId)->toBeSame('foofoobarbazqux');
  }

  public async function testDispatchWithImmutableEvents(): Awaitable<void> {
    $provider =
      new EventDispatcher\ListenerProvider\AttachableListenerProvider();
    $provider->listen<Fixture\HttpResponseEvent>(
      new Fixture\HttpResponseEventListener(),
    );

    $event = Fixture\HttpResponseEvent::create(200, dict[], 'hello, world!');

    $dispatcher = new EventDispatcher\EventDispatcher($provider);
    $modified_event = await $dispatcher->dispatch<Fixture\HttpResponseEvent>(
      $event,
    );

    expect($event->getStatusCode())->toBeSame(200);
    expect($event->getHeaders())->toBeSame(dict[]);
    expect($event->getBody())->toBeSame('hello, world!');

    expect($modified_event->getStatusCode())->toBeSame(404);
    expect($modified_event->getHeaders())->toBeSame(dict[
      'X-Foo' => vec['bar', 'baz'],
    ]);
    expect($modified_event->getBody())->toBeSame(
      'nothing is here. we checked.',
    );
  }
}
