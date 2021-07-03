namespace Nuxed\Example\HttpClient;

use namespace Facebook\AutoloadMap;

use namespace HH\Asio;
use namespace HH\Lib\{Str, IO, TCP, Network};

use namespace Nuxed\Http\{Client, Message};
use namespace Nuxed\Json;

<<__EntryPoint>>
async function main(): Awaitable<void> {
  require_once __DIR__.'/../../vendor/autoload.hack';

  AutoloadMap\initialize();

  $output = IO\request_output();
  $input = IO\request_input();

  $server_coroutine = async {
    $server = await TCP\Server::createAsync(
      Network\IPProtocolVersion::IPV4,
      '127.0.0.1',
      8008,
      shape(
        'socket_options' => shape(
          'SO_REUSEADDR' => true,
        ),
      ),
    );

    await $output->writeAllAsync("> server is listening on port 8008.\n");

    $connection = await $server->nextConnectionAsync();
    $request = await $connection->readAllowPartialSuccessAsync();

    await $output->writeAllAsync("< received a request.\n");

    await $output->writeAllAsync("< sending a response.\n");

    await $connection->writeAllAsync("HTTP/1.1 200 OK\n");
    await $connection->writeAllAsync("Server: Simple Hack Server\n");
    await $connection->writeAllAsync("Connection: close\n\n");
    await $connection->writeAllAsync("Hello, World!");


    $connection->close();

    $server->stopListening();
  };

  $client_coroutine = async {
    $client = Client\HttpClient::create(shape(
      'base_uri' => 'http://localhost:8008',
    ));


    await $output->writeAllAsync("> sending a request.\n");

    $response = await $client->request('GET', '/');

    $content = await $response->getBody()->readAllAsync();

    await $output->writeAllAsync("> received a response: \n");

    await $output->writeAllAsync($content."\n");
  };

  concurrent {
    await $server_coroutine;
    await $client_coroutine;
  }
}
