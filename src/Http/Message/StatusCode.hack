namespace Nuxed\Http\Message;

/**
 * Defines constants for common HTTP status code.
 *
 * @see https://tools.ietf.org/html/rfc2295#section-8.1
 * @see https://tools.ietf.org/html/rfc2324#section-2.3
 * @see https://tools.ietf.org/html/rfc2518#section-9.7
 * @see https://tools.ietf.org/html/rfc2774#section-7
 * @see https://tools.ietf.org/html/rfc3229#section-10.4
 * @see https://tools.ietf.org/html/rfc4918#section-11
 * @see https://tools.ietf.org/html/rfc5842#section-7.1
 * @see https://tools.ietf.org/html/rfc5842#section-7.2
 * @see https://tools.ietf.org/html/rfc6585#section-3
 * @see https://tools.ietf.org/html/rfc6585#section-4
 * @see https://tools.ietf.org/html/rfc6585#section-5
 * @see https://tools.ietf.org/html/rfc6585#section-6
 * @see https://tools.ietf.org/html/rfc7231#section-6
 * @see https://tools.ietf.org/html/rfc7238#section-3
 * @see https://tools.ietf.org/html/rfc7725#section-3
 * @see https://tools.ietf.org/html/rfc7540#section-9.1.2
 * @see https://tools.ietf.org/html/rfc8297#section-2
 * @see https://tools.ietf.org/html/rfc8470#section-7
 */
enum StatusCode: int as int {
  // Informational 1xx
  CONTINUE = 100;
  SWITCHING_PROTOCOLS = 101;
  PROCESSING = 102;
  EARLY_HINTS = 103;
  // Successful 2xx
  OK = 200;
  CREATED = 201;
  ACCEPTED = 202;
  NON_AUTHORITATIVE_INFORMATION = 203;
  NO_CONTENT = 204;
  RESET_CONTENT = 205;
  PARTIAL_CONTENT = 206;
  MULTI_STATUS = 207;
  ALREADY_REPORTED = 208;
  IM_USED = 226;
  // Redirection 3xx
  MULTIPLE_CHOICES = 300;
  MOVED_PERMANENTLY = 301;
  FOUND = 302;
  SEE_OTHER = 303;
  NOT_MODIFIED = 304;
  USE_PROXY = 305;
  RESERVED = 306;
  TEMPORARY_REDIRECT = 307;
  PERMANENT_REDIRECT = 308;
  // Client Errors 4xx
  BAD_REQUEST = 400;
  UNAUTHORIZED = 401;
  PAYMENT_REQUIRED = 402;
  FORBIDDEN = 403;
  NOT_FOUND = 404;
  METHOD_NOT_ALLOWED = 405;
  NOT_ACCEPTABLE = 406;
  PROXY_AUTHENTICATION_REQUIRED = 407;
  REQUEST_TIMEOUT = 408;
  CONFLICT = 409;
  GONE = 410;
  LENGTH_REQUIRED = 411;
  PRECONDITION_FAILED = 412;
  PAYLOAD_TOO_LARGE = 413;
  URI_TOO_LONG = 414;
  UNSUPPORTED_MEDIA_TYPE = 415;
  RANGE_NOT_SATISFIABLE = 416;
  EXPECTATION_FAILED = 417;
  IM_ATEAPOT = 418;
  MISDIRECTED_REQUEST = 421;
  UNPROCESSABLE_ENTITY = 422;
  LOCKED = 423;
  FAILED_DEPENDENCY = 424;
  TOO_EARLY = 425;
  UPGRADE_REQUIRED = 426;
  PRECONDITION_REQUIRED = 428;
  TOO_MANY_REQUESTS = 429;
  REQUEST_HEADER_FIELDS_TOO_LARGE = 431;
  UNAVAILABLE_FOR_LEGAL_REASONS = 451;
  // Server Errors 5xx
  INTERNAL_SERVER_ERROR = 500;
  NOT_IMPLEMENTED = 501;
  BAD_GATEWAY = 502;
  SERVICE_UNAVAILABLE = 503;
  GATEWAY_TIMEOUT = 504;
  VERSION_NOT_SUPPORTED = 505;
  VARIANT_ALSO_NEGOTIATES = 506;
  INSUFFICIENT_STORAGE = 507;
  LOOP_DETECTED = 508;
  NOT_EXTENDED = 510;
  NETWORK_AUTHENTICATION_REQUIRED = 511;
}
