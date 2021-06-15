namespace Nuxed\Http\Event;

use namespace Nuxed\EventDispatcher;
use namespace Nuxed\Http;

/**
 * This event is dispatched after the request has been handled.
 *
 * Allowing you to modify the response to fit your needs.
 */
final class AfterHandleEvent implements EventDispatcher\Event\IStoppableEvent {
  private bool $propagationStopped = false;

  public function __construct(
    private Http\Message\IServerRequest $request,
    private Http\Message\IResponse $response,
  ) {}

  public function getRequest(): Http\Message\IServerRequest {
    return $this->request;
  }

  public function getResponse(): Http\Message\IResponse {
    return $this->response;
  }

  public function setResponse(Http\Message\IResponse $response): void {
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
