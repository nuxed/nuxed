namespace Nuxed\Console\UserInput;

use namespace HH\Lib\{C, Str};
use namespace Nuxed\Console;

final class Confirm extends AbstractUserInput<bool> {
  /**
   * The message to be appended to the prompt message containing the accepted
   * values.
   */
  protected string $message = '';

  public function __construct(
    Console\Input\IInput $input,
    Console\Output\IOutput $output,
  ) {
    parent::__construct($input, $output);

    $this->acceptedValues = dict[
      'y' => true,
      'yes' => true,
      'oui' => true,
      'n' => false,
      'no' => false,
      'non' => false,
    ];
  }

  /**
   * {@inheritdoc}
   */
  <<__Override>>
  public async function prompt(string $message): Awaitable<bool> {
    $output = $message.' '.$this->message.' ';

    $cursor = null;
    if ($this->position is nonnull) {
      list($column, $row) = $this->position;
      $cursor = $this->output->getCursor();
      await $cursor->save();
      await $cursor->move($column, $row);
    }

    await $this->output->write($output);
    $input = await $this->input->getUserInput();
    if ('' === $input && '' !== $this->default) {
      $input = $this->default;
    }

    if (
      !C\contains_key<string, string, bool>(
        $this->acceptedValues,
        Str\lowercase($input),
      )
    ) {
      return await $this->prompt($message);
    }

    if ($cursor is nonnull) {
      await $cursor->restore();
    }

    return $this->acceptedValues[Str\lowercase($input)];
  }

  /**
   * {@inheritdoc}
   */
  <<__Override>>
  public function setDefault(string $default = ''): this {
    switch (Str\lowercase($default)) {
      case 'y':
      case 'yes':
        $this->default = $default;
        $message = ' [Y/n]';
        break;
      case 'n':
      case 'no':
        $this->default = $default;
        $message = ' [y/N]';
        break;
      default:
        $message = ' [y/n]';
        break;
    }

    $this->message = $message;

    return $this;
  }
}
