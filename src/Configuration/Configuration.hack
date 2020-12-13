namespace Nuxed\Configuration;

use namespace HH\Lib\Str;
use namespace Facebook\{TypeAssert, TypeSpec};

final class Configuration implements IConfiguration {
  public function __construct(
    private KeyedContainer<string, mixed> $configuration,
  ) {}

  /**
   * Fetches a value from the config.
   */
  public function get<reify T>(string $key): T {
    $value = $this->configuration[$key] ?? null;
    if (null === $value) {
      throw new Exception\MissingConfigurationException(
        Str\format('Configuration key "%s" is not present.', $key),
      );
    }

    try {
      return TypeSpec\of<T>()->coerceType($value);
    } catch (TypeAssert\TypeCoercionException $exception) {
      throw new Exception\InvalidTypeException(
        $exception->getMessage(),
        $exception->getCode(),
        $exception,
      );
    } catch (TypeAssert\UnsupportedTypeException $exception) {
      throw new Exception\InvalidTypeException(
        $exception->getMessage(),
        $exception->getCode(),
        $exception,
      );
    }
  }
}
