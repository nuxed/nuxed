namespace Nuxed\EventDispatcher\EventListener;

use namespace Nuxed\EventDispatcher\Event;
use namespace Nuxed\DependencyInjection;

/**
 * Helper function to create a lazy loaded event listener.
 */
function lazy<
  <<__Enforceable>> reify Ti as Event\IEvent,
  <<__Enforceable>> reify Ts as IEventListener<Ti>,
>(
  DependencyInjection\IServiceContainer $container,
  classname<Ts> $service,
): IEventListener<Ti> {
  return callable<Ti>(
    (Ti $event) ==> {
      $processor = $container->get<Ts>($service);

      return $processor->process($event);
    },
  );
}
