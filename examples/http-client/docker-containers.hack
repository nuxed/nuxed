namespace Nuxed\Example\HttpClient;

use namespace Facebook\AutoloadMap;

use namespace HH\Asio;
use namespace HH\Lib\{Str, IO, TCP, Network};

use namespace Nuxed\Http\{Client, Message};
use namespace Nuxed\Json;

<<__EntryPoint>>
async function unix(): Awaitable<void> {
  require_once __DIR__.'/../../vendor/autoload.hack';

  AutoloadMap\initialize();

  $out = IO\request_output();
  $client = Client\HttpClient::create(shape(
    'unix_socket' => '/var/run/docker.sock',
  ));

  // send a GET request to /container/json
  $response = await $client->request('GET', '/containers/json');

  $content = await $response->getBody()->readAllAsync();

  $containers = Json\typed<vec<shape('Id' => string, 'Image' => string, ...)>>(
    $content,
  );

  foreach ($containers as $container) {
    await $out->writeAllAsync(Str\format(
      'Container "%s" is running, and is using the "%s" image.%s',
      $container['Id'],
      $container['Image'],
      "\n",
    ));
  }
}
