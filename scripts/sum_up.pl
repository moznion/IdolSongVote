#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use FindBin;
use Encode;

my $songs_data_dir  = "$FindBin::Bin/../data_files/songs";
my $polled_log_file = "$songs_data_dir/polled.log";
open my $fh, '>>', $polled_log_file;
flock $fh, 2;

my $log_to_sum_up = $polled_log_file . ".bak";
rename $polled_log_file, $log_to_sum_up;
close $fh;

my $polled_data = {};
open my $frh, '<', $log_to_sum_up;
while (my $line = <$frh>) {
    chomp($line);
    my @polled = split /\t/, $line;
    my $title = decode_utf8($polled[0]);
    my $initial_group = decode_utf8($polled[1]);

    unless ($polled_data->{$initial_group}) {
        $polled_data->{$initial_group} = {};
    }

    $polled_data->{$initial_group}->{$title}++;
}
close $frh;
unlink $log_to_sum_up;

for my $group (keys %$polled_data) {
    my $song_file = "$songs_data_dir/$group.tsv";
    my $song_file_stash = "$song_file.bak";
    rename $song_file, $song_file_stash;

    open my $frh, '<', $song_file_stash;
    open my $fwh, '>', $song_file;
    while (my $line = <$frh>) {
        chomp($line);
        my @song_data = split /\t/, $line;
        my $title  = decode_utf8($song_data[0]);
        my $polled = decode_utf8($song_data[1]);

        if (my $polled_addition = $polled_data->{$group}->{$title}) {
            $polled += $polled_addition;
        }

        print $fwh sprintf("%s\t%s\n", encode_utf8($title), encode_utf8($polled));
    }

    unlink $song_file_stash;
}
