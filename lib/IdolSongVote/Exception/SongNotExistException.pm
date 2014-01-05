package IdolSongVote::Exception::SongNotExistException;
use strict;
use warnings;
use utf8;
use parent qw/IdolSongVote::Exception/;

sub new {
    my $class = shift;

    bless {}, $class;
}

1;
