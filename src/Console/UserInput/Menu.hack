namespace Nuxed\Console\UserInput;

use namespace HH\Lib\{C, Str, Vec};
use namespace Nuxed\Console;
use namespace Nuxed\Console\Output;

/**
 * The `Menu` class presents the user with a prompt and a list of available
 * options to choose from.
 */
final class Menu extends AbstractUserInput<string> {

  /**
   * {@inheritdoc}
   */
  <<__Override>>
  public async function prompt(string $prompt): Awaitable<string> {
    $keys = Vec\keys($this->acceptedValues);
    $values = vec<string>($this->acceptedValues);


    $lastOperation = async {
      if ($this->position is nonnull) {
        list($column, $row) = $this->position;
        await $this->output->getCursor()->save();
        await $this->output->getCursor()->move($column, $row);
      }
    };

    $lines = Str\split($prompt, Output\IOutput::EndOfLine);
    foreach ($lines as $i => $line) {
      $lastOperation = async {
        await $lastOperation;

        await $this->output
          ->writeln(Str\format(
            '%s  <fg=green>%s</>',
            0 === $i ? Output\IOutput::EndOfLine : '',
            $line,
          ));
      };
    }

    $lastOperation = async {
      await $lastOperation;

      await $this->output->writeln('');
    };

    foreach ($values as $index => $item) {
      $lastOperation = async {
        await $lastOperation;
        await $this->output
          ->writeln(
            Str\format('  [<fg=yellow>%d</>] %s', $index + 1, (string)$item),
          );
      };
    }

    await $lastOperation;
    await $this->output->writeln('');

    $result = await $this->selection($values, $keys);
    if ($this->position is nonnull) {
      await $this->output->getCursor()->restore();
    }

    return $result;
  }

  /**
   * The purpose of this functions is to avoid using `await` instead a loop.
   *
   * @ignore
   */
  private async function selection(
    KeyedContainer<int, string> $values,
    KeyedContainer<int, string> $keys,
  ): Awaitable<string> {
    await $this->output
      ->write('<fg=green>↪</> ', Console\Output\Verbosity::NORMAL);
    $input = await $this->input->getUserInput();
    $input = Str\to_int($input);
    if ($input is nonnull) {
      $input--;

      if (C\contains_key<int, int, string>($values, $input)) {
        return $keys[$input];
      }

      if ($input < 0 || $input >= C\count($values)) {
        await $this->output
          ->writeln('<error>Invalid menu selection: out of range.</>');
      }
    }

    return await $this->selection($values, $keys);
  }
}
