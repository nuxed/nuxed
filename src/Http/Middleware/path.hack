/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Http\Middleware;

use namespace Nuxed\Http\Middleware;

function path(
  string $path,
  Middleware\IMiddleware $middleware,
)[]: PathDecorator {
  return new PathDecorator($path, $middleware);
}
