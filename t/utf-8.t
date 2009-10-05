use strict;
use warnings;

use Test::More tests => 2;

use Email::Valid ();

ok(
  ! Email::Valid->address("adriano-f\xE9res\@blah.com"),
  'do not accept addr with \xE9',
);

ok(
  ! Email::Valid->address("adriano-u\x{11F}ur\@blah.com"),
  'do not accept addr with \x{11F}',
);

