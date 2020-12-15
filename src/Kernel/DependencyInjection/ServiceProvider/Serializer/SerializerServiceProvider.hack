namespace Nuxed\Kernel\DependencyInjection\ServiceProvider\Serializer;

use namespace Nuxed\{Configuration, DependencyInjection, Serializer};
use namespace Nuxed\Kernel\DependencyInjection\Factory;

final class SerializerServiceProvider
  implements DependencyInjection\IServiceProvider {
  public function register(
    DependencyInjection\ContainerBuilder $builder,
    Configuration\IConfiguration $_configurations,
  ): void {
    $builder->add<Serializer\NativeSerializer>(
      Serializer\NativeSerializer::class,
      new Factory\Serializer\NativeSerializerFactory(),
    );

    $builder->add<Serializer\ISerializer>(
      Serializer\ISerializer::class,
      DependencyInjection\alias<
        Serializer\ISerializer,
        Serializer\NativeSerializer,
      >(Serializer\NativeSerializer::class),
    );
  }
}
