namespace Nuxed\Http\Middleware;

function lambda(LambdaDecorator::TLambda $lambda)[]: LambdaDecorator {
  return new LambdaDecorator($lambda);
}

/**
 * Alias for `lambda()`
 *
 * @see lambda
 */
function λ(LambdaDecorator::TLambda $handler)[]: LambdaDecorator {
  return lambda($handler);
}
