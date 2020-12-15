namespace Nuxed\Kernel\DependencyInjection\Factory\Serializer;

use namespace Nuxed\DependencyInjection\Factory;
use namespace Nuxed\{DependencyInjection, Serializer};

final class NativeSerializerFactory
  implements Factory\IFactory<Serializer\NativeSerializer> {
  public function create(
    DependencyInjection\IServiceContainer $_container,
  ): Serializer\NativeSerializer {
    return new Serializer\NativeSerializer();
  }
}
