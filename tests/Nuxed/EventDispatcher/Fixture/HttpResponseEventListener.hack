/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Test\EventDispatcher\Fixture;

use namespace Nuxed\EventDispatcher\EventListener;

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
            ->withBody('nothing is here. we checked.');
    }
}
