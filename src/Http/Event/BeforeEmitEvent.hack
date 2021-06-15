namespace Nuxed\Http\Event;

use namespace Nuxed\EventDispatcher;
use namespace Nuxed\Http;

/**
 * This event is dispatched before the response is emitted, allowing you
 * to modify the response to fit your needs.
 *
 * The request might not always be present depending on the context.
 */
final class BeforeEmitEvent implements EventDispatcher\Event\IStoppableEvent {
  private bool $propagationStopped = false;

  public function __construct(
    private Http\Message\IResponse $response,
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
