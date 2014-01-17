#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use FindBin;
use Fcntl qw(:flock);

my $songs_data_dir  = "$FindBin::Bin/../data_files/songs";
my $polled_log_file = "$songs_data_dir/polled.log";
open my $fh, '>>', $polled_log_file or die "Can't open polled log file to append: $!";
flock $fh, LOCK_EX or die "Can't lock to write polled log file: $!";

my $log_to_sum_up = $polled_log_file . ".bak";
rename $polled_log_file, $log_to_sum_up;
close $fh;

my $polled_data = {};
open my $frh, '<:encoding(utf-8)', $log_to_sum_up or die "Can't open polled log file to read: $!";
while (my $line = <$frh>) {
    chomp($line);
    my @polled = split /\t/, $line;
    my $title = $polled[0];
    my $initial_group = $polled[1];

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

    open my $frh, '<:encoding(utf-8)', $song_file_stash or die "Can't open song file to read: $!";
    open my $fwh, '>:encoding(utf-8)', $song_file or die "Can't open song file to write: $!";
    while (my $line = <$frh>) {
        chomp($line);
        my @song_data = split /\t/, $line;
        my $title  = $song_data[0];
        my $polled = $song_data[1];

        if (my $polled_addition = $polled_data->{$group}->{$title}) {
            $polled += $polled_addition;
        }

        print $fwh "$title\t$polled\n";
    }

    unlink $song_file_stash;
}
