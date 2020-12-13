namespace Nuxed\Asset\Context;

interface IContextProvider {
  /**
   * Provide context.
   */
  public function getContext(): IContext;
}
