/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Console\Output;

final class BufferedOutput extends AbstractOutput {
  private string $stdout = '';

  /**
   * {@inheritdoc}
   */
  <<__Override>>
  public async function write(
    string $message,
    Verbosity $verbosity = Verbosity::NORMAL,
    Type $type = Type::NORMAL,
  ): Awaitable<void> {
    if (!$this->shouldOutput($verbosity)) {
      return;
    }

    $this->stdout .= $this->format($message, $type);
  }

  public function fetch(): string {
    $content = $this->stdout;
    $this->stdout = '';

    return $content;
  }
}
