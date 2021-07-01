/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Test\Console\Input;

use namespace HH\Lib\{IO, Str};
use namespace Facebook\HackTest;
use namespace Nuxed\Console;
use namespace Nuxed\Console\Input;
use function Facebook\FBExpect\expect;

class InputTest extends HackTest\HackTest {
  public function testActiveCommand(): void {
    $input = $this->getInput('foo bar');
    expect($input->getActiveCommand())->toBeSame('foo');

    $input = $this->getInput('foo:bar');
    expect($input->getActiveCommand())->toBeSame('foo:bar');

    $input = $this->getInput('');
    expect($input->getActiveCommand())->toBeNull();

    $input = $this->getInput('--foo');
    expect($input->getActiveCommand())->toBeNull();
  }

  public function testArgument(): void {
    $arguments = vec[
      new Input\Definition\Argument(
        'username',
        'The unique username of the user to delete',
        Input\Definition\Mode::REQUIRED,
      ),
    ];
    $input = $this->getInput('user:delete azjezz', $arguments);
    $input->parse();
    $input->validate();

    expect($input->getActiveCommand())->toBeSame('user:delete');

    $argument = $input->getArgument('username');
    expect($argument->exists())->toBeTrue();
    expect($argument->getValue())->toBeSame('azjezz');
  }

  public function testMissingRequiredArgument(): void {
    $arguments = vec[
      new Input\Definition\Argument(
        'username',
        'The unique username of the user to delete',
        Input\Definition\Mode::REQUIRED,
      ),
    ];

    $input = $this->getInput('user:delete', $arguments);
    $input->parse();

    expect($input->getActiveCommand())->toBeSame('user:delete');

    expect(() ==> $input->validate())
      ->toThrow(
        Console\Exception\MissingValueException::class,
        'No value present for required argument `username`.',
      );
  }

  public function testMissingOptionalArgument(): void {
    $arguments = vec[
      new Input\Definition\Argument(
        'remote',
        'Remote host to push changes to, defaults to `origin`',
        Input\Definition\Mode::OPTIONAL,
      ),
    ];

    $input = $this->getInput('push', $arguments);
    $input->parse();
    $input->validate();

    expect($input->getActiveCommand())->toBeSame('push');

    $argument = $input->getArgument('remote');
    expect($argument->exists())->toBeFalse();
    expect($argument->getValue())->toBeNull();
    expect($argument->getValue('origin'))->toBeSame('origin');
  }

  public function testOption(): void {
    $options = vec[
      new Input\Definition\Option(
        'config',
        'The configuration file to use',
        Input\Definition\Mode::OPTIONAL,
      ),
    ];
    $input = $this->getInput('lint --config=.hhast-lint.json', vec[], $options);
    $input->parse();
    $input->validate();

    expect($input->getActiveCommand())->toBeSame('lint');

    $option = $input->getOption('config');
    expect($option->exists())->toBeTrue();
    expect($option->getValue())->toBeSame('.hhast-lint.json');

    // `=` is not required.

    $input = $this->getInput('lint --config .hhast-lint.json', vec[], $options);
    $input->parse();
    $input->validate();

    expect($input->getActiveCommand())->toBeSame('lint');

    $option = $input->getOption('config');
    expect($option->exists())->toBeTrue();
    expect($option->getValue())->toBeSame('.hhast-lint.json');
  }

  public function testShortOption(): void {
    $options = vec[
      new Input\Definition\Option(
        'config',
        'The configuration file to use',
        Input\Definition\Mode::OPTIONAL,
      ),
    ];

    $input = $this->getInput('lint -c .hhast-lint.json', vec[], $options);
    $input->parse();
    $input->validate();

    expect($input->getActiveCommand())->toBeSame('lint');

    $option = $input->getOption('config');
    expect($option->exists())->toBeTrue();
    expect($option->getValue())->toBeSame('.hhast-lint.json');
  }

  public function testMissingRequiredOption(): void {
    $options = vec[
      new Input\Definition\Option(
        'file',
        'The json file to validate',
        Input\Definition\Mode::REQUIRED,
      ),
    ];
    $input = $this->getInput('validate:json', vec[], $options);
    $input->parse();

    expect(() ==> $input->validate())
      ->toThrow(
        Console\Exception\MissingValueException::class,
        'No value present for required option `file`.',
      );
  }

  public function testMissingOptionalOption(): void {
    $options = vec[
      new Input\Definition\Option(
        'port',
        'The port number to use',
        Input\Definition\Mode::OPTIONAL,
      ),
    ];
    $input = $this->getInput('server:start', vec[], $options);
    $input->parse();
    $input->validate();

    expect($input->getActiveCommand())->toBeSame('server:start');

    $option = $input->getOption('port');
    expect($option->exists())->toBeFalse();
    expect($option->getValue())->toBeNull();
    expect($option->getValue('8080'))->toBeSame('8080');
  }

  public function testFlag(): void {
    $flags = vec[
      new Input\Definition\Flag(
        'dry-run',
        'Perform a dry run',
        Input\Definition\Mode::OPTIONAL,
      ),
    ];
    $input = $this->getInput('database:create --dry-run', vec[], vec[], $flags);

    $input->parse();
    $input->validate();

    expect($input->getActiveCommand())->toBeSame('database:create');

    $flag = $input->getFlag('dry-run');
    expect($flag->exists())->toBeTrue();
    expect($flag->getValue())->toBeSame(1);

    $input = $this->getInput(
      'database:create --no-dry-run',
      vec[],
      vec[],
      $flags,
    );

    $input->parse();
    $input->validate();

    expect($input->getActiveCommand())->toBeSame('database:create');

    $flag = $input->getFlag('dry-run');
    expect($flag->exists())->toBeTrue();
    expect($flag->getValue())->toBeSame(0);
  }

  public function testFlagWithAlias(): void {
    $flags = vec[
      new Input\Definition\Flag(
        'dry-run',
        'Perform a dry run',
        Input\Definition\Mode::OPTIONAL,
      )
        |> $$->setAlias('d'),
    ];
    $input = $this->getInput('database:create -d', vec[], vec[], $flags);

    $input->parse();
    $input->validate();

    expect($input->getActiveCommand())->toBeSame('database:create');

    $flag = $input->getFlag('dry-run');
    expect($flag->exists())->toBeTrue();
    expect($flag->getValue())->toBeSame(1);
  }

  public function testMissingRequiredFlag(): void {
    $flags = vec[
      new Input\Definition\Flag(
        'backup',
        'Whether or not the a backup should be create.',
        Input\Definition\Mode::REQUIRED,
      ),
    ];
    $input = $this->getInput('database:schema:update', vec[], vec[], $flags);

    $input->parse();

    expect($input->getActiveCommand())->toBeSame('database:schema:update');

    expect(() ==> $input->validate())
      ->toThrow(
        Console\Exception\MissingValueException::class,
        'Required flag `backup` is not present.',
      );
  }

  public function testMissingOptionalFlag(): void {
    $flags = vec[
      new Input\Definition\Flag(
        'complete',
        'If defined, all assets of the database which are not relevant to the current metadata will be dropped.',
        Input\Definition\Mode::OPTIONAL,
      ),
    ];
    $input = $this->getInput('database:schema:update', vec[], vec[], $flags);

    $input->parse();
    $input->validate();

    expect($input->getActiveCommand())->toBeSame('database:schema:update');

    $flag = $input->getFlag('complete');
    expect($flag->exists())->toBeFalse();
    expect($flag->getValue())->toBeNull();
  }

  public function testSetAndGetArguments(): void {
    $input = $this->getInput('foo:bar:baz');
    $arguments = new Input\Bag\ArgumentBag();
    $foo = new Input\Definition\Argument('foo');
    $arguments->set('foo', $foo);
    $bar = new Input\Definition\Argument('bar');
    $arguments->set('bar', $bar);
    $baz = new Input\Definition\Argument('baz');
    $arguments->set('baz', $baz);

    $input->setArguments($arguments);
    expect($input->getArguments())->toBeSame($arguments);
    expect($input->getArgument('foo'))->toBeSame($foo);
    expect($input->getArgument('bar'))->toBeSame($bar);
    expect($input->getArgument('baz'))->toBeSame($baz);
  }

  public function testSetAndGetOptions(): void {
    $input = $this->getInput('foo:bar:baz');
    $options = new Input\Bag\OptionBag();
    $foo = new Input\Definition\Option('foo');
    $options->set('foo', $foo);
    $bar = new Input\Definition\Option('bar');
    $options->set('bar', $bar);
    $baz = new Input\Definition\Option('baz');
    $options->set('baz', $baz);

    $input->setOptions($options);
    expect($input->getOptions())->toBeSame($options);
    expect($input->getOption('foo'))->toBeSame($foo);
    expect($input->getOption('bar'))->toBeSame($bar);
    expect($input->getOption('baz'))->toBeSame($baz);
  }

  public function testSetAndGetFlags(): void {
    $input = $this->getInput('foo:bar:baz');
    $flags = new Input\Bag\FlagBag();
    $foo = new Input\Definition\Flag('foo');
    $flags->set('foo', $foo);
    $bar = new Input\Definition\Flag('bar');
    $flags->set('bar', $bar);
    $baz = new Input\Definition\Flag('baz');
    $flags->set('baz', $baz);

    $input->setFlags($flags);
    expect($input->getFlags())->toBeSame($flags);
    expect($input->getFlag('foo'))->toBeSame($foo);
    expect($input->getFlag('bar'))->toBeSame($bar);
    expect($input->getFlag('baz'))->toBeSame($baz);
  }

  private function getInput(
    string $command,
    Container<Input\Definition\Argument> $arguments = vec[],
    Container<Input\Definition\Option> $options = vec[],
    Container<Input\Definition\Flag> $flags = vec[],
  ): Input\Input {
    $input = new Input\Input(Str\split($command, ' '), IO\request_input());
    foreach ($arguments as $argument) {
      $input->addArgument($argument);
    }

    foreach ($options as $option) {
      $input->addOption($option);
    }

    foreach ($flags as $flag) {
      $input->addFlag($flag);
    }

    return $input;
  }
}
