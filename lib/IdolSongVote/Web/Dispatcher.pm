package IdolSongVote::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::RouterBoom;

any '/' => sub {
    my ($c) = @_;
    return $c->render('index.tx', {});
};

get '/songs' => sub {
    my ($c) = @_;

    my $search_word = $c->req->param('q');
    unless($search_word) {
        return $c->render('songs.tx', {});
    }

    my $songs = $c->db->fetch_songs_by_search_word($search_word);
    return $c->render('songs.tx', {songs => $songs});
};

get '/songs/:index' => sub {
    my ($c, $args) = @_;

    my $index = $args->{index};
    my $songs = $c->db->fetch_songs_by_first_char($index);
    return $c->render('songs.tx', {songs => $songs});
};

get '/vote' => sub {
    my ($c) = @_;

    my $song_id = $c->req->param('song_id');
    return $c->res_400 unless $song_id;

    my $song = $c->db->fetch_song_by_id($song_id);
    return $c->res_400 unless $song;

    return $c->render('vote.tx', {
        song_id => $song_id,
        song => $song,
    });
};

post '/vote' => sub {
    my ($c) = @_;

    my $song_id = $c->req->param('song_id');
    my $serial_number = $c->req->param('serial_number');
    return $c->res_400 if !$song_id || !$serial_number;

    if (!$c->db->is_available_serial_number($serial_number)) {
        return $c->res_400;
    }

    $c->db->vote_song($song_id);
    $c->db->mark_serial_number_as_used($serial_number);

    $c->redirect('/');
};

1;
