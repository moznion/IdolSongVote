package IdolSongVote::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::RouterBoom;
use Try::Lite;

any '/' => sub {
    my ($c) = @_;

    $c->render('index.tx', {
        flash_success => $c->flash('flash_success') || '',
        flash_error   => $c->flash('flash_error')   || '',
    });
};

get '/songs' => sub {
    my ($c) = @_;

    my $search_word = $c->req->param('q') or return $c->render('songs.tx', {});
    my $songs = $c->db->fetch_songs_by_search_word($search_word);
    return $c->render('songs.tx', {songs => $songs});
};

get '/songs/:index' => sub {
    my ($c, $args) = @_;

    try {
        my $index = $args->{index};
        my $songs = $c->db->fetch_songs_by_first_char($index);
        return $c->render('songs.tx', {songs => $songs});
    } (
        'IdolSongVote::Exception::SongNotExistException' => sub {
            return $c->res_404;
        },
    );
};

get '/vote' => sub {
    my ($c) = @_;

    try {
        my $song_id = $c->req->param('song_id') or return $c->res_400;
        my $song = $c->db->fetch_song_by_id($song_id);
        return $c->render('vote.tx', {
            song_id     => $song_id,
            song        => $song,
            flash_error => $c->flash('flash_error') || '',
        });
    } (
        'IdolSongVote::Exception::SongNotExistException' => sub {
            return $c->res_404;
        },
    );
};

post '/vote' => sub {
    my ($c) = @_;

    my $song_id       = $c->req->param('song_id') or return $c->res_400;
    my $serial_number = $c->req->param('serial_number');

    try {
        my $song = $c->db->fetch_song_by_id($song_id);
        my $serial_number_row = $c->db->fetch_serial_number($serial_number);
        $serial_number_row->check_availability;

        my $txn = $c->db->txn_scope;
        $song->vote;
        $serial_number_row->mark_as_used;
        $txn->commit;

        $c->flash('flash_success', '投票しました');
        $c->redirect('/');
    } (
        'IdolSongVote::Exception::SongNotExistException' => sub {
            return $c->res_400;
        },
        'IdolSongVote::Exception::InvalidSerialNumberException' => sub {
            $c->flash('flash_error', '不正なシリアルナンバーです');
            return $c->redirect('/vote', +{song_id => $song_id});
        }
    );
};

1;
