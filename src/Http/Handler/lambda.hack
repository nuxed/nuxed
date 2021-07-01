/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Http\Handler;

/**
 * Create a server handler from a lambda.
 */
function lambda(LambdaDecorator::TLambda $handler): LambdaDecorator {
  return new LambdaDecorator($handler);
}

/**
 * Alias for `lambda()`
 *
 * @see lambda
 */
function λ(LambdaDecorator::TLambda $handler): LambdaDecorator {
  return lambda($handler);
}
