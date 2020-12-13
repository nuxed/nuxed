namespace Nuxed\Console\Input;

use namespace HH\Lib\{IO, Regex, Str, Vec};
use namespace Nuxed\Console;
use namespace Nuxed\Console\Command;

/**
 * {@inheritdoc}
 */
final class Input implements IInput {
  /**
   * Bag container holding all registered `Argument` objects
   */
  protected Bag\ArgumentBag $arguments;

  /**
   * The active command name (if any) that is parsed from the provided input.
   */
  protected ?string $command;

  /**
   * All available `Command` candidates to parse from the input.
   */
  protected dict<string, Command\Command> $commands = dict[];

  /**
   * Bag container holding all registered `Flag` objects
   */
  protected Bag\FlagBag $flags;

  /**
   * The `Lexer` that will traverse and help parse the provided input.
   */
  protected Lexer $input;

  /**
   * All parameters provided in the input that do not match a given `Command`
   * or `Definition`.
   */
  protected vec<shape(
    'raw' => string,
    'value' => string,
  )> $invalid = vec[];

  /**
   * Bag container holding all registered `Option` objects
   */
  protected Bag\OptionBag $options;

  /**
   * Boolean if the provided input has already been parsed or not.
   */
  protected bool $parsed = false;

  /**
   * Raw input used at creation of the `Input` object.
   */
  protected vec<string> $rawInput;

  /**
   * Stream handle for user input.
   */
  protected IO\ReadHandle $stdin;

  /**
   * The 'strict' value of the `Input` object. If set to `true`, then any invalid
   * parameters found in the input will throw an exception.
   */
  protected bool $strict = false;

  private IO\BufferedReader $reader;

  /**
   * Construct a new instance of Input
   */
  public function __construct(
    Container<string> $args,
    IO\ReadHandle $stdin,
    bool $strict = false,
  ) {
    $args = Vec\filter<string>($args, (string $arg): bool ==> '' !== $arg);
    $this->stdin = $stdin;
    $this->reader = new IO\BufferedReader($stdin);
    $this->rawInput = $args;
    $this->input = new Lexer($args);
    $this->flags = new Bag\FlagBag();
    $this->options = new Bag\OptionBag();
    $this->arguments = new Bag\ArgumentBag();
    $this->strict = $strict;
  }

  /**
   * {@inheritdoc}
   */
  public function addArgument(Definition\Argument $argument): this {
    $this->arguments->set($argument->getName(), $argument);

    return $this;
  }

  /**
   * {@inheritdoc}
   */
  public function addFlag(Definition\Flag $flag): this {
    $this->flags->set($flag->getName(), $flag);

    return $this;
  }

  /**
   * {@inheritdoc}
   */
  public function addOption(Definition\Option $option): this {
    $this->options->set($option->getName(), $option);

    return $this;
  }

  /**
   * {@inheritdoc}
   */
  public function getActiveCommand(): ?string {
    if ($this->parsed === true) {
      return $this->command;
    }

    if ($this->command is nonnull) {
      return $this->command;
    }

    $this->parse();

    return $this->command;
  }

  /**
   * {@inheritdoc}
   */
  public function getArgument(string $key): Definition\Argument {
    $argument = $this->arguments->get($key);
    if ($argument is null) {
      throw new Console\Exception\InvalidInputDefinitionException(
        Str\format('The argument %s does not exist.', $key),
      );
    }

    return $argument;
  }

  /**
   * {@inheritdoc}
   */
  public function getArguments(): Bag\ArgumentBag {
    return $this->arguments;
  }

  /**
   * {@inheritdoc}
   */
  public function getFlag(string $key): Definition\Flag {
    $flag = $this->flags->get($key);
    if ($flag is null) {
      throw new Console\Exception\InvalidInputDefinitionException(
        Str\format('The flag %s does not exist.', $key),
      );
    }

    return $flag;
  }

  /**
   * {@inheritdoc}
   */
  public function getFlags(): Bag\FlagBag {
    return $this->flags;
  }

  /**
   * {@inheritdoc}
   */
  public function getOption(string $key): Definition\Option {
    $option = $this->options->get($key);
    if ($option is null) {
      throw new Console\Exception\InvalidInputDefinitionException(
        Str\format('The option %s does not exist.', $key),
      );
    }

    return $option;
  }

  /**
   * {@inheritdoc}
   */
  public function getOptions(): Bag\OptionBag {
    return $this->options;
  }

  /**
   * {@inheritdoc}
   */
  public function getStrict(): bool {
    return $this->strict;
  }

  /**
   * {@inheritdoc}
   */
  public async function getUserInput(?int $length = null): Awaitable<string> {
    if ($length is nonnull) {
      return await $this->reader->readAsync($length);
    }

    return Str\trim(await $this->reader->readLinexAsync());
  }

  /**
   * {@inheritdoc}
   */
  public function parse(bool $rewind = false): void {
    $lexer = $this->input;
    if ($rewind) {
      $lexer = new Lexer(Vec\map($this->invalid, ($entry) ==> $entry['raw']));
    }

    foreach ($lexer as $val) {
      if ($this->parseFlag($val)) {
        continue;
      }

      if ($this->parseOption($val, $lexer)) {
        continue;
      }

      if ($this->command is null && !Lexer::isArgument($val['raw'])) {
        // If we haven't parsed a command yet, do so.
        $this->command = $val['value'];
        continue;
      }

      if ($this->parseArgument($val)) {
        continue;
      }

      $this->invalid[] = $val;
    }

    if ($this->command is null && $this->strict === true) {
      throw new Console\Exception\InvalidNumberOfCommandsException(
        'No command was parsed from the input.',
      );
    }

    $this->parsed = true;
  }

  /**
   * {@inheritdoc}
   */
  public function validate(): void {
    foreach ($this->flags->getIterator() as $name => $flag) {
      if ($flag->getMode() !== Definition\Mode::REQUIRED) {
        continue;
      }

      if ($flag->getValue() is null) {
        throw new Console\Exception\MissingValueException(
          Str\format('Required flag `%s` is not present.', $name),
        );
      }
    }

    foreach ($this->options->getIterator() as $name => $option) {
      if ($option->getMode() !== Definition\Mode::REQUIRED) {
        continue;
      }

      if ($option->getValue() is null) {
        throw new Console\Exception\MissingValueException(
          Str\format('No value present for required option `%s`.', $name),
        );
      }
    }

    foreach ($this->arguments->getIterator() as $name => $argument) {
      if ($argument->getMode() !== Definition\Mode::REQUIRED) {
        continue;
      }

      if ($argument->getValue() is null) {
        throw new Console\Exception\MissingValueException(
          Str\format('No value present for required argument `%s`.', $name),
        );
      }
    }

    if ($this->strict) {
      foreach ($this->invalid as $value) {
        throw new Console\Exception\RuntimeException(
          Str\format('The `%s` parameter does not exist.', $value['raw']),
        );
      }
    }
  }

  /**
   * Determine if a RawInput matches an `Argument` candidate. If so, save its
   * value.
   */
  protected function parseArgument(
    shape(
      'raw' => string,
      'value' => string,
    ) $input,
  ): bool {
    foreach ($this->arguments as $argument) {
      if ($argument->getValue() is null) {
        $argument->setValue($input['raw']);
        $argument->setExists(true);

        $this->invalid = Vec\filter(
          $this->invalid,
          ($entry) ==> $entry['value'] !== $input['value'],
        );

        return true;
      }
    }

    return false;
  }

  /**
   * Determine if a RawInput matches a `Flag` candidate. If so, save its
   * value.
   */
  protected function parseFlag(
    shape(
      'raw' => string,
      'value' => string,
    ) $input,
  ): bool {
    $key = $input['value'];
    $flag = $this->flags->get($key);
    if ($flag is nonnull) {
      if ($flag->isStackable()) {
        $flag->increaseValue();
      } else {
        $flag->setValue(1);
      }

      $flag->setExists(true);

      $this->invalid = Vec\filter(
        $this->invalid,
        ($entry) ==> $entry['value'] !== $input['value'],
      );

      return true;
    }

    foreach ($this->flags->getIterator() as $_name => $flag) {
      if ($key === $flag->getNegativeAlias()) {
        $flag->setValue(0);
        $flag->setExists(true);

        $this->invalid = Vec\filter(
          $this->invalid,
          ($entry) ==> $entry['value'] !== $input['value'],
        );

        return true;
      }
    }

    return false;
  }

  /**
   * Determine if a RawInput matches an `Option` candidate. If so, save its
   * value.
   */
  protected function parseOption(
    shape(
      'raw' => string,
      'value' => string,
    ) $input,
    Lexer $lexer,
  ): bool {
    $key = $input['value'];
    $option = $this->options->get($key);
    if ($option is null) {
      return false;
    }

    // Peak ahead to make sure we get a value.
    $nextValue = $lexer->peek();
    if ($nextValue is null) {
      throw new Console\Exception\MissingValueException(
        Str\format('No value given for the option %s.', $input['value']),
      );
    }

    if (!$lexer->end() && Lexer::isArgument($nextValue['raw'])) {
      throw new Console\Exception\MissingValueException(
        Str\format('No value is present for option %s.', $key),
      );
    }

    $lexer->shift();
    $value = $lexer->current();

    $matches = vec[];
    if (Regex\matches($value['raw'], re"#\A\"(.+)\"$#")) {
      $matches = Regex\first_match($value['raw'], re"#\A\"(.+)\"$#") as nonnull;
      $value = $matches[1];
    } else if (Regex\matches($value['raw'], re"#\A'(.+)'$#")) {
      $matches = Regex\first_match($value['raw'], re"#\A'(.+)'$#") as nonnull;
      $value = $matches[1];
    } else {
      $value = $value['raw'];
    }

    $option->setValue($value);
    $option->setExists(true);

    $this->invalid = Vec\filter(
      $this->invalid,
      ($entry) ==> $entry['value'] !== $input['value'],
    );

    return true;
  }

  /**
   * {@inheritdoc}
   */
  public function setArguments(Bag\ArgumentBag $arguments): this {
    $this->arguments = $arguments;

    return $this;
  }

  /**
   * {@inheritdoc}
   */
  public function setFlags(Bag\FlagBag $flags): this {
    $this->flags = $flags;

    return $this;
  }

  /**
   * {@inheritdoc}
   */
  public function setInput(Container<string> $args): this {
    $this->rawInput = vec<string>($args);
    $this->input = new Lexer($args);
    $this->parsed = false;
    $this->command = null;

    return $this;
  }

  /**
   * {@inheritdoc}
   */
  public function setOptions(Bag\OptionBag $options): this {
    $this->options = $options;

    return $this;
  }

  /**
   * {@inheritdoc}
   */
  public function setStrict(bool $strict): this {
    $this->strict = $strict;

    return $this;
  }
}
