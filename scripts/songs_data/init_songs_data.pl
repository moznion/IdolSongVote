#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use Encode;
use FindBin;
use Text::LTSV;

use constant NUM_OF_SONGS => 661;

use constant GOJUON_MAP => +{
    a     => ['あ', 'い', 'う', 'え', 'お'],
    ka    => ['か', 'き', 'く', 'け', 'こ'],
    sa    => ['さ', 'し', 'す', 'せ', 'そ'],
    ta    => ['た', 'ち', 'つ', 'て', 'と'],
    na    => ['な', 'に', 'ぬ', 'ね', 'の'],
    ha    => ['は', 'ひ', 'ふ', 'へ', 'ほ'],
    ma    => ['ま', 'み', 'む', 'め', 'も'],
    ya    => ['や', 'ゆ', 'よ'],
    ra    => ['ら', 'り', 'る', 'れ', 'ろ'],
    wa    => ['わ', 'を', 'ん'],
    'a-m' => ['A' .. 'M'],
    'n-z' => ['N' .. 'Z'],
    '0-9' => [0 .. 9],
};

my %songs;
my %song_with_group;
my $p = Text::LTSV->new;
my $i = 0;
for my $song (@{$p->parse_file("$FindBin::Bin/songs.ltsv")}) {
    last if $i >= NUM_OF_SONGS;

    my $initial = $song->{initial} or next;
    my $title   = $song->{title} or next;

    next if ++$songs{$title} > 1; # タイトルの重複避け

    my $group = retrieve_initial_group(decode_utf8($initial));

    unless ($song_with_group{$group}) {
        $song_with_group{$group} = [];
    }

    push $song_with_group{$group}, +{
        title  => $title,
        polled => 0,
    };

    $i++;
}

my $j = 0;
open my $fh_all, '>', "$FindBin::Bin/../../data_files/songs/all.ltsv";
for my $group (keys %song_with_group) {
    open my $fh_with_group, '>', "$FindBin::Bin/../../data_files/songs/$group.ltsv";

    for my $song (@{$song_with_group{$group}}) {
        print $fh_with_group Text::LTSV->new(%$song)->to_s . "\n";
        print $fh_all Text::LTSV->new(
            title => $song->{title},
            initial_group => $group,
        )->to_s . "\n";
    }
    chmod 0707, $fh_with_group;

    close $fh_with_group;
}
chmod 0707, $fh_all;
close $fh_all;

sub retrieve_initial_group {
    my ($initial) = @_;

    for my $group (keys %{+GOJUON_MAP}) {
        for my $elem (@{GOJUON_MAP->{$group}}) {
            return $group if $initial eq $elem;
        }
    }
}
