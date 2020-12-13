namespace Nuxed\Http\Message;

/**
 * Defines constants for common HTTP request methods.
 */
enum RequestMethod: string as string {
  HEAD = 'HEAD';
  GET = 'GET';
  POST = 'POST';
  PUT = 'PUT';
  PATCH = 'PATCH';
  DELETE = 'DELETE';
  PURGE = 'PURGE';
  OPTIONS = 'OPTIONS';
  TRACE = 'TRACE';
  CONNECT = 'CONNECT';
  REPORT = 'REPORT';
  LOCK = 'LOCK';
  UNLOCK = 'UNLOCK';
  COPY = 'COPY';
  MOVE = 'MOVE';
  MERGE = 'MERGE';
  NOTIFY = 'NOTIFY';
  SUBSCRIBE = 'SUBSCRIBE';
  UNSUBSCRIBE = 'UNSUBSCRIBE';
}
