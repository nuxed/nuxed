namespace Nuxed\DependencyInjection;

use namespace HH\Lib\{C, Dict, Str};
use namespace Nuxed\Configuration;

final class ContainerBuilder {
  private dict<string, mixed> $definitions = dict[];

  public function __construct(
    private Configuration\IConfiguration $configuration,
    private Container<Processor\IProcessor> $processors,
  ) {}

  public function register(IServiceProvider ...$providers): this {
    foreach ($providers as $provider) {
      $provider->register($this, $this->configuration);
    }

    return $this;
  }

  public function add<<<__Enforceable>> reify T>(
    classname<T> $service,
    Factory\IFactory<T> $factory,
    bool $shared = true,
  ): this {
    $this->addDefinition<T>(
      new ServiceDefinition<T>($service, $factory, $shared),
    );

    return $this;
  }

  public function tag<
    <<__Enforceable>> reify TTag,
    <<__Enforceable>> reify TService as TTag,
  >(classname<TTag> $tag, classname<TService> $service): this {
    $definition = $this->getDefinition<TService>($service);
    $definition = $definition->withTag<TTag>($tag);
    // replace the old definition.
    $this->addDefinition<TService>($definition);

    return $this;
  }

  public function inflect<<<__Enforceable>> reify T>(
    classname<T> $service,
    Inflector\IInflector<T> $inflector,
  ): this {
    $definition = $this->getDefinition<T>($service);
    $definition = $definition->withInflector($inflector);

    // replace the old definition.
    $this->addDefinition<T>($definition);

    return $this;
  }

  private function addDefinition<<<__Enforceable>> reify T>(
    ServiceDefinition<T> $definition,
  ): void {
    foreach ($this->processors as $processor) {
      $definition = $processor->process<T>($definition);
    }

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
        return $definition;
      },
    );

    return new ServiceContainer(
      /* HH_IGNORE_ERROR[4110] - this is technically wrong, if keyed container is reified, it will fail, but there's no other solution. */
      $definitions,
      $delegates,
    );
  }
}
