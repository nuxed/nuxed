/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Http;

use namespace Nuxed\{Cache, Environment, EventDispatcher, Http};
use namespace Nuxed\EventDispatcher\{Event, EventListener, ListenerProvider};

final class Application
  implements
    Emitter\IEmitter,
    Routing\IRouteCollector,
    Middleware\IMiddlewareStack,
    Handler\IHandler {

  use Routing\RouterConvenienceMethodsTrait;

  private Emitter\IEmitter $emitter;
  private Routing\IRouter $router;
  private Cache\ICache $cache;
  private Middleware\IMiddlewareStack $middleware;
  private EventDispatcher\IEventDispatcher $dispatcher;
  private ListenerProvider\PrioritizedListenerProvider $listenerProvider;

  public function __construct(
    ?Routing\IRouter $router = null,
    Container<Middleware\IMiddleware> $middleware = vec[],
    ?Emitter\IEmitter $emitter = null,
    ?Cache\ICache $cache = null,
    ?ListenerProvider\IListenerProvider $listenerProvider = null,
  ) {
    $this->middleware = new Middleware\MiddlewareStack();
    $this->cache = $cache ?? new Cache\Cache(new Cache\Store\ApcStore());
    $this->emitter = $emitter ?? new Emitter\Emitter();
    $this->router = $router ?? new Routing\Router($this->cache);

    $this->listenerProvider =
      new ListenerProvider\PrioritizedListenerProvider();
    if ($listenerProvider is null) {
      $provider = $this->listenerProvider;
    } else {
      $provider = new ListenerProvider\ListenerProviderAggregate();
      $provider->attach($listenerProvider);
      $provider->attach($this->listenerProvider);
    }

    $this->dispatcher = new EventDispatcher\EventDispatcher($provider);

    foreach ($middleware as $mw) {
      $this->middleware->stack($mw);
    }

    $this->middleware
      ->stack(new Routing\Middleware\RouteMiddleware($this->router), -1001)
      ->stack(new Routing\Middleware\DispatchMiddleware(), -1002)
      ->stack(new Routing\Middleware\ImplicitHeadMiddleware(), -1003)
      ->stack(new Routing\Middleware\ImplicitOptionsMiddleware(), -1004);
  }

  /**
   * {@inheritdoc}
   */
  public function listen<<<__Enforceable>> reify T as Event\IEvent>(
    EventListener\IEventListener<T> $listener,
    int $priority = 1,
  ): void {
    $this->listenerProvider->listen<T>($listener, $priority);
  }

  public function addRoute(Routing\Route $route): this {
    $this->router->addRoute($route);

    return $this;
  }

  public function addRouteCollection(
    Routing\RouteCollection $collection,
  ): this {
    $this->router->addRouteCollection($collection);

    return $this;
  }

  /**
   * Attach middleware to the stack.
   */
  public function stack(
    Middleware\IMiddleware $middleware,
    int $priority = 0,
  ): this {
    $this->middleware->stack($middleware, $priority);

    return $this;
  }

  /**
   * Process an incoming server request and return a response, optionally delegating
   * response creation to a handler.
   */
  public async function process(
    Message\IServerRequest $request,
    Handler\IHandler $handler,
  ): Awaitable<Message\IResponse> {
    return await $this->middleware->process($request, $handler);
  }

  /**
   * Handle the request and return a response.
   */
  public async function handle(
    Message\IServerRequest $request,
  ): Awaitable<Message\IResponse> {
    // TODO(azjezz): does the event dispatching order here even make sense?
    // - what if before handle event listener throws?
    // - what if after handle event listener throws?
    // - what if server exception event listener throws?
    // - what if exception event listener throws?
    // ... etc.

    $event = await $this->dispatcher->dispatch<Http\Event\BeforeHandleEvent>(
      new Http\Event\BeforeHandleEvent($request),
    );

    if (!$event->hasResponse()) {
      try {
        $response = await $this->process(
          $request,
          new Handler\NotFoundHandler(),
        );
      } catch (Exception\ServerException $e) {
        $event = await $this->dispatcher
          ->dispatch<Http\Event\ServerExceptionEvent>(
            new Http\Event\ServerExceptionEvent($request, $e),
          );

        if ($event->hasResponse()) {
          $response = $event->getResponse();
        } else {
          $response = $e->toResponse();
        }
      } catch (\Exception $e) {
        $event = await $this->dispatcher->dispatch<Http\Event\ExceptionEvent>(
          new Http\Event\ExceptionEvent($request, $e),
        );

        if ($event->hasResponse()) {
          $response = $event->getResponse();
        } else {
          if (Environment\mode() === Environment\Mode::DEVELOPMENT) {
            throw $e;
          }

          $response = Message\Response\text(
            'Internal Server Error.',
            Message\StatusCode::INTERNAL_SERVER_ERROR,
          );
        }
      }
    } else {
      $response = $event->getResponse();
    }

    $event = await $this->dispatcher->dispatch<Http\Event\AfterHandleEvent>(
      new Http\Event\AfterHandleEvent($request, $response),
    );

    return $event->getResponse();
  }

  /**
   * Emit a response.
   *
   * Emits a response, including status line, headers, and the message body,
   * according to the environment.
   *
   * Implementations of this method may be written in such a way as to have
   * side effects, such as usage of header() or pushing output to the
   * output buffer.
   *
   * Implementations MAY raise exceptions if they are unable to emit the
   * response; e.g., if headers have already been sent.
   *
   * Implementations MUST return a boolean. A boolean `true` indicates that
   * the emitter was able to emit the response, while `false` indicates
   * it was not.
   */
  public async function emit(
    Message\IResponse $response,
    ?Message\IServerRequest $request = null,
  ): Awaitable<bool> {
    $response = await $this->dispatcher
      ->dispatch<Http\Event\BeforeEmitEvent>(
        new Http\Event\BeforeEmitEvent($response, $request),
      )
      |> $$->getResponse();

    $emitted = await $this->emitter->emit($response);

    await $this->dispatcher
      ->dispatch<Http\Event\AfterEmitEvent>(
        new Http\Event\AfterEmitEvent($response, $emitted, $request),
      );

    return $emitted;
  }

  public async function run(): Awaitable<void> {
    $request = await Message\ServerRequest::capture();
    $response = await $this->handle($request);

    await $this->emit($response, $request);
  }
}
