namespace Nuxed\DependencyInjection;

use namespace HH\Lib\{C, Str, Vec};

final class ServiceContainer implements IServiceContainer {
  protected KeyedContainer<string, ServiceDefinition<mixed>> $definitions;
  protected Container<IServiceContainer> $delegates;

  public function __construct(
    KeyedContainer<string, ServiceDefinition<mixed>> $definitions = dict[],
    Container<IServiceContainer> $delegates = vec[],
  ) {
    $this->definitions = $definitions;
    $this->delegates = $delegates;
  }

  public function tagged<<<__Enforceable>> reify T>(
    classname<T> $tag,
  ): Container<T> {
    $tagged = vec[];
    foreach ($this->definitions as $service => $definition) {
      $tags = $definition->getTags();
      if (C\contains($tags, $tag)) {
        try {
          $tagged[] = $definition->resolve($this) as T;
        } catch (\Exception $e) {
          throw new Exception\ContainerException(
            Str\format(
              'Exception thrown while trying to create service "%s": %s',
              $service,
              Str\ends_with($e->getMessage(), '.')
                ? $e->getMessage()
                : $e->getMessage().'.',
            ),
            $e->getCode(),
            $e,
          );
        }
      }
    }

    foreach ($this->delegates as $container) {
      try {
        $tagged = Vec\concat($tagged, $container->tagged<T>($tag));
      } catch (\Exception $e) {
        throw new Exception\ContainerException(
          Str\format(
            'Exception thrown while resolving services tagged with "%s" from a delegate container: %s',
            $tag,
            Str\ends_with($e->getMessage(), '.')
              ? $e->getMessage()
              : $e->getMessage().'.',
          ),
          $e->getCode(),
          $e,
        );
      }
    }

    return $tagged;
  }

  public function get<<<__Enforceable>> reify T>(classname<T> $service): T {
    if (C\contains_key($this->definitions, $service)) {
      $definition = $this->definitions[$service] as ServiceDefinition<T>;

      try {
        return $definition->resolve($this);
      } catch (\Exception $e) {
        throw new Exception\ContainerException(
          Str\format(
            'Exception thrown while trying to create service "%s": %s',
            $service,
            Str\ends_with($e->getMessage(), '.')
              ? $e->getMessage()
              : $e->getMessage().'.',
          ),
          $e->getCode(),
          $e,
        );
      }
    }

    foreach ($this->delegates as $container) {
      if ($container->has<T>($service)) {
        try {
          $object = $container->get<T>($service);
          if ($object is IServiceContainerAware) {
            $object->setContainer($this);
          }

          return $object;
        } catch (\Exception $e) {
          throw new Exception\ContainerException(
            Str\format(
              'Exception thrown while resolving service "%s" from a delegate container: %s',
              $service,
              Str\ends_with($e->getMessage(), '.')
                ? $e->getMessage()
                : $e->getMessage().'.',
            ),
            $e->getCode(),
            $e,
          );
        }
      }
    }

    throw new Exception\NotFoundException(Str\format(
      'Service (%s) is not managed by the service container or delegates.',
      $service,
    ));
  }

  public function has<<<__Enforceable>> reify T>(classname<T> $service): bool {
    if (C\contains_key($this->definitions, $service)) {
      return true;
    }

    foreach ($this->delegates as $delegate) {
      if ($delegate->has<T>($service)) {
        return true;
      }
    }

    return false;
  }

  public function delegate(IServiceContainer $delegate): this {
    $delegates = vec($this->delegates);
    $delegates[] = $delegate;

    $this->delegates = $delegates;

    return $this;
  }
}
