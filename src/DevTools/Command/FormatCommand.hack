namespace Nuxed\DevTools\Command;

use namespace HH\Asio;
use namespace HH\Lib\Str;
use namespace Nuxed\{Filesystem, Stopwatch};
use namespace Nuxed\Console\{Command, Output, Style};
use namespace Nuxed\Console\Input\Definition;
use namespace Nuxed\DevTools\Formatter;
use namespace Facebook\DiffLib;

final class FormatCommand extends Command\Command {
  public function __construct(private Formatter\IFormatter $formatter) {
    parent::__construct('format');
  }

  <<__Override>>
  public function configure(): void {
    $this
      ->addArgument(new Definition\Argument(
        'root',
        'Specify a root directory directory containing .hhconfig',
        Definition\Mode::REQUIRED,
      ))
      ->addOption(new Definition\Option(
        'indent-width',
        'Specify the number of spaces per indentation level. Defaults to 2',
      ))
      ->addOption(new Definition\Option(
        'line-width',
        'Specify the maximum length for each line. Defaults to 80',
      ))
      ->addFlag(
        new Definition\Flag('tabs', 'Indent with tabs rather than spaces'),
      )
      ->addFlag(new Definition\Flag(
        'dry-run',
        'Only shows which files would have been modified.',
      ))
      ->addFlag(
        new Definition\Flag('diff', 'Also produce diff for each file.'),
      );
  }

  <<__Override>>
  public async function run(): Awaitable<int> {
    $stopwatch = new Stopwatch\Stopwatch();
    $event = $stopwatch->start('format');

    $directory = $this->getArgument('root') as string;
    $folder = new Filesystem\Folder($directory);
    $style = new Style\Style($this->input, $this->output);
    $files = await $folder->find(re"/.*\.hack$/i", true); // find .hack files
    $operations = vec[];
    foreach ($files as $file) {
      $file as Filesystem\File;
      $operations[] = async {
        return await $this->format($file);
      };
    }

    $results = await Asio\v($operations);
    await $style->nl(2);
    $operation = async {
    };
    $dirty = false;
    foreach ($results as $value) {
      list($file, $original_content, $result) = $value;
      if ($result->isChanged()) {
        $dirty = true;
        $operation = async {
          await $operation;
          await $style->section(
            $folder->path()->relativeTo($file->path())->toString(),
          );

          if ($this->getFlag('diff')) {
            await $style->writeln(
              DiffLib\CLIColoredUnifiedDiff::create(
                $original_content,
                $result->getContent(),
              ),
              Output\Verbosity::NORMAL,
              Output\Type::RAW,
            );
          }
        };
      }
    }

    $event->stop();
    await $style->nl();
    await $style->success(Str\format(
      'Checked all files in %f seconds, %f MB memory used.',
      (float)$event->getDuration() / 1000,
      (float)$event->getMemory() / 1024 / 1024,
    ));

    return $dirty ? Command\ExitCode::FAILUER : Command\ExitCode::SUCCESS;
  }

  private async function format(
    Filesystem\File $file,
  ): Awaitable<(Filesystem\File, string, Formatter\Result)> {
    $content = await $file->readAll();
    $result = await $this->formatter->format(
      $content,
      (int)$this->getOption('line-width', '80'),
      (int)$this->getOption('indent-width', '2'),
      (bool)$this->getFlag('tabs'),
    );

    if ($result->isInvalid()) {
      await $this->output->write('<fg=red>E</>', Output\Verbosity::VERBOSE);
      return tuple($file, $content, $result);
    }

    if (!$result->isChanged()) {
      await $this->output->write('.', Output\Verbosity::VERBOSE);
      return tuple($file, $content, $result);
    }

    if (!$this->getFlag('dry-run')) {
      await $file->write($result->getContent());
    }

    await $this->output->write('<fg=green>F</>', Output\Verbosity::VERBOSE);

    return tuple($file, $content, $result);
  }
}
