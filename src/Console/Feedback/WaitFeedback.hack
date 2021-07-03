/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Console\Feedback;

use namespace Nuxed\Console;
use namespace HH\Lib\{C, Str};

/**
 * The `WaitFeedback` class displays feedback by cycling through a series of characters.
 */
final class WaitFeedback extends AbstractFeedback {

  /**
   * {@inheritdoc}
   */
  protected vec<string> $characterSequence = vec[
    '-',
    '\\',
    '|',
    '/',
  ];

  /**
   * {@inheritdoc}
   */
  protected string $prefix = '{:message} ';

  /**
   * {@inheritdoc}
   */
  protected string $suffix = '';

  /**
   * {@inheritdoc}
   */
  <<__Override>>
  protected async function display(bool $finish = false): Awaitable<void> {
    $variables = $this->buildOutputVariables();

    $index = $this->iteration % C\count($this->characterSequence);
    $feedback = Str\pad_right(
      $this->characterSequence[$index],
      $this->maxLength + 1,
    );

    $prefix = $this->insert($this->prefix, $variables);
    $suffix = $this->insert($this->suffix, $variables);
    if (!Console\Terminal::isDecorated()) {
      return;
    }

    $variables = dict[
      'prefix' => $prefix,
      'feedback' => $feedback,
      'suffix' => $suffix,
    ];

    $width = await Console\Terminal::getWidth();
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
      await $this->output->writeLine($output);
    } else {
      await $this->output->write($output);
    }

    if ($cursor is nonnull) {
      await $cursor->restore();
    }
  }
}
