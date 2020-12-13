namespace Nuxed\Console;

use namespace HH;
use namespace HH\Lib\Str;
use namespace Nuxed\{Environment, EventDispatcher};

/**
 * The `Application` class bootstraps and handles Input and Output to process and
 * run necessary commands.
 */
class Application implements Command\Manager\IManager {
  /**
   * A decorator banner to `brand` the application.
   */
  protected string $banner = '';

  /**
   * Command Manager to manage commands and command loaders.
   */
  protected Command\Manager\IManager $commandManager;

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
    $this->commandManager = new Command\Manager\Manager();
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
   * Retrieve the `Command\Manager` instance attached to the application.
   */
  final public function getCommandManager(): Command\Manager\IManager {
    return $this->commandManager;
  }

  /**
   * Add a `CommandLoader` to use for command discovery.
   */
  public function addLoader(Command\Loader\ILoader $loader): this {
    $this->commandManager->addLoader($loader);

    return $this;
  }

  /**
   * Add a `Command` to the application to be parsed by the `Input`.
   */
  public function add(Command\Command $command): this {
    $this->commandManager->add($command);

    return $this;
  }

  /**
   * Returns true if the command exists, false otherwise.
   */
  public function has(string $name): bool {
    return $this->commandManager->has($name);
  }

  /**
   * Returns a registered command by name or alias.
   */
  public function get(string $name): Command\Command {
    return $this->commandManager->get($name);
  }

  /**
   * Finds a command by name or alias.
   *
   * Contrary to get, this command tries to find the best
   * match if you give it an abbreviation of a name or alias.
   */
  public function find(string $name): Command\Command {
    return $this->commandManager->find($name);
  }

  /**
   * Gets the commands.
   *
   * The container keys are the full names and the values the command instances.
  */
  public function all(): KeyedContainer<string, Command\Command> {
    return $this->commandManager->all();
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

      $commandName = $input->getActiveCommand();

      if ($input->getFlag('ansi')->getValue() === 1) {
        Terminal::setDecorated(true);
      } else if ($input->getFlag('no-ansi')->getValue() === 1) {
        Terminal::setDecorated(false);
      }

      $flag = $input->getFlag('quiet');
      $verbositySet = false;
      if ($flag->exists()) {
        $verbositySet = true;
        Environment\put('SHELL_VERBOSITY', (string)Output\Verbosity::QUIET);

        $output->setVerbosity(Output\Verbosity::QUIET);
      }

      if ($verbositySet === false) {
        $flag = $input->getFlag('verbose');
        $verbosity = $flag->getValue(0) as int;
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
}
