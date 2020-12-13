namespace Nuxed\Console\Exception;

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
interface Exception extends Rx\Exception {
}
