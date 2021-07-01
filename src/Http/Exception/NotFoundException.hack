/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Http\Exception;

use namespace Nuxed\Http\Message;

final class NotFoundException extends ServerException {
  public function __construct() {
    parent::__construct(Message\StatusCode::NOT_FOUND);
  }
}
