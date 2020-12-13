namespace Nuxed\Http\Server\Handler\Decorator;


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
