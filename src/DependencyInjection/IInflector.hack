namespace Nuxed\DependencyInjection;

interface IInflector<T> {
  public function inflect(T $service, IServiceContainer $container): T;
}
