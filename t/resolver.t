#!perl
use strict;
use Test::More;

if (!eval { require Net::DNS; 1 }) {
    plan skip_all => 'only relevant if Net::DNS is installed';
}
else {
    plan tests => 4;
}

# not yet loaded, so resolver should be undef
ok !defined $Email::Valid::Resolver, 'resolver is undef';

# load module, which calls import(), initializing resolver
use_ok('Email::Valid');

# check resolver object
ok defined $Email::Valid::Resolver, 'resover initialized';
isa_ok $Email::Valid::Resolver, 'Net::DNS::Resolver';
