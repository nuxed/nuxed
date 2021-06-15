namespace Nuxed\Console\Exception;

use type Exception as BuiltinException;

<<__Sealed(
  CommandNotFoundException::class,
  InvalidArgumentException::class,
  InvalidCharacterSequenceException::class,
  InvalidCommandException::class,
  InvalidInputDefinitionException::class,
  InvalidNumberOfArgumentsException::class,
  InvalidNumberOfCommandsException::class,
  MissingValueException::class,
  RuntimeException::class,
)>>
interface Exception {
  require extends BuiltinException;
}
