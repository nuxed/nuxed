namespace Nuxed\Http\Event;

use namespace Nuxed\EventDispatcher;
use namespace Nuxed\Http\Exception;
use namespace Nuxed\Http;

/**
 * This event is dispatched if an exception is thrown while the request
 * is being handled.
 *
 * This allows you to specify a response that should be sent in this case, or log the error.
 *
 * If a response has not been specified, a default response will be created
 * with the status code of 500.
 */
final class ExceptionEvent implements EventDispatcher\Event\IStoppableEvent {
  private bool $propagationStopped = false;

  private ?Http\Message\IResponse $response = null;

  public function __construct(
    private Http\Message\IServerRequest $request,
    private \Exception $exception,
  ) {}

  public function getRequest(): Http\Message\IServerRequest {
    return $this->request;
  }

  public function getException(): \Exception {
    return $this->exception;
  }

  public function hasResponse(): bool {
    return $this->response is nonnull;
  }

  public function getResponse(): Http\Message\IResponse {
    return $this->response as nonnull;
  }

  public function setResponse(?Http\Message\IResponse $response): void {
    $this->response = $response;
  }

  /**
   * Stop propagation.
   *
   * This will mark the event complete and no further listeners will be called.
   */
  public function stopPropagation(): void {
    $this->propagationStopped = true;
  }

  /**
   * Is propagation stopped?
   *
   * This will typically only be used by the Dispatcher to determine if the
   * previous listener halted propagation.
   *
   * @return bool
   *   True if the Event is complete and no further listeners should be called.
   *   False to continue calling listeners.
   */
  public function isPropagationStopped(): bool {
    return $this->propagationStopped;
  }
}
