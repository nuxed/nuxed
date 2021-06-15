namespace Nuxed;

<<__EntryPoint>>
async function devtools(): Awaitable<void> {
    require_once __DIR__.'/../vendor/autoload.hack';

    \Facebook\AutoloadMap\initialize();

    $application = new Console\Application('Nuxed DevTools');
    $application->add(new DevTools\Command\SnakeCommand());

    await $application->run();
}
