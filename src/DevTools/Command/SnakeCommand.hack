namespace Nuxed\DevTools\Command;

use namespace HH\Asio;
use namespace HH\Lib\Str;
use namespace Nuxed\Console;
use namespace Nuxed\Process;
use namespace Nuxed\Console\{Command, Output, Formatter\Style};
use namespace Nuxed\DevTools\Games\Snake;

final class SnakeCommand extends Command\Command {
  <<__Override>>
  public function configure(): void {
    $this->setName('snake')
      ->setDescription('Play snake game.');
  }

  <<__Override>>
  public async function run(): Awaitable<int> {
    $this->output->getFormatter()->addStyle('snake', new Style\Style(
      Style\BackgroundColor::BLACK,
      Style\ForegroundColor::GREEN,
      vec[Style\Effect::BOLD],
    ));
    $this->output->getFormatter()->addStyle('goal', new Style\Style(
      Style\BackgroundColor::BLACK,
      Style\ForegroundColor::MAGENTA,
      vec[Style\Effect::BOLD],
    ));
    $this->output->getFormatter()->addStyle('background', new Style\Style(
      Style\BackgroundColor::BLACK,
      Style\ForegroundColor::CYAN,
    ));
    $this->output->getFormatter()->addStyle('crash', new Style\Style(
      Style\BackgroundColor::BLACK,
      Style\ForegroundColor::RED,
      vec[Style\Effect::BOLD, Style\Effect::BLINK],
    ));

    $sttyMode = \shell_exec('stty -g');
    \shell_exec('stty -icanon -echo');

    await $this->output->getCursor()->hide();

    $game = new Snake\Game(
      await Console\Terminal::getWidth(),
      await Console\Terminal::getHeight(),
    );

    await $game->run($this->input, $this->output);

    await $this->output->getCursor()->show();
    \shell_exec('stty '.$sttyMode);

    return Command\ExitCode::SUCCESS;
  }
}
