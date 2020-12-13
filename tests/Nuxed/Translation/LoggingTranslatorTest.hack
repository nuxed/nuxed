namespace Nuxed\Test\Translation;

use namespace HH\Lib\{C, Str};
use namespace Facebook\HackTest;
use namespace Nuxed\Contract\Log;
use namespace Nuxed\Translation;
use namespace Nuxed\Translation\Exception;

use function Facebook\FBExpect\expect;

class LoggingTranslatorTest extends HackTest\HackTest {
  public async function testTransWithNoTranslationIsLogged(): Awaitable<void> {
    $logger = new TestingLogger();
    $translator = new Translation\Translator('en');
    $loggableTranslator = new Translation\LoggingTranslator(
      $translator,
      $logger,
    );

    expect(await $loggableTranslator->trans('bar'))->toBeSame('bar');
    expect(C\count($logger->logs))->toBeSame(1);
    expect($logger->logs[0]['level'])->toBeSame(Log\LogLevel::Warning);
    expect($logger->logs[0]['message'])->toBeSame('Translation not found.');
    expect($logger->logs[0]['context'])->toBeSame(
      dict[
        'id' => 'bar',
        'domain' => 'messages',
        'locale' => 'en',
      ],
    );
  }

  public async function testTransFallbackIsLogged(): Awaitable<void> {
    $logger = new TestingLogger();
    $translator = new Translation\Translator('fr');
    $translator->setFallbackLocales(vec['en']);
    $translator->addLoader('tree', new Translation\Loader\TreeLoader());
    $translator->addResource('tree', dict['hello' => 'Hello {name}!'], 'en');
    $loggableTranslator = new Translation\LoggingTranslator(
      $translator,
      $logger,
    );

    expect(await $loggableTranslator->trans('hello', dict['name' => 'Saif']))
      ->toBeSame('Hello Saif!');
    expect(C\count($logger->logs))->toBeSame(1);
    expect($logger->logs[0]['level'])->toBeSame(Log\LogLevel::Debug);
    expect($logger->logs[0]['message'])->toBeSame(
      'Translation use fallback catalogue.',
    );
    expect($logger->logs[0]['context'])->toBeSame(
      dict[
        'id' => 'hello',
        'domain' => 'messages',
        'locale' => 'fr',
      ],
    );
  }
}

class TestingLogger extends Log\NullLogger {
  public vec<shape(
    'level' => Log\LogLevel,
    'message' => string,
    'context' => KeyedContainer<string, mixed>,
  )> $logs = vec[];

  /**
   * Logs with an arbitrary level.
   */
  <<__Override>>
  public async function log(
    Log\LogLevel $level,
    string $message,
    KeyedContainer<string, mixed> $context = dict[],
  ): Awaitable<void> {
    $this->logs[] = shape(
      'level' => $level,
      'message' => $message,
      'context' => $context,
    );
  }
}
