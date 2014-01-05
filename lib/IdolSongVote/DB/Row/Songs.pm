package IdolSongVote::DB::Row::Songs;
use strict;
use warnings;
use utf8;
use parent qw(Teng::Row);
use IdolSongVote::Exception::SongNotExistException;

sub vote {
    my ($self) = @_;

    my $song = $self->{teng}->single('songs', {id => $self->id});
    die IdolSongVote::Exception::SongNotExistException->new unless $song;

    $song->polled($song->polled + 1);
    $song->update;
}

1;
