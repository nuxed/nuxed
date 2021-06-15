namespace Nuxed\Http\Routing;

use namespace Nuxed\Http\Message;
use namespace Nuxed\Http\Handler;

interface IRouter extends Matcher\IMatcher, IRouteCollector {
}
