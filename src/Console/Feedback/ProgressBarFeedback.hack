namespace Nuxed\Console\Feedback;

use namespace Nuxed\Console;
use namespace Nuxed\Console\Output;
use namespace HH\Lib\{C, Math, Str};

/**
 * The `ProgressBarFeedback` class displays feedback information with a progress bar.
 * Additional information including percentage done, time elapsed, and time
 * remaining is included by default.
 */
final class ProgressBarFeedback extends AbstractFeedback {
  /**
   * The 2-string character format to use when constructing the displayed bar.
   */
  protected vec<string> $characterSequence = vec['=', '>', ' '];

  /**
   * {@inheritdoc}
   */
  <<__Override>>
  protected async function display(bool $finish = false): Awaitable<void> {
    if (!$finish && $this->current === $this->total) {
      return;
    }

    $completed = $this->getPercentageComplete();
    $variables = dict<string, string>($this->buildOutputVariables());
    if ($finish) {
      $variables['estimated'] = $variables['elapsed'];
    }

    // Need to make prefix and suffix before the bar so we know how long to render it.
    $prefix = $this->insert($this->prefix, $variables);
    $prefixLength = Str\length(
      $this->output->format($prefix, Output\Type::PLAIN),
    );

    $suffix = $this->insert($this->suffix, $variables);
    $suffixLength = Str\length(
      $this->output->format($suffix, Output\Type::PLAIN),
    );

    if (!Console\Terminal::isDecorated()) {
      return;
    }

    $width = await Console\Terminal::getWidth();
    $size = $width - ($prefixLength + $suffixLength);
    if ($size < 0) {
      $size = 0;
    }

    $completed = (int)Math\floor($completed * $size);
    $rest = $size - ($completed + \mb_strlen($this->characterSequence[1]));

    // Str\slice is needed to trim off the bar cap at 100%
    $bar = Str\repeat($this->characterSequence[0], $completed)
      |> $$.$this->characterSequence[1]
      |> $$.\str_repeat($this->characterSequence[2], $rest < 0 ? 0 : $rest)
      |> \mb_substr($$, 0, $size);

    $variables = dict[
      'prefix' => $prefix,
      'feedback' => $bar,
      'suffix' => $suffix,
    ];

    // format message
    $output = $this->insert($this->format, $variables)
      // pad the output to the terminal width
      |> Str\pad_right($$, $width);


    $cursor = null;
    if ($this->position is nonnull) {
      list($column, $row) = $this->position;
      $cursor = $this->output->getCursor();
      await $cursor->save();
      await $cursor->move($column, $row);
    }

    await $this->output->erase();

    if ($finish) {
      await $this->output->writeln($output);
    } else {
      await $this->output->write($output);
    }

    if ($cursor is nonnull) {
      await $cursor->restore();
    }
  }

  /**
   * {@inheritdoc}
   */
  <<__Override>>
  public function setCharacterSequence(Container<string> $characters): this {
    if (C\count($characters) !== 3) {
      throw new Console\Exception\InvalidCharacterSequenceException(
        'Display bar must only contain 3 values',
      );
    }

    parent::setCharacterSequence($characters);
    return $this;
  }

}
