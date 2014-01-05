package IdolSongVote::DB;
use strict;
use warnings;
use utf8;
use parent qw(Teng);
use IdolSongVote::Exception::SongNotExistException;
use IdolSongVote::Exception::InvalidSerialNumberException;

use constant GOJUON_MAP => +{
    a  => ['あ', 'い', 'う', 'え', 'お'],
    ka => ['か', 'き', 'く', 'け', 'こ'],
    sa => ['さ', 'し', 'す', 'せ', 'そ'],
    ta => ['た', 'ち', 'つ', 'て', 'と'],
    na => ['な', 'に', 'ぬ', 'ね', 'の'],
    ha => ['は', 'ひ', 'ふ', 'へ', 'ほ'],
    ma => ['ま', 'み', 'む', 'め', 'も'],
    ya => ['や', 'ゆ', 'よ'],
    ra => ['ら', 'り', 'る', 'れ', 'ろ'],
    wa => ['わ', 'を', 'ん'],
};

sub fetch_songs_by_first_char {
    my ($self, $first_char) = @_;

    my $search_query;
    if ($first_char =~ /^\w-\w$/) { # For `a-m`, `n-z` and `0-9`
        my ($begin, $end) = split /-/, $first_char;
        for my $char ($begin..$end) {
            push @$search_query, $char;
        }
    }
    else {
        $search_query = GOJUON_MAP->{$first_char};
    }

    unless ($search_query) {
        die IdolSongVote::Exception::SongNotExistException->new;
    }

    my $songs = $self->search(
        'songs',
        {first_char => $search_query},
        {order_by => 'id'},
    );

    return $songs;
}

sub fetch_songs_by_search_word {
    my ($self, $word) = @_;

    my $songs = $self->search(
        'songs',
        ['title' => {'like' => "%$word%"}],
        {order_by => 'id'},
    );

    return $songs;
}

sub fetch_song_by_id {
    my ($self, $id) = @_;

    return $self->single(
        'songs',
        {'id' => $id},
    ) || die IdolSongVote::Exception::SongNotExistException->new;
}

sub fetch_serial_number {
    my ($self, $serial_number) = @_;

    return $self->single(
        'serial_numbers',
        {'serial_number' => $serial_number},
    ) || die IdolSongVote::Exception::InvalidSerialNumberException->new;
}

1;
