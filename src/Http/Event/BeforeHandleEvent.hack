namespace Nuxed\Http\Event;

use namespace Nuxed\EventDispatcher;
use namespace Nuxed\Http;

/**
 * This event is dispatched before the request is handled.
 *
 * Allow you to modify the request, or set a response to be emitted immediately without
 * dispatching the real handler.
 */
final class BeforeHandleEvent implements EventDispatcher\Event\IStoppableEvent {
  private bool $propagationStopped = false;

  private ?Http\Message\IResponse $response = null;

  public function __construct(private Http\Message\IServerRequest $request) {}

  public function getRequest(): Http\Message\IServerRequest {
    return $this->request;
  }

  public function setRequest(Http\Message\IServerRequest $request): void {
    $this->request = $request;
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
