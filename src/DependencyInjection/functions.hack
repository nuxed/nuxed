namespace Nuxed\DependencyInjection;

function factory<<<__Enforceable>> reify T>(
  (function(IServiceContainer): T) $factory,
): Factory\IFactory<T> {
  return new Factory\Decorator\CallableFactoryDecorator<T>($factory);
}

function inflector<<<__Enforceable>> reify T>(
  (function(T, IServiceContainer): T) $inflector,
): Inflector\IInflector<T> {
  return new Inflector\Decorator\CallableInflectorDecorator<T>($inflector);
}

function alias<
  <<__Enforceable>> reify TAlias,
  <<__Enforceable>> reify TService as TAlias,
>(classname<TService> $alias): Factory\IFactory<TAlias> {
  return factory<TAlias>(($container) ==> $container->get<TService>($alias));
}
