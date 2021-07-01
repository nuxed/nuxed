/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Http\Event;

use namespace Nuxed\{EventDispatcher, Http};

/**
 * This event is dispatched after the response is emitted, allowing you
 * to finish any pending operation before the request cycle is terminted.
 *
 * The request might not always be present depending on the context.
 */
final class AfterEmitEvent implements EventDispatcher\Event\IEvent {
  public function __construct(
    private Http\Message\IResponse $response,
    private bool $emittedSuccessfully,
    private ?Http\Message\IRequest $request = null,
  ) {}

  public function hasRequest(): bool {
    return $this->request is nonnull;
  }

  public function getRequest(): Http\Message\IRequest {
    return $this->request as nonnull;
  }

  public function getResponse(): Http\Message\IResponse {
    return $this->response;
  }

  /**
   * Return whether the response has been emitted successfully.
   */
  public function isEmittedSuccessfully(): bool {
    return $this->emittedSuccessfully;
  }
}
