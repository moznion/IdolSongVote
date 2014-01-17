#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use FindBin;

use constant NUM_OF_SONGS => 661;

my $gojuon_map = +{
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

my $initial_group_map = {};
for my $group (keys %$gojuon_map) {
    for my $char (@{$gojuon_map->{$group}}) {
        $initial_group_map->{$char} = $group;
    }
}

my %songs;
my %song_with_group;
my $i = 0;

open my $fh, '<:encoding(utf-8)', "$FindBin::Bin/songs.tsv" or die "Can't open songs tsv file to read: $!";
while (my $line = <$fh>) {
    chomp($line);
    last if $i >= NUM_OF_SONGS;

    my @song_data = split /\t/, $line;
    if (!$song_data[0] || !$song_data[1]) {
        next;
    }
    my $title   = $song_data[0];
    my $initial = $song_data[1];

    next if ++$songs{$title} > 1; # タイトルの重複避け

    my $group = $initial_group_map->{$initial};

    unless ($song_with_group{$group}) {
        $song_with_group{$group} = [];
    }

    push $song_with_group{$group}, "$title\t0";

    $i++;
}

my $j = 0;
for my $group (keys %song_with_group) {
    open my $fh_with_group, '>:encoding(utf-8)', "$FindBin::Bin/../../data_files/songs/$group.tsv" or die "Can't open songs file to write: $!";

    for my $song (@{$song_with_group{$group}}) {
        print $fh_with_group "$song\n";
    }
    chmod 0707, $fh_with_group;

    close $fh_with_group;
}
