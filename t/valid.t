#!perl
use strict;

use Test::More tests => 33;

BEGIN {
  use_ok('Email::Valid');
}

my $v = Email::Valid->new;

for my $sub (
  sub { $_[0] },
  sub { Mail::Address->new(undef, $_[0]) },
) {
  ok(
    ! $v->address( $sub->('Alfred Neuman <Neuman@BBN-TENEXA>') ),
    'Alfred Neuman <Neuman@BBN-TENEXA>',
  );

  ok(
    $v->address( $sub->('123@example.com') ),
    '123@example.com',
  );
}

ok(
  $v->address( -address => 'Alfred Neuman <Neuman@BBN-TENEXA>', -fqdn    => 0),
  'Alfred Neuman <Neuman@BBN-TENEXA> { -fqdn => 0 }',
);

is(
  $v->address( -address => 'first last@aol.com', -fudge   => 1),
  'firstlast@aol.com',
  "spaces fudged out of an address local-part",
);

ok(
  ! $v->address( -address => 'first last@aol.com', -fudge   => 0),
  "spaces in localpart is not valid when not fudging",
);

is($v->details, 'rfc822', "details are rfc822");

is(
  $v->address('foo @ foo.com'),
  'foo@foo.com',
  "spaced out address is squished"
);
 
is(
  $v->address(q{fred&barney@stonehenge(yup, the rock place).(that's dot)com}),
  'fred&barney@stonehenge.com',
  "comments nicely dropped from an address",
);

is ($v->address(-address => 'user@example.aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'),
  undef,
  "address with > 254 chars fails",
);

is($v->details, 'address_too_long', "details say address is too long");

is(
  $v->address(-address => 'somebody@example.com', -localpart => 1),
  'somebody@example.com',
  "localpart with 64 chars or less is valid",
);

is(
  $v->address(-address => 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa@example.com', -localpart => 1),
  undef,
  "localpart with 64 chars or more fails",
);

is($v->details, 'localpart', "details are localpart");

ok(
  $v->address('somebody@ example.com'),
  "space between @ and domain is valid",
);

is(
  $v->address(-address => '1@example.com', -localpart => 1),
  '1@example.com',
  "localpart in true context succeeds",
);

is(
  $v->address(-address => '0@example.com', -localpart => 1),
  '0@example.com',
  "localpart in false context is defined (bug 75736)",
);

ok(
  $v->address('-dashy@example.net'),
  'an email can start with a dash',
);

ok(
  $v->address(-address => '-dashy@example.net'),
  'an email can start with a dash (alternate calling method)',
);

ok(
  ! $v->address(-address => 'dashy@-example.net', -fqdn => 1),
  'but a domain cannot',
);

ok(
  ! $v->address(-address => 'dashy@example.net-', -fqdn => 1),
  'a domain cannot end with a dash either',
);

ok(
  $v->address(-address => 'dashy@a--o.example.net', -fqdn => 1),
  'but a domain may contain two dashes in a row in the middle',
);

ok(
  $v->address(-address => 'dashy@ao.example.net', -fqdn => 1),
  'and of course two-character labels are valid!',
);

ok(
  $v->address(-address => 'dashy@a.a.example.net', -fqdn => 1),
  'onesies, too',
);

SKIP: {
  skip "your dns appears missing or failing to resolve", 2
    unless eval { $v->address(-address=> 'devnull@pobox.com', -mxcheck => 1) };

  if (
    $v->address(-address => 'blort@will-never-exist.pobox.com', -mxcheck => 1)
  ) {
    skip "your dns is lying to you; you must not use mxcheck", 2;
  }

  ok(
    $v->address(-address => 'blort@aol.com', -mxcheck => 1),
    'blort@aol.com, with mxcheck, is ok',
  );

  ok(
    !$v->address(-address => 'blort@will-never-exist.pobox.com', -mxcheck => 1),
    'blort@will-never-exist.pobox.com, with mxcheck, is invalid',
  ) or diag "was using $Email::Valid::DNS_Method for dns resolution";
}

ok(
  $v->address(-address => 'rjbs@[127.0.0.1]'),
  'a domain literal address is okay',
);

ok(
  ! $v->address(-address => 'rjbs@[127.0.0.1]', -allow_ip => 0),
  'a domain literal address is not okay if we say -allow_ip=>0',
);

SKIP: {
  skip "tests require Net::Domain::TLD 1.65", 3
    unless (eval {require Net::Domain::TLD;Net::Domain::TLD->VERSION(1.65);1});

  my $v = Email::Valid->new;

  ok(
    $v->address( -address => 'blort@notarealdomainfoo.com', -mxcheck => 0, -tldcheck => 1),
    'blort@notarealdomainfoo.com is ok with tldcheck',
  );

  ok(
    ! $v->address( -address => 'blort@notarealdomainfoo.bla', -mxcheck => 0, -tldcheck => 1),
    'blort@notarealdomainfoo.bla is not ok with tldcheck',
  );

  is($v->details, 'tldcheck', "it was the tldcheck that broke this email");
}
