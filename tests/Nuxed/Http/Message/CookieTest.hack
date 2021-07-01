/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Test\Http\Message;

use namespace Nuxed\Http\Message;
use namespace Facebook\HackTest;

use function Facebook\FBExpect\expect;

class CookieTest extends HackTest\HackTest {
  public function testGetters(): void {
    $cookie = new Message\Cookie(
      'hello',
      123,
      456,
      '/',
      'www.facebook.com',
      true,
      true,
      Message\CookieSameSite::STRICT,
    );
    expect($cookie->getValue())->toBeSame('hello');
    expect($cookie->getExpires())->toBeSame(123);
    expect($cookie->getMaxAge())->toBeSame(456);
    expect($cookie->getPath())->toBeSame('/');
    expect($cookie->getDomain())->toBeSame('www.facebook.com');
    expect($cookie->getSecure())->toBeTrue();
    expect($cookie->getHttpOnly())->toBeTrue();
    expect($cookie->getSameSite())->toBeSame(Message\CookieSameSite::STRICT);
  }

  public function testWithValue(): void {
    $cookie = new Message\Cookie('hhvm');
    $cookie2 = $cookie->withValue('hack');
    expect($cookie->getValue())->toBeSame('hhvm');
    expect($cookie2->getValue())->toBeSame('hack');
    expect($cookie2)->toNotBeSame($cookie);
  }

  public function testWithExpires(): void {
    $cookie = new Message\Cookie('hhvm', 123);
    $cookie2 = $cookie->withExpires(null);
    $cookie3 = $cookie2->withExpires(456);
    expect($cookie2)->toNotBeSame($cookie);
    expect($cookie3)->toNotBeSame($cookie2);
    expect($cookie2->getExpires())->toBeNull();
    expect($cookie3->getExpires())->toBeSame(456);
  }

  public function testWithPath(): void {
    $cookie = new Message\Cookie('waffle', 123, 456, '/auth');
    $cookie2 = $cookie->withPath('/');
    expect($cookie2)->toNotBeSame($cookie);
    expect($cookie2->getPath())->toBeSame('/');
  }

  public function testWithDomain(): void {
    $cookie = new Message\Cookie('waffle', 123, 456, '/', 'thefacebook.com');
    $cookie2 = $cookie->withDomain('facebook.com');
    expect($cookie2)->toNotBeSame($cookie);
    expect($cookie2->getDomain())->toBeSame('facebook.com');
  }

  public function testWithAndWithoutSecure(): void {
    $cookie = new Message\Cookie('waffle', null, null, null, null, false);
    expect($cookie->getSecure())->toBeFalse();
    $cookie2 = $cookie->withSecure(true);
    expect($cookie2)->toNotBeSame($cookie);
    expect($cookie2->getSecure())->toBeTrue();
    $cookie3 = $cookie2->withoutSecure();
    expect($cookie3->getSecure())->toBeNull();
  }

  public function testWithAndWithoutHttpOnly(): void {
    $cookie = new Message\Cookie(
      'waffle',
      null,
      null,
      null,
      null,
      false,
      false,
    );
    expect($cookie->getHttpOnly())->toBeFalse();
    $cookie2 = $cookie->withHttpOnly(true);
    expect($cookie2)->toNotBeSame($cookie);
    expect($cookie2->getHttpOnly())->toBeTrue();
    $cookie3 = $cookie2->withoutHttpOnly();
    expect($cookie3->getHttpOnly())->toBeNull();
  }

  public function testWithSameSite(): void {
    $cookie = new Message\Cookie(
      'waffle',
      null,
      null,
      null,
      null,
      false,
      false,
      null,
    );
    $strict = Message\CookieSameSite::STRICT;
    $lax = Message\CookieSameSite::LAX;
    expect($cookie->getSameSite())->toBeNull();
    $cookie2 = $cookie->withSameSite($strict);
    expect($cookie2)->toNotBeSame($cookie);
    expect($cookie2->getSameSite())->toBeSame($strict);
    $cookie3 = $cookie2->withSameSite($lax);
    expect($cookie3)->toNotBeSame($cookie2);
    expect($cookie3->getSameSite())->toBeSame($lax);
  }
}
