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

/**
 * An example of an immutable event object.
 */
final class HttpResponseEvent implements EventDispatcher\Event\IEvent {
    private function __construct(
        private int $status,
        private dict<string, vec<string>> $headers,
        private string $body,
    ) {}

    public static function create(
        int $status,
        dict<string, vec<string>> $headers,
        string $body,
    ): HttpResponseEvent {
        return new self($status, $headers, $body);
    }

    public function getStatusCode(): int {
        return $this->status;
    }

    public function withStatusCode(int $status_code): this {
        $self = clone $this;
        $self->status = $status_code;

        return $self;
    }

    public function getHeaders(): dict<string, vec<string>> {
        return $this->headers;
    }

    public function withHeaders(dict<string, vec<string>> $headers): this {
        $self = clone $this;
        $self->headers = $headers;

        return $self;
    }

    public function getBody(): string {
        return $this->body;
    }

    public function withBody(string $body): this {
        $self = clone $this;
        $self->body = $body;

        return $self;
    }
}
