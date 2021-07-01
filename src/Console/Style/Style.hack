/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Console\Style;

use namespace HH\Lib\{Str, Vec};
use namespace Nuxed\Console;
use namespace Nuxed\Console\{
  Feedback,
  Formatter,
  Input,
  Output,
  Table,
  Tree,
  UserInput,
};
use namespace Nuxed\Console\Output\Sequence;

/**
 * Output decorator helpers for the Nuxed Style Guide.
 *
 * This is a port of Symfony Console Style Guide to Nuxed Console.
 *
 * @see https://github.com/symfony/symfony/blob/99ae043165341550278d350ef9c2e594401895aa/src/Symfony/Component/Console/Style/SymfonyStyle.php
 *
 * @author Saif Eddin Gmat <azjezz@protonmail.com>
 * @author Kevin Bond <kevinbond@gmail.com>
 *
 * @license MIT - https://github.com/symfony/symfony/blob/99ae043165341550278d350ef9c2e594401895aa/LICENSE
 *
 * @copyright (c) 2004-2020 Fabien Potencier
 */
final class Style extends Output\AbstractOutputWrapper implements IOutputStyle {
  private Input\IInput $input;
  private Output\BufferedOutput $buffer;

  public function __construct(Input\IInput $input, Output\IOutput $output) {
    $this->input = $input;
    $this->buffer = new Output\BufferedOutput(
      $output->getVerbosity(),
      $output->getFormatter(),
    );

    parent::__construct($output);
  }

  public function getOutput(): Output\IOutput {
    return $this->output;
  }

  /**
   * Send output to the standard output stream.
   */
  <<__Override>>
  public async function write(
    string $message,
    Output\Verbosity $verbosity = Output\Verbosity::NORMAL,
    Output\Type $type = Output\Type::NORMAL,
  ): Awaitable<void> {
    concurrent {
      await $this->output->write($message, $verbosity, $type);
      await $this->buffer->write($message, $verbosity, $type);
    }
  }

  /**
   * Send output to the standard output stream with a new line charachter appended to the message.
   */
  <<__Override>>
  public async function writeln(
    string $message,
    Output\Verbosity $verbosity = Output\Verbosity::NORMAL,
    Output\Type $type = Output\Type::NORMAL,
  ): Awaitable<void> {
    concurrent {
      await $this->output->writeln($message, $verbosity, $type);
      await $this->buffer->writeln($message, $verbosity, $type);
    }
  }

  /**
   * Clears all characters
   */
  <<__Override>>
  public async function erase(
    Sequence\Erase $mode = Sequence\Erase::LINE,
  ): Awaitable<void> {
    concurrent {
      await $this->output->erase($mode);
      await $this->buffer->erase($mode);
    }
  }

  /**
   * Set the formatter instance.
   */
  <<__Override>>
  public function setFormatter(Formatter\IFormatter $formatter): this {
    $this->output->setFormatter($formatter);
    $this->buffer->setFormatter($formatter);

    return $this;
  }

  /**
   * Set the global verbosity of the `Output`.
   */
  <<__Override>>
  public function setVerbosity(Output\Verbosity $verbosity): this {
    $this->output->setVerbosity($verbosity);
    $this->buffer->setVerbosity($verbosity);

    return $this;
  }

  /**
   * Formats a message as a block of text.
   */
  public async function block(
    string $message,
    Output\Verbosity $verbosity = Output\Verbosity::NORMAL,
    ?string $type = null,
    ?string $style = null,
    string $prefix = '',
    bool $padding = false,
    bool $escape = true,
    bool $indent = true,
  ): Awaitable<void> {
    $lastOperation = async {
      await $this->autoPrependBlock($verbosity);
    };

    foreach (
      $this->createBlock(
        $message,
        $type,
        $style,
        $prefix,
        $padding,
        $escape,
        $indent,
      ) await as $line
    ) {
      $lastOperation = async {
        await $lastOperation;
        await $this->writeln($line, $verbosity);
      };
    }

    await $lastOperation;
    await $this->nl(1, $verbosity);
  }

  /**
   * Formats a command title.
   */
  public async function title(
    string $message,
    Output\Verbosity $verbosity = Output\Verbosity::NORMAL,
  ): Awaitable<void> {
    await $this->autoPrependBlock($verbosity);
    await $this->writeln(
      Str\format(
        '<comment>%s</>',
        $message, // Formatter\escape_trailing_backslash($message),
      ),
      $verbosity,
    );

    await $this->writeln(
      Str\format('<comment>%s</>', Str\repeat(
        '=',
        Str\length($this->output->format($message, Output\Type::PLAIN)),
      )),
      $verbosity,
    );

    await $this->nl(1, $verbosity);
  }

  /**
   * Formats a section title.
   */
  public async function section(
    string $message,
    Output\Verbosity $verbosity = Output\Verbosity::NORMAL,
  ): Awaitable<void> {
    await $this->autoPrependBlock($verbosity);

    await $this->writeln(
      Str\format(
        '<comment>%s</comment>',
        $message, //   Formatter\escape_trailing_backslash($message),
      ),
      $verbosity,
    );

    await $this->writeln(
      Str\format('<comment>%s</comment>', Str\repeat(
        '-',
        Str\length($this->output->format($message, Output\Type::PLAIN)),
      )),
      $verbosity,
    );

    await $this->nl(1, $verbosity);
  }

  /**
   * Formats informational text.
   */
  public async function text(
    string $message,
    Output\Verbosity $verbosity = Output\Verbosity::NORMAL,
  ): Awaitable<void> {
    await $this->autoPrepandText($verbosity);
    await $this->writeln(Str\format(' %s', $message), $verbosity);
  }

  /**
   * Formats a command comment.
   */
  public async function comment(
    string $message,
    Output\Verbosity $verbosity = Output\Verbosity::NORMAL,
  ): Awaitable<void> {
    await $this->block(
      $message,
      $verbosity,
      null,
      null,
      '<fg=default;bg=default> // </>',
      false,
      false,
    );
  }

  /**
   * Formats a success result bar.
   */
  public async function success(
    string $message,
    Output\Verbosity $verbosity = Output\Verbosity::NORMAL,
  ): Awaitable<void> {
    await $this->block(
      $message,
      $verbosity,
      'OK',
      'fg=black;bg=green',
      ' ',
      true,
    );
  }

  /**
   * Formats an error result bar.
   */
  public async function error(
    string $message,
    Output\Verbosity $verbosity = Output\Verbosity::NORMAL,
  ): Awaitable<void> {
    await $this->block($message, $verbosity, 'ERROR', 'error', ' ', true);
  }

  /**
   * Formats an warning result bar.
   */
  public async function warning(
    string $message,
    Output\Verbosity $verbosity = Output\Verbosity::NORMAL,
  ): Awaitable<void> {
    await $this->block($message, $verbosity, 'ERROR', 'warning', ' ', true);
  }

  /**
   * Formats a note admonition.
   */
  public async function note(
    string $message,
    Output\Verbosity $verbosity = Output\Verbosity::NORMAL,
  ): Awaitable<void> {
    await $this->block($message, $verbosity, 'NOTE', 'comment', ' ! ');

  }

  /**
   * Formats a caution admonition.
   */
  public async function caution(
    string $message,
    Output\Verbosity $verbosity = Output\Verbosity::NORMAL,
  ): Awaitable<void> {
    await $this->block($message, $verbosity, 'CAUTION', 'error', ' ! ', true);
  }

  /**
   * Add a newline(s).
   */
  public async function nl(
    int $count = 1,
    Output\Verbosity $verbosity = Output\Verbosity::NORMAL,
  ): Awaitable<void> {
    concurrent {
      await $this->output
        ->write(Str\repeat(Output\IOutput::EndOfLine, $count), $verbosity);

      await $this->buffer
        ->write(Str\repeat(Output\IOutput::EndOfLine, $count), $verbosity);
    }
  }

  /**
   * Construct and return a new `Tree` object.
   */
  public function tree<Tk as arraykey, Tv>(
    KeyedContainer<Tk, Tv> $elements,
  ): Tree\ITree<Tk, Tv> {
    return new Tree\AsciiTree<Tk, Tv>($elements);
  }

  /**
   * Construct and return a new `Table` object.
   */
  public function table(): Table\ITable {
    return new Table\AsciiTable();
  }

  /**
   * Construct and return a new `Confirm` object given the default answer.
   */
  public function confirm(string $default = ''): UserInput\Confirm {
    $confirm = new UserInput\Confirm($this->input, $this);
    $confirm->setDefault($default);
    $confirm->setStrict(true);

    return $confirm;
  }

  /**
   * Construct and return a new `Menu` object given the choices and display
   * message.
   */
  public function menu(
    KeyedContainer<string, string> $choices,
  ): UserInput\Menu {
    $menu = new UserInput\Menu($this->input, $this);
    $menu->setAcceptedValues($choices);
    $menu->setStrict(true);

    return $menu;
  }

  /**
   * Construct and return a new instance of `ProgressBarFeedback`.
   */
  public function progress(
    int $total,
    string $message = '',
    int $interval = 100,
  ): Feedback\ProgressBarFeedback {
    $progress = new Feedback\ProgressBarFeedback(
      $this,
      $total,
      $message,
      $interval,
    );

    $progress->setCharacterSequence(vec[
      '▓', // dark shade character \u2593
      '',
      '░', // light shade character \u2591
    ]);

    return $progress;
  }

  /**
   * Construct and return a new `WaitFeedback` object.
   *
   * @param int    $total     The total number of cycles of the process
   * @param string $message   The message presented with the feedback
   * @param int    $interval  The time interval the feedback should update
   */
  public function wait(
    int $total,
    string $message = '',
    int $interval = 100,
  ): Feedback\WaitFeedback {
    $wait = new Feedback\WaitFeedback($this, $total, $message, $interval);

    return $wait;
  }

  private async function autoPrependBlock(
    Output\Verbosity $verbosity,
  ): Awaitable<void> {
    $length = Str\length(Str\repeat(Output\IOutput::EndOfLine, 2));
    $buffer = $this->buffer->fetch();
    if (Str\length($buffer) < $length) {
      $chars = '';
    } else {
      $chars = Str\slice($buffer, -$length);
    }

    if ('' === $chars) {
      await $this->nl(1, $verbosity);

      return;
    }

    if (Str\ends_with($chars, Output\IOutput::EndOfLine)) {
      if (!Str\starts_with($chars, Output\IOutput::EndOfLine)) {
        await $this->nl(1, $verbosity);
      }

      return;
    }

    await $this->nl(2, $verbosity);
  }
  /**
   * Prepand a new line if the last outputed content isn't "Output\IOutput::EndOfLine"
   */
  private async function autoPrepandText(
    Output\Verbosity $verbosity,
  ): Awaitable<void> {
    $content = $this->buffer->fetch();
    if (!Str\ends_with($content, Output\IOutput::EndOfLine)) {
      await $this->nl(1, $verbosity);
    }
  }

  private async function createBlock(
    string $message,
    ?string $type = null,
    ?string $style = null,
    string $prefix = ' ',
    bool $padding = false,
    bool $escape = false,
    bool $indent = true,
  ): AsyncIterator<string> {
    $width = await Console\Terminal::getWidth();

    $indentLength = 0;
    $lineIndentation = '';
    $prefixLength = Str\length(
      $this->output->format($prefix, Output\Type::PLAIN),
    );

    if ($type is nonnull) {
      $type = Str\format('[%s] ', $type);
      if ($indent) {
        $indentLength = Str\length($type);
        $lineIndentation = Str\repeat(' ', $indentLength);
      }

      $message = $type.$message;
    }

    if ($escape) {
      $message = Formatter\escape($message);
    }

    $lines = Str\split(
      \wordwrap(
        $message,
        $width - $prefixLength - $indentLength,
        Output\IOutput::EndOfLine,
        true,
      ),
      Output\IOutput::EndOfLine,
    );

    $firstLineIndex = 0;
    if ($padding && Console\Terminal::isDecorated()) {
      $firstLineIndex = 1;
      $lines = Vec\concat(vec[''], $lines);
      $lines[] = '';
    }

    foreach ($lines as $i => $line) {
      if ($type is nonnull) {
        $line = $firstLineIndex === $i ? $line : $lineIndentation.$line;
      }

      $line = $prefix.$line;
      $fit = $width -
        Str\length($this->output->format($line, Output\Type::PLAIN));
      if ($fit > 0) {
        $line .= Str\repeat(' ', $fit);
      }

      if ($style) {
        $line = Str\format('<%s>%s</>', $style, $line);
      }

      yield $line;
    }
  }
}
