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

final class MethodNotAllowedException extends ServerException {
  public function __construct(protected keyset<Message\HttpMethod> $allowed) {

    parent::__construct(Message\StatusCode::METHOD_NOT_ALLOWED, dict[
      'Allow' => vec($allowed),
    ]);
  }

  public function getAllowedMethods()[]: keyset<Message\HttpMethod> {
    return $this->allowed;
  }
}
