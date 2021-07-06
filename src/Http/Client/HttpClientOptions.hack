/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Http\Client;

type HttpClientOptions = shape(
  ?'http_version' => string,

  ?'base_uri' => string,

  ?'headers' => KeyedContainer<string, Container<string>>,

  // a token enabling HTTP Bearer authorization (RFC 6750)
  ?'auth_bearer' => string,

  // the name of the file containing the cookie data.
  // the cookie file can be in Netscape format, or just plain HTTP-style headers dumped into a file.
  // if the name is an empty string, no cookies are loaded, but cookie handling is still enabled.
  ?'cookie_file' => string,

  // the maximum number of redirects to follow; a value lower or equal to 0 means
  //    redirects should not be followed; "Authorization" and "Cookie" headers MUST
  //    NOT follow except for the initial host name
  ?'max_redirects' => int,

  // a container of host to IP address that SHOULD replace DNS resolution
  ?'resolve' => KeyedContainer<string, string>,

  // by default, the proxy-related env vars handled by curl SHOULD be honored
  ?'proxy' => string,

  // a comma separated list of hosts that do not require a proxy to be reached
  ?'no_proxy' => string,

  // the inactivity timeout - defaults to 30
  ?'connect_timeout' => float,

  // the total timeout - defaults to 60
  ?'timeout' => float,

  // the maximum execution time for the request+response as a whole;
  // a value lower than or equal to 0 means it is unlimited
  ?'max_duration' => float,

  // the interface or the local socket to bind to - defaults to '0'
  ?'bindto' => string,

  // Require verification of SSL certificate used.
  ?'verify_peer' => bool,
  ?'verify_host' => bool,

  // location of Certificate Authority file on local filesystem which should be used with the verify_peer context option to authenticate the identity of the remote peer.
  ?'cafile' => string,

  // if cafile is not specified or if the certificate is not found there, the directory pointed to by capath is searched for a suitable certificate.
  //    capath must be a correctly hashed certificate directory.
  ?'capath' => string,

  // path to local certificate file on filesystem.
  //    it must be a PEM encoded file which contains your certificate and private key.
  //    it can optionally contain the certificate chain of issuers.
  //    the private key also may be contained in a separate file specified by local_pk.
  ?'local_cert' => string,

  // path to local private key file on filesystem in case of separate files for certificate (local_cert) and private key.
  ?'local_pk' => string,

  // passphrase with which your local_cert file was encoded.
  ?'passphrase' => string,

  // sets the list of available ciphers. The format of the string is described in
  //    https://www.openssl.org/docs/manmaster/man1/ciphers.html#CIPHER-LIST-FORMAT
  ?'ciphers' => Container<string>,

  // aborts when the remote certificate digest doesn't match the specified hash.
  //    the keys indicate the hashing algorithm name and each corresponding value is the expected digest.
  ?'peer_fingerprint' => KeyedContainer<string, Container<string>>,

  // if set to True, a peer_certificate_chain context option will be created containing the certificate chain.
  ?'capture_peer_cert_chain' => bool,

  // If set, connection will be made to the unix domain socket instead of establishing a TCP connection to a host.
  // Since no TCP connection is created, there's no need to resolve the DNS hostname in the URL.
  //
  // Note: proxy and DNS options such as "proxy", and "resolve" have no effect either as these are TCP-oriented.
  ?'unix_socket' => string,

  // if set to True, an additional `X-Nuxed-Debug` header will be added to the response
  // containing debug information about request.
  // each header value will use format of "information=value" ( e.g = "header-size=230" )
  ?'debug' => bool,

  ...
);
