namespace Nuxed\DependencyInjection;

final class ServiceDefinition<<<__Enforceable>> reify T> {
  private vec<string> $tags = vec[];
  private vec<IInflector<T>> $inflectors = vec[];
  private ?T $resolved = null;

  public function __construct(
    private classname<T> $type,
    private IFactory<T> $factory,
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

  public function getFactory(): IFactory<T> {
    return $this->factory;
  }

  public function setFactory(IFactory<T> $factory): this {
    $this->factory = $factory;
    $this->resolved = null;

    return $this;
  }

  public function isShared(): bool {
    return $this->shared;
  }

  public function addTag<<<__Enforceable>> reify TT>(classname<TT> $tag): this {
    $this->tags[] = $tag;
    return $this;
  }

  public function setShared(bool $shared = true): this {
    $this->shared = $shared;

    return $this;
  }

  public function getInflectors(): Container<IInflector<T>> {
    return $this->inflectors;
  }

  public function inflect(IInflector<T> $inflector): this {
    $this->inflectors[] = $inflector;
    $this->resolved = null;

    return $this;
  }
}
