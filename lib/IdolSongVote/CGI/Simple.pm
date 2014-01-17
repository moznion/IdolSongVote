package IdolSongVote::CGI::Simple;
use strict;
use warnings;
use utf8;
use parent qw/CGI::Simple/;
use Encode;

sub param {
    my ($self, $parameter) = @_;

    decode_utf8($self->SUPER::param($parameter));
}

1;
