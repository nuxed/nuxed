namespace Nuxed\Console;

use namespace HH;
use namespace HH\Lib\{C, Dict, Str, Vec};
use namespace Nuxed\{Environment, EventDispatcher};

/**
 * The `Application` class bootstraps and handles Input and Output to process and
 * run necessary commands.
 */
class Application {
  /**
   * A decorator banner to `brand` the application.
   */
  protected string $banner = '';

  /**
   * Store added commands until we inject them into the `Input` at runtime.
   */
  protected dict<string, Command\Command> $commands = dict[];

  /**
  * The `Loader` instances to use to lookup commands.
  */
  protected vec<Command\Loader\ILoader> $loaders = vec[];

  /**
   * Error Handler used to handle exceptions thrown during command execution.
   */
  protected ErrorHandler\IErrorHandler $errorHandler;

  /**
   * Event Dispatcher to dispatch events during the application lifecycle.
   */
  protected ?EventDispatcher\IEventDispatcher $dispatcher = null;

  protected bool $autoExit = true;

  /**
   * Construct a new `Application` instance.
   */
  public function __construct(
    /**
    * The name of the application.
    */
    protected string $name = '',

    /**
     * The version of the application.
     */
    protected string $version = '',
  ) {
    $this->errorHandler = new ErrorHandler\StandardErrorHandler();
  }

  /**
   * Sets the `EventDispatcher` to be used for dispatching events.
   */
  final public function setEventDispatcher(
    EventDispatcher\IEventDispatcher $dispatcher,
  ): this {
    $this->dispatcher = $dispatcher;

    return $this;
  }

  /**
   * Retrieve the `EventDispatcher` instance attached to the application ( if any ).
   */
  final public function getEventDispatcher(
  ): ?EventDispatcher\IEventDispatcher {
    return $this->dispatcher;
  }

  /**
   * Sets the `ErrorHandler` to be used for handling exceptions throw during
   * the command execution.
   */
  final public function setErrorHandler(
    ErrorHandler\IErrorHandler $errorHandler,
  ): this {
    $this->errorHandler = $errorHandler;

    return $this;
  }

  /**
   * Retrieve the `ErrorHandler` instance attached to the application.
   */
  final public function getErrorHandler(): ErrorHandler\IErrorHandler {
    return $this->errorHandler;
  }

  /**
   * Add a `CommandLoader` to use for command discovery.
   */
  public function addLoader(Command\Loader\ILoader $loader): this {
    foreach ($loader->getNames() as $name) {
      _Private\validate_command_name($name);
    }

    $this->loaders[] = $loader;

    return $this;
  }

  /**
   * Add a `Command` to the application to be parsed by the `Input`.
   */
  public function add(Command\Command $command): this {
    if (!$command->isEnabled()) {
      return $this;
    }

    _Private\validate_command_name($command->getName());
    foreach ($command->getAliases() as $alias) {
      _Private\validate_command_name($alias);
    }

    $this->commands[$command->getName()] = $command;

    return $this;
  }

  /**
   * Returns true if the command exists, false otherwise.
   */
  public function has(string $name): bool {
    if (C\contains_key($this->commands, $name)) {
      return true;
    }

    foreach ($this->loaders as $loader) {
      if ($loader->has($name)) {
        return true;
      }
    }

    return false;
  }

  /**
   * Returns a registered command by name or alias.
   */
  public function get(string $name): Command\Command {
    if (C\contains_key($this->commands, $name)) {
      return $this->commands[$name];
    }

    foreach ($this->loaders as $loader) {
      if ($loader->has($name)) {
        return $loader->get($name);
      }
    }

    throw new Exception\CommandNotFoundException(
      Str\format('The command "%s" does not exist.', $name),
    );
  }

  /**
   * Finds a command by name or alias.
   *
   * Contrary to get, this command tries to find the best
   * match if you give it an abbreviation of a name or alias.
   */
  public function find(string $name): Command\Command {
    foreach ($this->commands as $command) {
      foreach ($command->getAliases() as $alias) {
        if (!$this->has($alias)) {
          $this->commands[$alias] = $command;
        }
      }
    }

    if ($this->has($name)) {
      return $this->get($name);
    }

    $allCommands = Vec\keys($this->commands);
    foreach ($this->loaders as $loader) {
      $allCommands = Vec\concat($allCommands, $loader->getNames());
    }

    $message = Str\format('Command "%s" is not defined.', $name);
    $alternatives = $this->findAlternatives($name, $allCommands);
    if (!C\is_empty($alternatives)) {
      // remove hidden commands
      $alternatives = Vec\filter(
        $alternatives,
        (string $name): bool ==> !$this->get($name)->isHidden(),
      );
      if (1 === C\count($alternatives)) {
        $message .= Str\format(
          '%s%sDid you mean this?%s%s',
          Output\IOutput::EndOfLine,
          Output\IOutput::EndOfLine,
          Output\IOutput::EndOfLine,
          Output\IOutput::EndOfLine,
        );
      } else {
        $message .= Str\format(
          '%s%sDid you mean one of these?%s%s',
          Output\IOutput::EndOfLine,
          Output\IOutput::EndOfLine,
          Output\IOutput::EndOfLine,
          Output\IOutput::EndOfLine,
        );
      }

      foreach ($alternatives as $alternative) {
        $message .= Str\format(
          '    - %s%s',
          $alternative,
          Output\IOutput::EndOfLine,
        );
      }
    }

    throw new Exception\CommandNotFoundException($message);
  }

  /**
   * Gets the commands.
   *
   * The container keys are the full names and the values the command instances.
   */
  public function all(): KeyedContainer<string, Command\Command> {
    $commands = $this->commands;
    foreach ($this->loaders as $loader) {
      foreach ($loader->getNames() as $name) {
        if (!C\contains_key($commands, $name) && $this->has($name)) {
          $commands[$name] = $this->get($name);
        }
      }
    }

    return $commands;
  }

  /**
   * Gets whether to automatically exit after a command execution or not.
   *
   * @return bool Whether to automatically exit after a command execution or not
   */
  public function isAutoExitEnabled(): bool {
    return $this->autoExit;
  }

  /**
   * Sets whether to automatically exit after a command execution or not.
   */
  public function setAutoExit(bool $boolean): this {
    $this->autoExit = $boolean;

    return $this;
  }

  /**
   * Bootstrap the `Application` instance with default parameters and global
   * settings.
   */
  protected async function bootstrap(
    Input\IInput $input,
    Output\IOutput $_output,
  ): Awaitable<void> {
    /*
     * Add global flags
     */
    $input->addFlag(
      new Input\Definition\Flag('help', 'Display this help screen.')
        |> $$->setAlias('h'),
    );
    $input->addFlag(
      new Input\Definition\Flag('quiet', 'Suppress all output.')
        |> $$->setAlias('q'),
    );
    $input->addFlag(
      new Input\Definition\Flag(
        'verbose',
        'Set the verbosity of the application\'s output.',
      )
        |> $$->setAlias('v')
        |> $$->setStackable(true),
    );
    $input->addFlag(
      new Input\Definition\Flag('version', 'Display the application\'s version')
        |> $$->setAlias('V'),
    );
    $input
      ->addFlag(new Input\Definition\Flag('ansi', 'Force ANSI output'));
    $input
      ->addFlag(new Input\Definition\Flag('no-ansi', 'Disable ANSI output'));
  }

  /**
   * Retrieve the application's banner.
   */
  public function getBanner(): string {
    return $this->banner;
  }

  /**
   * Retrieve the application's name.
   */
  public function getName(): string {
    return $this->name;
  }

  /**
   * Retrieve the application's version.
   */
  public function getVersion(): string {
    return $this->version;
  }

  /**
   * Run the application.
   */
  public async function run(
    ?Input\IInput $input = null,
    ?Output\IOutput $output = null,
    bool $catch = true,
  ): Awaitable<int> {
    Environment\put('COLUMNS', (string)await Terminal::getWidth());
    Environment\put('LINES', (string)await Terminal::getHeight());
    if ($input is null) {
      $input = input();
    }

    if ($output is null) {
      $output = output();
    }

    $command = null;
    $exitCode = Command\ExitCode::SUCCESS;
    try {
      await $this->bootstrap($input, $output);

      if ($input->getFlag('ansi')->getValue() === 1) {
        Terminal::setDecorated(true);
      } else if ($input->getFlag('no-ansi')->getValue() === 1) {
        Terminal::setDecorated(false);
      }

      $verbositySet = false;
      if ($input->getFlag('quiet')->exists()) {
        $verbositySet = true;
        Environment\put('SHELL_VERBOSITY', (string)Output\Verbosity::QUIET);

        $output->setVerbosity(Output\Verbosity::QUIET);
      }

      if (!$verbositySet) {
        $verbosity = $input->getFlag('verbose')->getValue(0) as int;
        switch ($verbosity) {
          case 0:
            $verbosity = Output\Verbosity::NORMAL;
            break;
          case 1:
            $verbosity = Output\Verbosity::VERBOSE;
            break;
          case 2:
            $verbosity = Output\Verbosity::VERY_VERBOS;
            break;
          default:
            $verbosity = Output\Verbosity::DEBUG;
            break;
        }

        Environment\put('SHELL_VERBOSITY', (string)$verbosity);
        $output->setVerbosity($verbosity);
      }

      $commandName = $input->getActiveCommand();
      if ($commandName is null) {
        $input->parse();
        if ($input->getFlag('version')->getValue() === 1) {
          await $this->renderVersionInformation($output);
          $exitCode = Command\ExitCode::SUCCESS;
        } else {
          await $this->renderHelpScreen($input, $output);
          $exitCode = Command\ExitCode::SUCCESS;
        }

      } else {
        $command = $this->find($commandName);
        $exitCode = await $this->runCommand($input, $output, $command);
      }
    } catch (\Throwable $exception) {
      if (!$catch) {
        throw $exception;
      }

      $exitCode = null;
      if ($this->dispatcher is nonnull) {
        $dispatcher = $this->dispatcher;
        $event = await $dispatcher->dispatch<Event\ErrorEvent>(
          new Event\ErrorEvent($input, $output, $exception, $command),
        );

        $exitCode = $event->getExitCode();
      }

      if ($exitCode is null || Command\ExitCode::SUCCESS !== $exitCode) {
        $exitCode = await $this->errorHandler
          ->handle($input, $output, $exception, $command);
      }
    }

    return await $this->terminate($input, $output, $command, $exitCode);
  }

  /**
   * Register and run the `Command` object.
   */
  public async function runCommand(
    Input\IInput $input,
    Output\IOutput $output,
    Command\Command $command,
  ): Awaitable<int> {
    $command->setApplication($this);
    $command->setInput($input);
    $command->setOutput($output);

    $command->registerInput();
    $input->parse(true);

    if ($input->getFlag('help')->getValue() === 1) {
      await $this->renderHelpScreen($input, $output, $command);
      return 0;
    }

    if ($input->getFlag('version')->getValue() === 1) {
      await $this->renderVersionInformation($output);
      return 0;
    }

    $input->validate();

    $dispatcher = $this->dispatcher;
    if ($dispatcher is null) {
      return await $command->run();
    }

    $event = await $dispatcher->dispatch<Event\CommandEvent>(
      new Event\CommandEvent($input, $output, $command),
    );

    if ($event->commandShouldRun()) {
      $exitCode = await $command->run();
    } else {
      $exitCode = Command\ExitCode::SKIPPED_COMMAND;
    }

    return $exitCode;
  }

  /**
   * Render the help screen for the application or the `Command` passed in.
   */
  protected async function renderHelpScreen(
    Input\IInput $input,
    Output\IOutput $output,
    ?Command\Command $command = null,
  ): Awaitable<void> {
    $helpScreen = new HelpScreen($this, $input);
    if ($command is nonnull) {
      $helpScreen->setCommand($command);
    }

    $help = await $helpScreen->render();
    await $output->write($help);
  }

  /**
   * Output version information of the current `Application`.
   */
  protected async function renderVersionInformation(
    Output\IOutput $output,
  ): Awaitable<void> {
    $name = Str\format('<fg=green>%s</>', $this->getName());
    $version = $this->getVersion();
    if ($version !== '') {
      $name .= Str\format(' version <fg=yellow>%s</>', $version);
    }

    await $output->writeln($name);
  }

  /**
   * Set the banner of the application.
   */
  public function setBanner(string $banner): this {
    $this->banner = $banner;

    return $this;
  }

  /**
   * Set the name of the application.
   */
  public function setName(string $name): this {
    $this->name = $name;

    return $this;
  }

  /**
   * Set the version of the application.
   */
  public function setVersion(string $version): this {
    $this->version = $version;

    return $this;
  }

  /**
   * Termination method executed at the end of the application's run.
   */
  protected async function terminate(
    Input\IInput $input,
    Output\IOutput $output,
    ?Command\Command $command,
    int $exitCode,
  ): Awaitable<int> {
    if ($this->dispatcher is nonnull) {
      $dispatcher = $this->dispatcher;
      $event = await $dispatcher->dispatch<Event\TerminateEvent>(
        new Event\TerminateEvent($input, $output, $command, $exitCode),
      );

      $exitCode = $event->getExitCode();
    }

    await $output->flush();

    if ($exitCode > Command\ExitCode::EXIT_STATUS_OUT_OF_RANGE) {
      $exitCode = $exitCode % Command\ExitCode::EXIT_STATUS_OUT_OF_RANGE;
    }

    if ($this->autoExit) {
      exit($exitCode);
    }

    return $exitCode;
  }

  /**
   * Finds alternative of $name among $collection.
   */
  private function findAlternatives(
    string $name,
    Container<string> $collection,
  ): Container<string> {
    $threshold = 1e3;
    $alternatives = dict[];
    $collectionParts = dict[];
    foreach ($collection as $item) {
      $collectionParts[$item] = Str\split($item, ':');
    }

    foreach (Str\split($name, ':') as $i => $subname) {
      foreach ($collectionParts as $collectionName => $parts) {
        $exists = C\contains_key($alternatives, $collectionName);
        if (!C\contains_key($parts, $i)) {
          if ($exists) {
            $alternatives[$collectionName] += $threshold;
          }

          continue;
        }

        $lev = (float)\levenshtein($subname, $parts[$i]);
        if (
          $lev <= Str\length($subname) / 3 ||
          '' !== $subname && Str\contains($parts[$i], $subname)
        ) {
          $alternatives[$collectionName] = $exists
            ? $alternatives[$collectionName] + $lev
            : $lev;
        } else if ($exists) {
          $alternatives[$collectionName] += $threshold;
        }
      }
    }

    foreach ($collection as $item) {
      $lev = (float)\levenshtein($name, $item);
      if ($lev <= Str\length($name) / 3 || Str\contains($item, $name)) {
        $alternatives[$item] = C\contains_key($alternatives, $item)
          ? $alternatives[$item] - $lev
          : $lev;
      }
    }

    return Dict\filter($alternatives, ($lev) ==> $lev < (2 * $threshold))
      |> Dict\sort($$)
      |> Vec\keys($$);
  }
}
