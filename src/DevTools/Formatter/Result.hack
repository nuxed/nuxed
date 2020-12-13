namespace Nuxed\DevTools\Formatter;

enum Status: int {
  INVALID = 0;
  FORMATTED = 1;
  NO_CHANGES = 2;
}

final class Result {
  public function __construct(
    private string $content,
    private Status $status,
  ) {}

  public function isInvalid(): bool {
    return $this->status === Status::INVALID;
  }

  public function isChanged(): bool {
    return $this->status === Status::FORMATTED;
  }

  public function getContent(): string {
    return $this->content;
  }
}
