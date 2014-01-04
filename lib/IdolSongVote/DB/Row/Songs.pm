package IdolSongVote::DB::Row::Songs;
use strict;
use warnings;
use utf8;
use parent qw(Teng::Row);

sub vote {
    my ($self) = @_;

    my $song = $self->{teng}->single('songs', {id => $self->id});
    $song->polled($song->polled + 1);
    $song->update;
}

1;
