use strict;
use warnings;

use Test::More tests => 3;

use Email::Valid;

eval {
    Email::Valid->new( -mxcheck => 3, bad => 1 );
};

like $@, qr/argument 'bad' not recognized/, 'throws an error';

subtest 'can pass args as hashref' => sub {
    my $ev = Email::Valid->new({ mxcheck => 1, fudge => 2 });

    is $ev->{mxcheck} => 1;
    is $ev->{fudge}   => 2;
};

subtest 'can pass args without dashes' => sub {
    my $ev = Email::Valid->new( mxcheck => 1, fudge => 2);

    is $ev->{mxcheck} => 1;
    is $ev->{fudge}   => 2;
};
