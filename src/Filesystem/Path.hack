namespace Nuxed\Filesystem;

use namespace HH\Lib\{C, Str, Vec};

/**
 * Provides convenience functions for inflecting notation paths and file system paths.
 */
final class Path {
  /**
   * Directory separator.
   */
  const string SEPARATOR = \DIRECTORY_SEPARATOR;

  /**
   * Include path separator.
   */
  const string DELIMITER = \PATH_SEPARATOR;

  public function __construct(private string $path) {
  }

  public static function create(string $path): Path {
    $path = static::standard($path, false);
    return new self($path);
  }

  public function toString(): string {
    if ($this->isAbsolute() && !$this->isSymlink() && $this->exists()) {
      return static::normalize($this->path) as string;
    }

    return $this->path;
  }

  /**
   * Return the extension from a file path.
   */
  public function extension(): ?string {
    $extension = \pathinfo($this->path, \PATHINFO_EXTENSION);
    return $extension === '' ? null : $extension;
  }

  /**
   * Verify a path is absolute by checking the first path part.
   */
  public function isAbsolute(): bool {
    return Str\starts_with($this->path, static::SEPARATOR);
  }

  /**
   * Verify a path is relative.
   */
  public function isRelative(): bool {
    return !$this->isAbsolute();
  }

  /**
   * Join all path parts and return a normalized path.
   *
   * @param bool $above - Go above the root path if .. is used
   */
  public static function join(
    Container<string> $paths,
    bool $above = true,
  ): Path {
    $clean = vec[];
    $parts = vec[];
    $up = 0;

    // First pass expands sub-paths
    foreach ($paths as $path) {
      $path = Str\trim(static::standard($path), '/');

      if (Str\contains($path, '/')) {
        $clean = Vec\concat($clean, Str\split($path, '/'));
      } else {
        $clean[] = $path;
      }
    }

    // Second pass flattens dot paths
    $clean = Vec\reverse($clean);
    foreach ($clean as $path) {
      if ($path === '.' || $path === '') {
        continue;
      } else if ($path === '..') {
        $up++;
      } else if ($up > 0) {
        $up--;
      } else {
        $parts[] = $path;
      }
    }

    // Append double dots above root
    if ($above) {
      while ($up) {
        $parts[] = '..';
        $up--;
      }
    }

    $parts = Vec\reverse($parts);

    return self::create(Str\join($parts, '/'));
  }

  /**
   * Normalize a string by resolving "." and "..". When multiple slashes are found, they're replaced by a single one;
   * when the path contains a trailing slash, it is preserved. On Windows backslashes are used.
   *
   * if the path couldn't be normalized, null will be returned.
   */
  public static function normalize(string $path): ?string {
    $normalized = \realpath($path);
    if ($normalized is string) {
      return $normalized;
    }

    return null;
  }

  /**
   * Converts OS directory separators to the standard forward slash.
   */
  public static function standard(
    string $path,
    bool $endSlash = false,
  ): string {
    return Str\replace($path, '\\', '/')
      |> ($endSlash && !Str\ends_with($$, '/')) ? $$.'/' : $$;
  }

  /**
   * Determine the relative path between this and another absolute path.
   */
  public function relativeTo(Path $to): Path {
    if ($this->isRelative() || $to->isRelative()) {
      throw new Exception\InvalidPathException(
        'Cannot determine relative path without two absolute paths.',
      );
    }

    $from = Str\split(static::standard($this->toString(), true), '/');
    $to = Str\split(static::standard($to->toString(), true), '/');
    $relative = $to;

    foreach ($from as $depth => $dir) {
      // Find first non-matching dir and ignore it
      if ($dir === $to[$depth]) {
        $relative = Vec\slice($relative, 1);

        // Get count of remaining dirs to $from
      } else {
        $remaining = C\count($from) - $depth;

        // Add traversals up to first matching dir
        if ($remaining > 1) {
          $relative = Vec\concat(Vec\fill($remaining - 1, '..'), $relative);
          break;
        } else {
          $relative[0] = './'.$relative[0];
        }
      }
    }

    $relative = Vec\filter($relative);
    if (0 === C\count($relative)) {
      return self::create('./');
    }

    return self::create(Str\join($relative, '/'));
  }

  /**
   * Check if the path is a directory.
   */
  public function isFolder(): bool {
    return \is_dir($this->path);
  }

  /**
   * Check if the path is a file.
   */
  public function isFile(): bool {
    return \is_file($this->path);
  }

  /**
   * Check if the path is a symbolic link.
   */
  public function isSymlink(): bool {
    return \is_link($this->path);
  }

  /**
   * Check if the file exists.
   */
  public function exists(): bool {
    return \file_exists($this->path);
  }

  /**
   * Return the parent directory.
   * Will always end in a trailing slash.
   */
  public function parent(): Path {
    return new self(\dirname($this->path));
  }

  /**
   * Return the file name with extension.
   */
  public function basename(): string {
    return \basename($this->path);
  }

  /**
   * Return the file name without extension.
   */
  public function name(): string {
    return \pathinfo($this->toString(), \PATHINFO_FILENAME);
  }

  public function parts(): Container<string> {
    return Str\split($this->path, static::SEPARATOR)
      |> Vec\filter($$, $part ==> !Str\is_empty($part));
  }

  public function compare(string $other): int {
    $other = static::standard($other, false);
    $other = static::normalize($other) ?? $other;
    if (Str\ends_with($other, '/')) {
      $other = Str\slice($other, 0, Str\length($other) - 1);
    }

    $self = static::standard($this->toString(), false);
    $self = static::normalize($self) ?? $self;
    if (Str\ends_with($self, '/')) {
      $self = Str\slice($self, 0, Str\length($self) - 1);
    }

    return Str\compare($self, $other);
  }
}
