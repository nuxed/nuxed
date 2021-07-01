/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Http\Message;

enum HttpMethod: string as string {
  GET = 'GET';
  HEAD = 'HEAD';
  POST = 'POST';
  PUT = 'PUT';
  PATCH = 'PATCH';
  DELETE = 'DELETE';
  OPTIONS = 'OPTIONS';
  PURGE = 'PURGE';
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
