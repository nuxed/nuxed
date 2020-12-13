namespace Nuxed\DependencyInjection;

function factory<<<__Enforceable>> reify T>(
  (function(IServiceContainer): T) $factory,
): IFactory<T> {
  return new Decorator\CallableFactoryDecorator<T>($factory);
}

function inflector<<<__Enforceable>> reify T>(
  (function(T, IServiceContainer): T) $inflector,
): IInflector<T> {
  return new Decorator\CallableInflectorDecorator<T>($inflector);
}

function alias<
  <<__Enforceable>> reify TAlias,
  <<__Enforceable>> reify TService as TAlias,
>(classname<TService> $alias): IFactory<TAlias> {
  return factory<TAlias>(($container) ==> $container->get<TService>($alias));
}
