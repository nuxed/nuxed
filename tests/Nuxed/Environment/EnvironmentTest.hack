namespace Nuxed\Test\Environment;

use namespace Nuxed\Environment;
use namespace Facebook\HackTest;
use function Facebook\FBExpect\expect;

class EnvironmentTest extends HackTest\HackTest {
  public function testAdd(): void {
    Environment\add('FOO', 'BAR');
    expect(Environment\get('FOO'))->toBeSame('BAR');

    Environment\add('FOO', 'BAZ');
    expect(Environment\get('FOO'))->toBeSame('BAR');
  }

  public function testPut(): void {
    Environment\put('FOO', 'BAR');
    expect(Environment\get('FOO'))->toBeSame('BAR');

    Environment\put('FOO', 'BAZ');
    expect(Environment\get('FOO'))->toBeSame('BAZ');
  }

  public function testContains(): void {
    Environment\put('X_FOO', 'BAR');
    expect(Environment\contains('X_FOO'))->toBeTrue();
    expect(Environment\contains('X_BAR_QUX'))->toBeFalse();
  }

  public function testForget(): void {
    Environment\put('FOO', 'BAR');
    expect(Environment\get('FOO'))->toBeSame('BAR');
    expect(Environment\contains('FOO'))->toBeTrue();

    Environment\forget('FOO');
    expect(Environment\get('FOO'))->toBeNull();
    expect(Environment\contains('FOO'))->toBeFalse();
  }

  public function testGet(): void {
    Environment\put('FOO', 'BAR');
    expect(Environment\get('FOO'))->toBeSame('BAR');

    Environment\forget('FOO');
    expect(Environment\get('FOO'))->toBeNull();

    Environment\put('FOO', '"BAR"');
    expect(Environment\get('FOO'))->toBeSame('BAR');

    Environment\forget('FOO');
    expect(Environment\get('FOO', 'BAZ'))->toBeSame('BAZ');
  }

  public async function testLoad(): Awaitable<void> {
    await Environment\load(__DIR__.'/.env.test');
    expect(Environment\get('LFOO'))->toBeSame('BAR');
    expect(Environment\get('LBAR'))->toBeSame('QUX');
    expect(Environment\get('LBAZ'))->toBeSame('BAZ');

    Environment\forget('LFOO');
    Environment\forget('LBAR');
    Environment\forget('LBAZ');

    Environment\put('LFOO', 'QUX');

    await Environment\load(__DIR__.'/.env.test');
    expect(Environment\get('LFOO'))->toBeSame('QUX');
    expect(Environment\get('LBAR'))->toBeSame('QUX');
    expect(Environment\get('LBAZ'))->toBeSame('BAZ');
  }

  public async function testOverload(): Awaitable<void> {
    await Environment\overload(__DIR__.'/.env.test');
    expect(Environment\get('LFOO'))->toBeSame('BAR');
    expect(Environment\get('LBAR'))->toBeSame('QUX');
    expect(Environment\get('LBAZ'))->toBeSame('BAZ');

    Environment\forget('LFOO');
    Environment\forget('LBAR');
    Environment\forget('LBAZ');

    Environment\put('LFOO', 'QUX');

    await Environment\overload(__DIR__.'/.env.test');
    expect(Environment\get('LFOO'))->toBeSame('BAR');
    expect(Environment\get('LBAR'))->toBeSame('QUX');
    expect(Environment\get('LBAZ'))->toBeSame('BAZ');
  }

  <<HackTest\DataProvider('provideParseData')>>
  public function testParse(string $value, (string, ?string) $expected): void {
    expect(Environment\parse($value))->toBeSame($expected);
  }

  public function provideParseData(): Container<(string, (string, ?string))> {
    return vec[
      tuple('FOO', tuple('FOO', null)),
      tuple('FOO=', tuple('FOO', null)),
      tuple('FOO=BAR', tuple('FOO', 'BAR')),
      tuple('FOO="BAR"', tuple('FOO', 'BAR')),
      tuple('export FOO=BAR', tuple('FOO', 'BAR')),
      tuple('export FOO=BAR#comment', tuple('FOO', 'BAR')),
      tuple('export FOO              =         "BAR"', tuple('FOO', 'BAR')),
    ];
  }

  public function testParseInvalidSquence(): void {
    expect(() ==> {
      Environment\parse('export FOO="BAR\\#X');
    })->toThrow(
      Environment\Exception\InvalidArgumentException::class,
      'an unexpected escape sequence',
    );
  }

  public function testParseUnexceptedWhiteSpace(): void {
    expect(() ==> {
      Environment\parse('export FOO=BAR "FOO"');
    })->toThrow(
      Environment\Exception\InvalidArgumentException::class,
      'unexpected whitespace',
    );
  }

  public function testMode(): void {
    Environment\put('APP_MODE', 'test');
    expect(Environment\mode())
      ->toBeSame(Environment\Mode::Test);

    Environment\put('APP_MODE', 'prod');
    expect(Environment\mode())
      ->toBeSame(Environment\Mode::Production);

    Environment\put('APP_MODE', 'dev');
    expect(Environment\mode())
      ->toBeSame(Environment\Mode::Development);

    Environment\put('APP_MODE', 'deV');
    expect(Environment\mode())
      ->toBeSame(Environment\Mode::Development);

    Environment\put('APP_MODE', 'local');
    expect(Environment\mode())
      ->toBeSame(Environment\Mode::Local);

    Environment\put('APP_MODE', 'develop');
    expect(Environment\mode())
      ->toBeSame(Environment\Mode::Development);

    Environment\put('APP_MODE', 'Development');
    expect(Environment\mode())
      ->toBeSame(Environment\Mode::Development);

    Environment\put('APP_MODE', 'production');
    expect(Environment\mode())
      ->toBeSame(Environment\Mode::Production);

    Environment\put('APP_MODE', 'testing');
    expect(Environment\mode())
      ->toBeSame(Environment\Mode::Test);


    Environment\put('APP_MODE', 'unknown');
    expect(() ==> {
      Environment\mode();
    })->toThrow(
      Environment\Exception\RuntimeException::class,
      'Failed to determine application mode: invalid value for "APP_MODE" environment variable ( excepted "dev", "prod", "test", or "local", got "unknown")',
    );

    Environment\forget('APP_MODE');
    expect(() ==> {
      Environment\mode();
    })->toThrow(
      Environment\Exception\RuntimeException::class,
      'Failed to determine application mode: "APP_MODE" variable is missing.',
    );
  }

  public async function testBootstrap(): Awaitable<void> {
    await Environment\bootstrap(__DIR__.'/env/dist/.env');
    expect(Environment\contains('NE_DIST_LOADED'))
      ->toBeTrue();

    Environment\forget('APP_MODE');
    await Environment\bootstrap(__DIR__.'/env/dev/.env');
    expect(Environment\contains('NE_DEV_LOADED'))
      ->toBeTrue();
    expect(Environment\contains('NE_DEV_MODE_LOADED'))
      ->toBeTrue();
    expect(Environment\mode())
      ->toBeSame(Environment\Mode::Development);

    Environment\forget('APP_MODE');
    await Environment\bootstrap(__DIR__.'/env/prod/.env');
    expect(Environment\contains('NE_PROD_LOADED'))
      ->toBeTrue();
    expect(Environment\contains('NE_PROD_MODE_LOADED'))
      ->toBeTrue();
    expect(Environment\contains('NE_PROD_MODE_LOCAL_LOADED'))
      ->toBeTrue();
    expect(Environment\mode())
      ->toBeSame(Environment\Mode::Production);

    Environment\forget('APP_MODE');
    await Environment\bootstrap(__DIR__.'/env/test/.env');
    expect(Environment\contains('NE_TEST_LOADED'))
      ->toBeTrue();
    expect(Environment\contains('NE_TEST_MODE_LOADED'))
      ->toBeTrue();
    expect(Environment\contains('NE_TEST_MODE_LOCAL_LOADED'))
      ->toBeFalse();
    expect(Environment\mode())
      ->toBeSame(Environment\Mode::Test);
  }
}
