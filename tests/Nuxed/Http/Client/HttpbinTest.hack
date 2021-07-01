/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Test\Http\Client;

use namespace Nuxed\Json;
use namespace Nuxed\Environment;
use namespace Nuxed\Http\{Client, Message};
use namespace Facebook\HackTest;

use function Facebook\FBExpect\expect;

final class HttpbinTest extends HackTest\HackTest {
  <<HackTest\DataProvider('getRequests')>>
  public async function testRequest(
    Message\IRequest $request,
    Client\HttpClientOptions $options,
    int $expected_status_code,
    dict<string, vec<string>> $expected_headers,
    ?(function(Message\IResponse): Awaitable<void>) $inspector = null,
  ): Awaitable<void> {
    $httpbin = Environment\get('HTTPBIN_BASE_URI', 'https://httpbin.org')
      as string;

    $client = Client\HttpClient::create(shape(
      'base_uri' => $httpbin,
    ));

    $response = await $client->send($request, $options);
    expect($response->getStatusCode())->toBeSame($expected_status_code);
    foreach ($expected_headers as $header => $values) {
      foreach ($values as $value) {
        expect($response->getHeader($header))->toContain($value);
      }
    }

    if ($inspector is nonnull) {
      await $inspector($response);
    }
  }

  public function getRequests(): dict<string, (
    Message\IRequest,
    Client\HttpClientOptions,
    int,
    dict<string, vec<string>>,
    ?(function(Message\IResponse): Awaitable<void>),
  )> {

    $requests = dict[];

    // Http Methods
    $requests['http-methods:get-post'] = tuple(
      Message\request(Message\HttpMethod::GET, Message\uri('/post')),
      shape(),
      Message\StatusCode::METHOD_NOT_ALLOWED,
      dict[],
      null,
    );

    $requests['http-methods:get'] = tuple(
      Message\request(Message\HttpMethod::GET, Message\uri('/get')),
      shape(),
      Message\StatusCode::OK,
      dict[],
      null,
    );

    $requests['http-method:post'] = tuple(
      Message\request(Message\HttpMethod::POST, Message\uri('/post')),
      shape(),
      Message\StatusCode::OK,
      dict[],
      null,
    );

    $requests['http-methods:delete'] = tuple(
      Message\request(Message\HttpMethod::DELETE, Message\uri('/delete')),
      shape(),
      Message\StatusCode::OK,
      dict[],
      null,
    );

    $requests['http-methods:patch'] = tuple(
      Message\request(Message\HttpMethod::PATCH, Message\uri('/patch')),
      shape(),
      Message\StatusCode::OK,
      dict[],
      null,
    );

    $requests['http-methods:put'] = tuple(
      Message\request(Message\HttpMethod::PUT, Message\uri('/put')),
      shape(),
      Message\StatusCode::OK,
      dict[],
      null,
    );

    // Auth
    $requests['auth:basic'] = tuple(
      Message\request(
        Message\HttpMethod::GET,
        Message\uri('/basic-auth/user/password')->withUserInfo(
          'user',
          'password',
        ),
      ),
      shape(),
      Message\StatusCode::OK,
      dict[],
      null,
    );

    $requests['auth:bearer'] = tuple(
      Message\request(Message\HttpMethod::GET, Message\uri('/bearer')),
      shape('auth_bearer' => 'foo'),
      Message\StatusCode::OK,
      dict[],
      null,
    );

    $requests['auth:bearer-authorization-header'] = tuple(
      Message\request(
        Message\HttpMethod::GET,
        Message\uri('/bearer'),
        dict[
          'Authorization' => vec[
            'Bearer foo',
          ],
        ],
      ),
      shape(),
      Message\StatusCode::OK,
      dict[],
      null,
    );

    $requests['auth:bearer-unauthorized'] = tuple(
      Message\request(Message\HttpMethod::GET, Message\uri('/bearer')),
      shape(),
      Message\StatusCode::UNAUTHORIZED,
      dict[],
      null,
    );

    $common_methods = vec[
      Message\HttpMethod::GET,
      Message\HttpMethod::POST,
      Message\HttpMethod::DELETE,
      Message\HttpMethod::PATCH,
      Message\HttpMethod::PUT,
    ];

    // Status
    foreach ($common_methods as $method) {
      foreach (Message\StatusCode::getValues() as $status) {
        // skip 1xx and 3xx.
        if ($status < 200 || ($status >= 300 && $status < 400)) {
          continue;
        }

        $requests['status:'.$method.'-'.$status] = tuple(
          Message\request($method, Message\uri('/status/'.$status)),
          shape(),
          $status,
          dict[],
          null,
        );
      }
    }

    // Request inspection
    $requests['request-inspections:headers'] = tuple(
      Message\request(
        Message\HttpMethod::GET,
        Message\uri('/headers'),
        dict[
          'X-Foo' => vec['bar'],
          'X-Bar' => vec['baz', 'qux'],
        ],
      ),
      shape(),
      Message\StatusCode::OK,
      dict[],
      async (Message\IResponse $response) ==> {
        $content = await $response->getBody()->readAllAsync()
          |> Json\typed<dict<string, dict<string, string>>>($$);

        $headers = $content['headers'];

        expect($headers['X-Foo'])->toBeSame('bar');
        expect($headers['X-Bar'])->toBeSame('baz, qux');
      },
    );

    $requests['request-inspections:user-agent'] = tuple(
      Message\request(Message\HttpMethod::GET, Message\uri('/user-agent')),
      shape(),
      Message\StatusCode::OK,
      dict[],
      async (Message\IResponse $response) ==> {
        $content = await $response->getBody()->readAllAsync()
          |> Json\typed<dict<string, string>>($$);

        expect($content['user-agent'])->toContainSubstring('Nuxed');
      },
    );

    return $requests;

    // Anything
    foreach ($common_methods as $method) {
      $requests['anything:'.$method] = tuple(
        Message\request($method, Message\uri('/anything')),
        shape(),
        Message\StatusCode::OK,
        dict[],
        async (Message\IResponse $response) ==> {
          $content = await $response->getBody()->readAllAsync()
            |> Json\typed<shape('method' => string, ...)>($$);

          expect($content['method'])->toBeSame($method);
        },
      );
    }

    return $requests;
  }
}
