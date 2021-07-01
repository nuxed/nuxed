/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Console\Tree;

use namespace Nuxed\Console;
use namespace HH\Lib;
use namespace HH\Lib\{C, Str, Vec};

/**
 * Build a human readable ASCII tree given an infinitely nested data structure.
 */
final class AsciiTree<Tk as arraykey, Tv> extends AbstractTree<Tk, Tv> {
  /**
   * {@inheritdoc}
   */
  <<__Override>>
  protected async function build(
    KeyedContainer<Tk, Tv> $tree,
    string $prefix = '',
  ): Awaitable<string> {
    $output = new Lib\Ref<vec<Awaitable<string>>>(vec[]);
    $keys = Vec\keys<Tk, Tv>($this->data);
    $branch = vec<Tv>($this->data);

    for ($i = 0, $count = C\count($branch); $i < $count; ++$i) {
      $itemPrefix = $prefix;
      $next = $branch[$i];

      if ($i === $count - 1) {
        if ($next is Container<_>) {
          $itemPrefix .= $prefix === ''
            ? '<fg=green>──┬</> '
            : '<fg=green>└─┬</> ';
        } else {
          $itemPrefix .= $prefix === ''
            ? '<fg=green>───</> '
            : '<fg=green>└──</> ';
        }
      } else {
        if ($next is Container<_>) {
          $itemPrefix .= '<fg=green>├─┬</> ';
        } else {
          $itemPrefix .= (0 === $i && '' === $prefix)
            ? '<fg=green>┌──</> '
            : '<fg=green>├──</> ';
        }
      }

      if ($branch[$i] is Container<_>) {
        $output->value[] = async {
          return $itemPrefix.(string)$keys[$i];
        };
      } else {
        $output->value[] = async {
          return $itemPrefix.(string)$branch[$i];
        };
      }

      if ($next is Container<_>) {
        if (!$next is KeyedContainer<_, _>) {
          $next = vec($next);
        }

        $tree = new self<arraykey, mixed>($next);
        $output->value[] = $tree->build(
          $next,
          $prefix.($i === $count - 1 ? '  ' : '<fg=green>│</> '),
        );
      }
    }

    $result = await Vec\from_async<string>($output->value);
    return Str\join($result, Console\Output\IOutput::EndOfLine);
  }
}
