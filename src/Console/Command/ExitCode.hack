namespace Nuxed\Console\Command;

enum ExitCode: int as int {
  /**
   * No error. The command executed successfully.
   */
  SUCCESS = 0;

  /**
   * Catchall for general errors.
   */
  FAILUER = 1;

  /**
   * Command has been skipped.
   */
  SKIPPED_COMMAND = 113;

  /**
   * Command not found.
   */
  COMMAND_NOT_FOUND = 127;

  /**
   * The returned exit code is out of range.
   *
   * An exit value greater than 255 returns an exit code modulo 256.
   * For example, exit 3809 gives an exit code of 225 (3809 % 256 = 225).
   */
  EXIT_STATUS_OUT_OF_RANGE = 255;
}
