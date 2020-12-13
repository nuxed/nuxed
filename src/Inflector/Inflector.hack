namespace Nuxed\Inflector;

use namespace HH\Lib\{C, Str};

final abstract class Inflector {
  private static string $vocals = 'aeiou';

  /**
   * Map English plural to singular suffixes.
   *
   * @see http://english-zone.com/spelling/plurals.html
   */
  private static vec<(string, int, bool, bool, vec<string>)> $pluralMap = vec[
    // First entry: plural suffix, reversed
    // Second entry: length of plural suffix
    // Third entry: Whether the suffix may succeed a vocal
    // Fourth entry: Whether the suffix may succeed a consonant
    // Fifth entry: singular suffix, normal

    // bacteria (bacterium), criteria (criterion), phenomena (phenomenon)
    tuple('a', 1, true, true, vec['on', 'um']),
    // nebulae (nebula)
    tuple('ea', 2, true, true, vec['a']),
    // services (service)
    tuple('secivres', 8, true, true, vec['service']),
    // mice (mouse), lice (louse)
    tuple('eci', 3, false, true, vec['ouse']),
    // geese (goose)
    tuple('esee', 4, false, true, vec['oose']),
    // fungi (fungus), alumni (alumnus), syllabi (syllabus), radii (radius)
    tuple('i', 1, true, true, vec['us']),
    // men (man), women (woman)
    tuple('nem', 3, true, true, vec['man']),
    // children (child)
    tuple('nerdlihc', 8, true, true, vec['child']),
    // oxen (ox)
    tuple('nexo', 4, false, false, vec['ox']),
    // indices (index), appendices (appendix), prices (price)
    tuple('seci', 4, false, true, vec['ex', 'ix', 'ice']),
    // selfies (selfie)
    tuple('seifles', 7, true, true, vec['selfie']),
    // movies (movie)
    tuple('seivom', 6, true, true, vec['movie']),
    // feet (foot)
    tuple('teef', 4, true, true, vec['foot']),
    // geese (goose)
    tuple('eseeg', 5, true, true, vec['goose']),
    // teeth (tooth)
    tuple('hteet', 5, true, true, vec['tooth']),
    // news (news)
    tuple('swen', 4, true, true, vec['news']),
    // series (series)
    tuple('seires', 6, true, true, vec['series']),
    // babies (baby)
    tuple('sei', 3, false, true, vec['y']),
    // accesses (access), addresses (address), kisses (kiss)
    tuple('sess', 4, true, false, vec['ss']),
    // analyses (analysis), ellipses (ellipsis), fungi (fungus),
    // neuroses (neurosis), theses (thesis), emphases (emphasis),
    // oases (oasis), crises (crisis), houses (house), bases (base),
    // atlases (atlas)
    tuple('ses', 3, true, true, vec['s', 'se', 'sis']),
    // objectives (objective), alternative (alternatives)
    tuple('sevit', 5, true, true, vec['tive']),
    // drives (drive)
    tuple('sevird', 6, false, true, vec['drive']),
    // lives (life), wives (wife)
    tuple('sevi', 4, false, true, vec['ife']),
    // moves (move)
    tuple('sevom', 5, true, true, vec['move']),
    // hooves (hoof), dwarves (dwarf), elves (elf), leaves (leaf), caves (cave), staves (staff)
    tuple('sev', 3, true, true, vec['f', 've', 'ff']),
    // axes (axis), axes (ax), axes (axe)
    tuple('sexa', 4, false, false, vec['ax', 'axe', 'axis']),
    // indexes (index), matrixes (matrix)
    tuple('sex', 3, true, false, vec['x']),
    // quizzes (quiz)
    tuple('sezz', 4, true, false, vec['z']),
    // bureaus (bureau)
    tuple('suae', 4, false, true, vec['eau']),
    // fees (fee), trees (tree), employees (employee)
    tuple('see', 3, true, true, vec['ee']),
    // roses (rose), garages (garage), cassettes (cassette),
    // waltzes (waltz), heroes (hero), bushes (bush), arches (arch),
    // shoes (shoe)
    tuple('se', 2, true, true, vec['', 'e']),
    // tags (tag)
    tuple('s', 1, true, true, vec['']),
    // chateaux (chateau)
    tuple('xuae', 4, false, true, vec['eau']),
    // people (person)
    tuple('elpoep', 6, true, true, vec['person']),
  ];

  /**
   * Map English singular to plural suffixes.
   *
   * @see http://english-zone.com/spelling/plurals.html
   */
  private static vec<(string, int, bool, bool, vec<string>)> $singularMap = vec[
    // First entry: singular suffix, reversed
    // Second entry: length of singular suffix
    // Third entry: Whether the suffix may succeed a vocal
    // Fourth entry: Whether the suffix may succeed a consonant
    // Fifth entry: plural suffix, normal
    // criterion (criteria)

    tuple('airetirc', 8, false, false, vec['criterion']),
    // nebulae (nebula)
    tuple('aluben', 6, false, false, vec['nebulae']),
    // children (child)
    tuple('dlihc', 5, true, true, vec['children']),
    // prices (price)
    tuple('eci', 3, false, true, vec['ices']),
    // services (service)
    tuple('ecivres', 7, true, true, vec['services']),
    // lives (life), wives (wife)
    tuple('efi', 3, false, true, vec['ives']),
    // selfies (selfie)
    tuple('eifles', 6, true, true, vec['selfies']),
    // movies (movie)
    tuple('eivom', 5, true, true, vec['movies']),
    // lice (louse)
    tuple('esuol', 5, false, true, vec['lice']),
    // mice (mouse)
    tuple('esuom', 5, false, true, vec['mice']),
    // geese (goose)
    tuple('esoo', 4, false, true, vec['eese']),
    // houses (house), bases (base)
    tuple('es', 2, true, true, vec['ses']),
    // geese (goose)
    tuple('esoog', 5, true, true, vec['geese']),
    // caves (cave)
    tuple('ev', 2, true, true, vec['ves']),
    // drives (drive)
    tuple('evird', 5, false, true, vec['drives']),
    // objectives (objective), alternative (alternatives)
    tuple('evit', 4, true, true, vec['tives']),
    // moves (move)
    tuple('evom', 4, true, true, vec['moves']),
    // staves (staff)
    tuple('ffats', 5, true, true, vec['staves']),
    // hooves (hoof), dwarves (dwarf), elves (elf), leaves (leaf)
    tuple('ff', 2, true, true, vec['ffs']),
    // hooves (hoof), dwarves (dwarf), elves (elf), leaves (leaf)
    tuple('f', 1, true, true, vec['fs', 'ves']),
    // arches (arch)
    tuple('hc', 2, true, true, vec['ches']),
    // bushes (bush)
    tuple('hs', 2, true, true, vec['shes']),
    // teeth (tooth)
    tuple('htoot', 5, true, true, vec['teeth']),
    // bacteria (bacterium), criteria (criterion), phenomena (phenomenon)
    tuple('mu', 2, true, true, vec['a']),
    // men (man), women (woman)
    tuple('nam', 3, true, true, vec['men']),
    // people (person)
    tuple('nosrep', 6, true, true, vec['persons', 'people']),
    // bacteria (bacterium), criteria (criterion), phenomena (phenomenon)
    tuple('noi', 3, true, true, vec['ions']),
    // seasons (season), treasons (treason), poisons (poison), lessons (lesson)
    tuple('nos', 3, true, true, vec['sons']),
    // bacteria (bacterium), criteria (criterion), phenomena (phenomenon)
    tuple('no', 2, true, true, vec['a']),
    // echoes (echo)
    tuple('ohce', 4, true, true, vec['echoes']),
    // heroes (hero)
    tuple('oreh', 4, true, true, vec['heroes']),
    // atlases (atlas)
    tuple('salta', 5, true, true, vec['atlases']),
    // irises (iris)
    tuple('siri', 4, true, true, vec['irises']),
    // analyses (analysis), ellipses (ellipsis), neuroses (neurosis)
    // theses (thesis), emphases (emphasis), oases (oasis),
    // crises (crisis)
    tuple('sis', 3, true, true, vec['ses']),
    // accesses (access), addresses (address), kisses (kiss)
    tuple('ss', 2, true, false, vec['sses']),
    // syllabi (syllabus)
    tuple('suballys', 8, true, true, vec['syllabi']),
    // buses (bus)
    tuple('sub', 3, true, true, vec['buses']),
    // circuses (circus)
    tuple('suc', 3, true, true, vec['cuses']),
    // fungi (fungus), alumni (alumnus), syllabi (syllabus), radii (radius)
    tuple('su', 2, true, true, vec['i']),
    // news (news)
    tuple('swen', 4, true, true, vec['news']),
    // feet (foot)
    tuple('toof', 4, true, true, vec['feet']),
    // chateaux (chateau), bureaus (bureau)
    tuple('uae', 3, false, true, vec['eaus', 'eaux']),
    // oxen (ox)
    tuple('xo', 2, false, false, vec['oxen']),
    // hoaxes (hoax)
    tuple('xaoh', 4, true, false, vec['hoaxes']),
    // indices (index)
    tuple('xedni', 5, false, true, vec['indicies', 'indexes']),
    // boxes (box)
    tuple('xo', 2, false, true, vec['oxes']),
    // indexes (index), matrixes (matrix)
    tuple('x', 1, true, false, vec['cies', 'xes']),
    // appendices (appendix)
    tuple('xi', 2, false, true, vec['ices']),
    // babies (baby)
    tuple('y', 1, false, true, vec['ies']),
    // quizzes (quiz)
    tuple('ziuq', 4, true, false, vec['quizzes']),
    // waltzes (waltz)
    tuple('z', 1, true, true, vec['zes']),
  ];

  /**
   * A list of words which should not be inflected, reversed.
   */
  private static vec<string> $uninflected = vec[
    'atad',
    'reed',
    'kcabdeef',
    'hsif',
    'ofni',
    'esoom',
    'seires',
    'peehs',
    'seiceps',
  ];

  /**
   * Returns the singular possibilities form of a word.
   *
   * @param string $plural A word in plural form
   *
   * @return Container<string> a container of possible singular forms
   */
  public static function singularize(string $plural): Container<string> {
    $pluralRev = Str\reverse($plural);
    $lowerPluralRev = Str\lowercase($pluralRev);
    $pluralLength = Str\length($lowerPluralRev);

    if (C\contains(static::$uninflected, $lowerPluralRev)) {
      return vec[$plural];
    }

    // The outer loop iterates over the entries of the plural table
    // The inner loop $j iterates over the characters of the plural suffix
    // in the plural table to compare them with the characters of the actual
    // given plural suffix
    foreach (static::$pluralMap as $map) {
      $suffix = $map[0];
      $suffixLength = $map[1];
      $j = 0;

      // Compare characters in the plural table and of the suffix of the
      // given plural one by one
      while ($suffix[$j] === $lowerPluralRev[$j]) {
        // Let $j point to the next character
        ++$j;

        // Successfully compared the last character
        // Add an entry with the singular suffix to the singular array
        if ($j === $suffixLength) {
          // Is there any character preceding the suffix in the plural string?
          if ($j < $pluralLength) {
            $nextIsVocal = Str\contains(static::$vocals, $lowerPluralRev[$j]);

            if (!$map[2] && $nextIsVocal) {
              // suffix may not succeed a vocal but next char is one
              break;
            }

            if (!$map[3] && !$nextIsVocal) {
              // suffix may not succeed a consonant but next char is one
              break;
            }
          }

          $newBase = Str\slice($plural, 0, $pluralLength - $suffixLength);
          $newSuffix = $map[4];

          // Check whether the first character in the plural suffix
          // is uppercased. If yes, uppercase the first character in
          // the singular suffix too
          $firstUpper = \ctype_upper($pluralRev[$j - 1]);

          $singulars = vec[];

          foreach ($newSuffix as $newSuffixEntry) {
            $singulars[] = $newBase.
              ($firstUpper ? Str\capitalize($newSuffixEntry) : $newSuffixEntry);
          }

          return $singulars;
        }

        // Suffix is longer than word
        if ($j === $pluralLength) {
          break;
        }
      }
    }

    // Assume that plural and singular is identical
    return vec[$plural];
  }

  /**
   * Returns the plural possibilities form of a word.
   *
   * @param string $singular A word in singular form
   *
   * @return Container<string> a container of possible plural forms
   */
  public static function pluralize(string $singular): Container<string> {
    $singularRev = Str\reverse($singular);
    $lowerSingularRev = Str\lowercase($singularRev);
    $singularLength = Str\length($lowerSingularRev);
    // Check if the word is one which is not inflected, return early if so
    if (C\contains(static::$uninflected, $lowerSingularRev)) {
      return vec[$singular];
    }

    // The outer loop iterates over the entries of the singular table
    // The inner loop $j iterates over the characters of the singular suffix
    // in the singular table to compare them with the characters of the actual
    // given singular suffix
    foreach (static::$singularMap as $map) {
      $suffix = $map[0];
      $suffixLength = $map[1];
      $j = 0;
      // Compare characters in the singular table and of the suffix of the
      // given plural one by one
      while ($suffix[$j] === $lowerSingularRev[$j]) {
        // Let $j point to the next character
        ++$j;
        // Successfully compared the last character
        // Add an entry with the plural suffix to the plural array
        if ($j === $suffixLength) {
          // Is there any character preceding the suffix in the plural string?
          if ($j < $singularLength) {
            $nextIsVocal = Str\contains(static::$vocals, $lowerSingularRev[$j]);
            if (!$map[2] && $nextIsVocal) {
              // suffix may not succeed a vocal but next char is one
              break;
            }

            if (!$map[3] && !$nextIsVocal) {
              // suffix may not succeed a consonant but next char is one
              break;
            }
          }

          $newBase = Str\slice($singular, 0, $singularLength - $suffixLength);
          $newSuffix = $map[4];
          // Check whether the first character in the singular suffix
          // is uppercased. If yes, uppercase the first character in
          // the singular suffix too
          $firstUpper = \ctype_upper($singularRev[$j - 1]);
          $plurals = vec[];
          foreach ($newSuffix as $newSuffixEntry) {
            $plurals[] = $newBase.
              ($firstUpper ? Str\capitalize($newSuffixEntry) : $newSuffixEntry);
          }

          return $plurals;
        }

        // Suffix is longer than word
        if ($j === $singularLength) {
          break;
        }
      }
    }

    // Assume that plural is singular with a trailing `s`
    return vec[$singular.'s'];
  }
}
