/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Console\Input\Bag;

use namespace Nuxed\Console\Input;
use namespace Nuxed\Console\Input\Definition;

/**
 * The `FlagBag` holds available `Flag` objects to reference.
 */
final class FlagBag extends Input\AbstractBag<Definition\Flag> {}
