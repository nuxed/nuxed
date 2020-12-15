namespace Nuxed\DependencyInjection;

final class ServiceDefinition<<<__Enforceable>> reify T> {
  private vec<string> $tags = vec[];
  private vec<Inflector\IInflector<T>> $inflectors = vec[];
  private ?T $resolved = null;

  public function __construct(
    private classname<T> $type,
    private Factory\IFactory<T> $factory,
    private bool $shared = true,
  ) {}

  public function resolve(IServiceContainer $container): T {
    if ($this->isShared() && $this->resolved is nonnull) {
      return $this->resolved;
    }

    $object = $this->factory->create($container);
    foreach ($this->inflectors as $inflector) {
      $object = $inflector->inflect($object, $container);
    }

    $this->resolved = $object;

    return $this->resolved;
  }

  public function getType(): classname<T> {
    return $this->type;
  }

  public function getTags(): Container<string> {
    return $this->tags;
  }

  public function getFactory(): Factory\IFactory<T> {
    return $this->factory;
  }

  public function getInflectors(): Container<Inflector\IInflector<T>> {
    return $this->inflectors;
  }

  public function isShared(): bool {
    return $this->shared;
  }

  public function withFactory(Factory\IFactory<T> $factory): this {
    $clone = clone $this;
    $clone->factory = $factory;
    $clone->resolved = null;

    return $clone;
  }

  public function withTag<<<__Enforceable>> reify TT>(
    classname<TT> $tag,
  ): this {
    $clone = clone $this;
    $clone->tags[] = $tag;
    return $clone;
  }

  public function withShared(bool $shared): this {
    $clone = clone $this;
    $clone->shared = $shared;

    return $clone;
  }

  public function withInflector(Inflector\IInflector<T> $inflector): this {
    $clone = clone $this;
    $clone->inflectors[] = $inflector;
    $clone->resolved = null;

    return $clone;
  }
}
