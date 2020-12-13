namespace Nuxed\Console\Formatter;

final class NullFormatter
  extends AbstractFormatter
  implements IWrappableFormatter {

  /**
   * {@inheritdoc}
   */
  <<__Override>>
  public function format(string $message, int $_width = 0): string {
    return $message;
  }
}
