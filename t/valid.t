#!perl
use strict;

use Test::More tests => 19;

BEGIN {
  use_ok('Email::Valid');
}

my $v = Email::Valid->new;

ok(
  ! $v->address('Alfred Neuman <Neuman@BBN-TENEXA>'),
  'Alfred Neuman <Neuman@BBN-TENEXA>',
);

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

ok(
  $v->address('somebody@ example.com'),
  "space between @ and domain is valid",
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

SKIP: {
  skip "your dns appears missing or failing to resolve", 2
    unless $v->address(-address=> 'devnull@pobox.com', -mxcheck => 1);

  ok(
    $v->address(-address => 'blort@aol.com', -mxcheck => 1),
    'blort@aol.com, with mxcheck, is ok',
  );

  ok(
    !$v->address(-address => 'blort@will-never-exist.pobox.com', -mxcheck => 1),
    'blort@will-never-exist.pobox.com, with mxcheck, is invalid',
  );
}

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
