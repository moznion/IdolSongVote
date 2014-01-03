package IdolSongVote::DB;
use strict;
use warnings;
use utf8;
use parent qw(Teng);

__PACKAGE__->load_plugin('Count');
__PACKAGE__->load_plugin('Replace');
__PACKAGE__->load_plugin('Pager');

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
    $self->single(
        'songs',
        {'id' => $id},
    );
}

sub vote_song {
    my ($self, $id) = @_;

    my $song = $self->single('songs', {id => $id});
    $song->polled($song->polled + 1);
    $song->update;
}

sub is_available_serial_number {
    my ($self, $serial_number) = @_;

    my $item = $self->single(
        'serial_numbers',
        {'serial_number' => $serial_number},
    );

    if (!$item || $item->is_used) {
        return 0;
    }

    return 1;
}

sub mark_serial_number_as_used {
    my ($self, $serial_number) = @_;

    $self->update(
        'serial_numbers',
        {is_used => 1},
        {serial_number => $serial_number},
    );
}

1;
