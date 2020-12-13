namespace Nuxed\DependencyInjection;

use namespace HH\Lib\{C, Dict, Str};
use namespace Nuxed\Configuration;

final class ContainerBuilder {
  private dict<string, mixed> $definitions = dict[];

  public function __construct(
    private Configuration\IConfiguration $configuration,
  ) {}

  public function register(IServiceProvider $provider): this {
    $provider->register($this, $this->configuration);

    return $this;
  }

  public function add<<<__Enforceable>> reify T>(
    classname<T> $service,
    IFactory<T> $factory,
    bool $shared = true,
  ): this {
    $this->addDefinition<T>(
      new ServiceDefinition<T>($service, $factory, $shared),
    );

    return $this;
  }

  public function tag<
    <<__Enforceable>> reify TT,
    <<__Enforceable>> reify TS as TT,
  >(classname<TT> $tag, classname<TS> $service): this {
    $definition = $this->getDefinition<TS>($service);
    $definition->addTag<TT>($tag);

    return $this;
  }

  public function inflect<<<__Enforceable>> reify T>(
    classname<T> $service,
    IInflector<T> $inflector,
  ): this {
    $definition = $this->getDefinition<T>($service);
    $definition->inflect($inflector);

    return $this;
  }

  private function addDefinition<<<__Enforceable>> reify T>(
    ServiceDefinition<T> $definition,
  ): void {
    $this->definitions[$definition->getType()] = $definition;
  }

  private function getDefinition<<<__Enforceable>> reify T>(
    classname<T> $service,
  ): ServiceDefinition<T> {
    if (C\contains_key($this->definitions, $service)) {
      return $this->definitions[$service] as ServiceDefinition<T>;
    }

    throw new Exception\NotFoundException(Str\format(
      'Container builder doesn\'t contain definition for service (%s).',
      $service,
    ));
  }

  public function build(
    Container<IServiceContainer> $delegates = vec[],
  ): IServiceContainer {
    $definitions = Dict\map(
      $this->definitions,
      ($definition) ==> {
        $definition as ServiceDefinition<_>;
        return clone $definition;
      },
    );

    return new ServiceContainer(
      /* HH_IGNORE_ERROR[4110] */
      $definitions,
      $delegates,
    );
  }
}
