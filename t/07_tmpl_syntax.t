#!perl

use strict;
use warnings;
use utf8;

use Test::More;
use IdolSongVote::Web;
use IdolSongVote::Web::View;

my @files = (<tmpl/*.tx>, <tmpl/*/*.tx>);

my $tx = IdolSongVote::Web::View->make_instance('IdolSongVote::Web');
for my $file (@files) {
    my (undef, @file) = split(qr!/!, $file);

    eval { $tx->validate(join('/', @file)) };
    ok !$@, qq/Xslate Syntax OK: "$file"/;
}

done_testing;
