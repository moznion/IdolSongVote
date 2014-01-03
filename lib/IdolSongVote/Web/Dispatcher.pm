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
};

post '/vote' => sub {
};

1;
