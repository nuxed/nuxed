namespace Nuxed\Http\Session;

enum CacheLimiter: string as string {
  NO_CACHE = 'nocache';
  PUBLIC = 'public';
  PRIVATE = 'private';
  PRIVATE_NO_EXPIRE = 'private_no_expire';
}
