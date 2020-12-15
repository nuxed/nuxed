namespace App;

use namespace Nuxed\Configuration;
use namespace Nuxed\DependencyInjection;
use namespace Nuxed\Kernel;
use namespace Nuxed\Log;
use namespace Nuxed\Serializer;

<<__EntryPoint>>
async function main(): Awaitable<void> {
  require_once __DIR__.'/../vendor/autoload.hack';
  \Facebook\AutoloadMap\initialize();

  $configuration = new Configuration\Configuration(dict[
    'log' => dict[
      'handlers' => vec[
        dict[
          'type' => 'file',
          'path' => __DIR__.'/test.log',
        ],
      ],
    ],
  ]);

  $builder = new DependencyInjection\ContainerBuilder($configuration, vec[
    new DependencyInjection\Processor\ServiceContainerAwareProcessor(),
    new Kernel\DependencyInjection\Processor\Console\CommandProcessor(),
  ]);

  $builder->register(
    new Kernel\DependencyInjection\ServiceProvider\Stopwatch\StopwatchServiceProvider(),
    new Kernel\DependencyInjection\ServiceProvider\Serializer\SerializerServiceProvider(),
    new Kernel\DependencyInjection\ServiceProvider\Log\LogServiceProvider(),
  );

  $container = $builder->build();

  $serializer = $container->get<Serializer\ISerializer>(
    Serializer\ISerializer::class,
  );

  $logger = $container->get<Log\ILogger>(Log\ILogger::class);

  await $logger->debug<nothing>('connecting to the API.');
  await $logger->alert<nothing>('unable to reach the API.');

  await $logger->debug<?string>('serializing some data', dict[
    'serializer' => $serializer->serialize<Serializer\ISerializer>($serializer),
    'logger' => $serializer->serialize<Log\ILogger>($logger),
  ]);

  echo 'look into test.log :).'."\n";
}
