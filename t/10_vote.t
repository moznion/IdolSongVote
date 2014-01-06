#!perl

use strict;
use warnings;
use utf8;
use t::Util;
use Plack::Util;
use Web::Query;
use Test::More;
use Test::WWW::Mechanize::PSGI;

use IdolSongVote;

IdolSongVote->bootstrap;
my $c = IdolSongVote->context;

$c->batch('DispenseSerialNumbers')->run(1);
$c->batch('StoreSongsData')->run(1);

subtest 'Vote' => sub {
    my $serial_numbers_table = 'serial_numbers';
    my $songs_table = 'songs';
    my $serial_number = $c->db->single($serial_numbers_table);
    my $song = $c->db->single($songs_table);

    is $serial_number->is_used, '0', 'シリアルナンバーは未使用';
    is $song->polled, '0', '楽曲の投票数は初期値 (0)';

    my $app = Plack::Util::load_psgi 'script/idolsongvote-server';

    my $mech = Test::WWW::Mechanize::PSGI->new(app => $app);

    subtest '未使用シリアルナンバーでVoteしたら成功する' => sub {
        $mech->post_ok('/vote', +{
            song_id => $song->id,
            serial_number => $serial_number->serial_number,
        });

        subtest 'indexページにリダイレクトする' => sub {
            my $res = $mech->res;
            is $res->request->uri->path, '/';

            my $does_flash_exist = 0;
            wq($res->content)->find('div.flash-success')->each(sub {
                $does_flash_exist++;
            });
            ok $does_flash_exist, 'flashメッセージが存在する';
        };

        $serial_number = $c->db->single($serial_numbers_table);
        $song = $c->db->single($songs_table);
        is $serial_number->is_used, '1', 'シリアルナンバーが使用済みになる';
        is $song->polled, '1', '楽曲の投票数がインクリメントされる';
    };

    subtest '使用済みシリアルナンバーでVoteしたら失敗する' => sub {
        $mech->post('/vote', +{
            song_id => $song->id,
            serial_number => $serial_number->serial_number,
        });
        is $song->polled, '1', '使用済みシリアルナンバーでVoteしても投票数が増えない';

        subtest '画面遷移しない' => sub {
            my $res = $mech->res;
            is $res->request->uri->path, '/vote';
            is $res->request->uri->query, 'song_id=1';

            my $does_flash_exist = 0;
            wq($res->content)->find('div.flash-error')->each(sub {
                $does_flash_exist++;
            });
            ok $does_flash_exist, 'flashメッセージが存在する';
        };
    };
};

done_testing;
