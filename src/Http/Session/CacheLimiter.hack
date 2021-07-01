/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Http\Session;

enum CacheLimiter: string as string {
  NO_CACHE = 'nocache';
  PUBLIC = 'public';
  PRIVATE = 'private';
  PRIVATE_NO_EXPIRE = 'private_no_expire';
}
