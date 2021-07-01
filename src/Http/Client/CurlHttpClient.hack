/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Http\Client;

use namespace HH\Asio;
use namespace HH\Lib\{C, Dict, Math, Regex, Str};
use namespace Nuxed\Http\{Exception, Message};

final class CurlHttpClient extends HttpClient {
  /**
   * Process the request and returns a response.
   *
   * @throws Exception\IException If an error happens while processing the request.
   */
  <<__Override>>
  public async function process(
    Message\IRequest $request,
    HttpClientOptions $options,
  ): Awaitable<Message\IResponse> {
    $uri = $request->getUri();

    $timeout = $options['timeout'] ?? 60.0;
    $ciphers = $options['ciphers'] ?? null;
    if ($ciphers is nonnull) {
      $ciphers = Str\join($ciphers, ',')
        |> $$ === '' ? null : $$;
    }

    $curlOptions = dict[
      \CURLOPT_URL => $uri->toString(),
      \CURLOPT_USERAGENT => 'Nuxed HttpClient/Curl',
      \CURLOPT_PROTOCOLS => \CURLPROTO_HTTP | \CURLPROTO_HTTPS,
      \CURLOPT_REDIR_PROTOCOLS => \CURLPROTO_HTTP | \CURLPROTO_HTTPS,
      \CURLOPT_FOLLOWLOCATION => true,
      \CURLOPT_RETURNTRANSFER => true,
      \CURLOPT_HEADER => true,
      \CURLOPT_MAXREDIRS => Math\max(vec[0, $options['max_redirects'] ?? 0]),
      \CURLOPT_COOKIEFILE => '', // Keep track of cookies during redirects
      \CURLOPT_CONNECTTIMEOUT_MS => 1000 * $timeout,
      \CURLOPT_HEADEROPT => \CURLHEADER_SEPARATE,
      \CURLOPT_SSL_VERIFYPEER => $options['verify_peer'] ?? true,
      \CURLOPT_SSL_VERIFYHOST => ($options['verify_host'] ?? true) ? 2 : 0,
      \CURLOPT_CAINFO => $options['cafile'] ?? null,
      \CURLOPT_CAPATH => $options['capath'] ?? null,
      \CURLOPT_SSL_CIPHER_LIST => $ciphers,
      \CURLOPT_SSLCERT => $options['local_cert'] ?? null,
      \CURLOPT_SSLKEY => $options['local_pk'] ?? null,
      \CURLOPT_KEYPASSWD => $options['passphrase'] ?? null,
      \CURLOPT_CERTINFO => $options['capture_peer_cert_chain'] ?? null,
    ];

    if (Shapes::keyExists($options, 'unix_socket')) {
      if ($uri->getHost() is null) {
        // if we have unix socket to connect to, the host is redundant, however, curl
        // will fail if we don't provide a host
        $curlOptions[\CURLOPT_URL] =
          $uri->withScheme('http')->withHost('0.0.0.0')->toString();
      }

      $curlOptions[\CURLOPT_UNIX_SOCKET_PATH] = $options['unix_socket'];
      $tcp_connection = false;
    } else {
      $curlOptions[\CURLOPT_TCP_NODELAY] = true;
      $curlOptions[\CURLOPT_PROXY] = $options['proxy'] ?? null;
      $curlOptions[\CURLOPT_NOPROXY] = $options['no_proxy'] ?? '';

      $tcp_connection = true;
    }

    $protocolVersion = (float)$request->getProtocolVersion();
    if (1.0 === $protocolVersion) {
      $curlOptions[\CURLOPT_HTTP_VERSION] = \CURL_HTTP_VERSION_1_0;
    } else if (1.1 === $protocolVersion) {
      $curlOptions[\CURLOPT_HTTP_VERSION] = \CURL_HTTP_VERSION_1_1;
    } else {
      $curlOptions[\CURLOPT_HTTP_VERSION] = \CURL_HTTP_VERSION_2_0;
    }

    $method = $request->getMethod();

    if (Message\HttpMethod::POST === $method) {
      // Use CURLOPT_POST to have browser-like POST-to-GET redirects for 301, 302 and 303
      $curlOptions[\CURLOPT_POST] = true;
    } else if (Message\HttpMethod::HEAD === $method) {
      $curlOptions[\CURLOPT_NOBODY] = true;
    } else {
      $curlOptions[\CURLOPT_CUSTOMREQUEST] = (string)$method;
    }

    if ($timeout < 1) {
      $curlOptions[\CURLOPT_NOSIGNAL] = true;
    }

    $headers = vec[];
    if (!$request->hasHeader('Accept-Encoding')) {
      $headers[] = 'Accept-Encoding: gzip';
    }

    foreach ($request->getHeaders() as $name => $_values) {
      $headers[] = Str\format('%s: %s', $name, $request->getHeaderLine($name));
    }

    // Prevent curl from sending its default Accept and Expect headers
    foreach (vec['Accept', 'Expect'] as $header) {
      if (!$request->hasHeader($header)) {
        $headers[] = $header.':';
      }
    }
    $curlOptions[\CURLOPT_HTTPHEADER] = $headers;

    $body = $request->getBody();
    $body->seek(0);
    $content = await $body->readAllAsync();
    if ('' !== $content || Message\HttpMethod::POST === $request->getMethod()) {
      $curlOptions[\CURLOPT_POSTFIELDS] = $content;
    }

    $fingerprint = $options['peer_fingerprint'] ?? dict[];
    foreach ($fingerprint as $algorithm => $digest) {
      if ($algorithm !== 'pin-sha256') {
        throw new Exception\InvalidArgumentException(
          Str\format('%s supports only "pin-sha256" fingerprints.', __CLASS__),
        );
      }

      $curlOptions[\CURLOPT_PINNEDPUBLICKEY] = Str\format(
        'sha256//%s',
        Str\join($digest, ';sha256//'),
      );
    }

    if (Shapes::keyExists($options, 'bindto')) {
      $bind_to = $options['bindto'];
      if (\file_exists($bind_to)) {
        $curlOptions[\CURLOPT_UNIX_SOCKET_PATH] = $bind_to;
      } else {
        $curlOptions[\CURLOPT_INTERFACE] = $bind_to;
      }
    }

    if (Shapes::keyExists($options, 'max_duration')) {
      if (0 < $options['max_duration']) {
        $curlOptions[\CURLOPT_TIMEOUT_MS] = 1000 * $options['max_duration'];
      }
    }

    $ch = \curl_init();
    foreach ($curlOptions as $opt => $value) {
      if ($value is nonnull) {
        $set = \curl_setopt($ch, $opt, $value);
        if (!$set && \CURLOPT_CERTINFO !== $opt) {
          $const = (string)(
            C\first(Dict\filter_with_key(
              \get_defined_constants(),
              ($key, $value) ==> $opt === $value &&
                'C' === $key[0] &&
                (
                  Str\starts_with($key, 'CURLOPT_') ||
                  Str\starts_with($key, 'CURLINFO_')
                ),
            )) ??
            $opt
          );

          throw new Exception\InvalidArgumentException(
            Str\format('Curl option "%s" is not supported.', $const),
          );
        }
      }
    }

    $result = await Asio\curl_exec($ch);
    $error = \curl_error($ch);
    if ($error !== '') {
      throw new Exception\NetworkException($error);
    }

    $debug_information = \curl_getinfo($ch);
    if ($options['debug'] ?? false) {
      $headers = dict[
        'X-Nuxed-Debug' => vec[
          Str\format('url=%s', $debug_information['url'] as string),
          Str\format(
            'content-type=%s',
            ($debug_information['content_type'] ?? '[none]') as string,
          ),
          Str\format(
            'header-size=%d',
            $debug_information['header_size'] as int,
          ),
          Str\format(
            'request-size=%d',
            $debug_information['request_size'] as int,
          ),
          Str\format('file-time=%d', $debug_information['filetime'] as int),
          Str\format(
            'redirect-count=%d',
            $debug_information['redirect_count'] as int,
          ),
          Str\format(
            'total-time=%f',
            $debug_information['total_time'] as float,
          ),
          Str\format(
            'namelookup-time=%f',
            $debug_information['namelookup_time'] as float,
          ),
          Str\format(
            'connect-time=%f',
            $debug_information['connect_time'] as float,
          ),
          Str\format(
            'pre-transfer-time=%f',
            $debug_information['pretransfer_time'] as float,
          ),
          Str\format(
            'start-transfer-time=%f',
            $debug_information['starttransfer_time'] as float,
          ),
          Str\format(
            'redirect-time=%f',
            $debug_information['redirect_time'] as float,
          ),
          Str\format(
            'redirect-url=%s',
            ($debug_information['redirect_url'] ?? '[none]') as string,
          ),
          Str\format(
            'upload-size=%f',
            $debug_information['size_upload'] as float,
          ),
          Str\format(
            'upload-speed=%f',
            $debug_information['speed_upload'] as float,
          ),
          Str\format(
            'upload-content-length=%f',
            $debug_information['upload_content_length'] as float,
          ),
          Str\format(
            'download-size=%f',
            $debug_information['size_download'] as float,
          ),
          Str\format(
            'download-speed=%f',
            $debug_information['speed_download'] as float,
          ),
          Str\format(
            'download-content-length=%f',
            $debug_information['download_content_length'] as float,
          ),
        ],
      ];
    } else {
      $headers = dict[];
    }

    $response = new Message\Response(
      $debug_information['http_code'] as int,
      $headers,
    );

    $size = (int)$debug_information['header_size'];
    $content = Str\slice($result, $size);
    \curl_close($ch);

    $body = Message\Body\memory();
    await $body->writeAllAsync(Str\slice($result, $size));
    $body->seek(0); // rewind
    $response = $response->withBody($body);
    $response_headers = Str\trim_right(Str\slice($result, 0, $size), "\n\r");
    $last_headers_set = C\lastx(Str\split($response_headers, "\n\r"));
    $headers = Str\split($last_headers_set, "\n");
    foreach ($headers as $header) {
      if (!Str\contains($header, ':')) {
        if (Str\starts_with($header, 'HTTP')) {
          $header = Str\trim($header)
            |> Str\slice(
              $$,
              0,
              Str\search($header, (string)$debug_information['http_code']),
            )
            |> Str\trim($$);

          $response = Regex\first_match(
            $header,
            re"#^(HTTP/)?(?P<version>[1-9]\d*(?:\.\d)?)$#",
          ) as nonnull
            |> $$['version']
            |> Str\contains($$, '.') ? $$ : ($$.'.0')
            |> $response->withProtocolVersion($$);
        }

        continue;
      }

      $response = Str\split($header, ':', 2)
        |> tuple(Str\trim($$[0]), vec[Str\trim($$[1])])
        |> $response->withAddedHeader($$[0], $$[1]);
    }

    return $response;
  }
}
