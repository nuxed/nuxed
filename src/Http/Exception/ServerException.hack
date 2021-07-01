/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Http\Exception;

use namespace Nuxed\Http\Message;
use namespace HH\Lib\IO;

<<__Sealed(MethodNotAllowedException::class, NotFoundException::class)>>
class ServerException extends RuntimeException {
  public function __construct(
    protected int $status = Message\StatusCode::INTERNAL_SERVER_ERROR,
    protected dict<string, vec<string>> $headers = dict[],
    protected ?IO\SeekableReadWriteHandle $body = null,
  ) {
    $message = Message\Response::$phrases[$status] ??
      Message\Response::$phrases[500];

    parent::__construct($message);

    if (null === $body) {
      $this->headers['Content-Type'] = vec['text/plain', 'charset=utf-8'];
      $this->body = Message\Body\memory($message);
    }
  }

  public function getStatusCode(): int {
    return $this->status;
  }

  public function getHeaders(): KeyedContainer<string, Container<string>> {
    return $this->headers;
  }

  public function getBody(): ?IO\SeekableReadWriteHandle {
    return $this->body;
  }

  public function toResponse(): Message\IResponse {
    return Message\response($this->status, $this->headers, $this->body);
  }
}
