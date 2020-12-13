namespace Nuxed\Test\EventDispatcher\Fixture;

use namespace Nuxed\Contract\EventDispatcher\EventListener;

final class HttpResponseEventListener
    implements EventListener\IEventListener<HttpResponseEvent> {

    public async function process(
        HttpResponseEvent $event,
    ): Awaitable<HttpResponseEvent> {
        return $event
            ->withStatusCode(404)
            ->withHeaders(dict[
                'X-Foo' => vec['bar', 'baz'],
            ])
            ->withBody("nothing is here. we checked.");
    }
}
