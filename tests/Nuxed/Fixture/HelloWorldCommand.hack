/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Test\Fixture;

use namespace Nuxed\Console\Command;

final class HelloWorldCommand extends Command\Command {
  /**
   * The configure method that sets up name, description, and necessary parameters
   * for the `Command` to run.
   */
  <<__Override>>
  public function configure(): void {
    $this->setName('hello:world');
  }

  /**
   * The method that stores the code to be executed when the `Command` is run.
   */
  <<__Override>>
  public async function run(): Awaitable<int> {
    await $this->output->writeLine('Hello, World!');

    return 0;
  }
}
