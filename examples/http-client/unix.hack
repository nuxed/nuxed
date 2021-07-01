namespace Nuxed\Example\HttpClient\Request;

use namespace Facebook\AutoloadMap;
use namespace HH\Lib\{Str, IO};
use namespace Nuxed\Http\{Client, Message};
use namespace Nuxed\Json;

<<__EntryPoint>>
async function main(): Awaitable<void> {
  require_once __DIR__.'/../../vendor/autoload.hack';

  AutoloadMap\initialize();

  $out = IO\request_output();
  $client = Client\HttpClient::create();

  $response = await $client
    ->request('GET', '/containers/json', shape(
      'unix_socket' => '/var/run/docker.sock',
    ));

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
