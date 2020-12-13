namespace Nuxed\Configuration;

interface IConfiguration {
  /**
   * Fetches a value from the config.
   */
  public function get<reify T>(string $key): T;
}
