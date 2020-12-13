namespace App;

use namespace Nuxed\Configuration;
use namespace Nuxed\DependencyInjection;
use namespace Nuxed\Hook;
use namespace Nuxed\Log;

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

  $builder = new DependencyInjection\ContainerBuilder($configuration);

  $builder->register(
    new Hook\DependencyInjection\ServiceProvider\LogServiceProvider(),
  );

  $container = $builder->build();

  $logger = $container->get<Log\ILogger>(Log\ILogger::class);

  await $logger->debug<nothing>('connecting to the API.');
  await $logger->alert<nothing>('unable to reach the API.');

  echo 'look into test.log :).'."\n";
}
