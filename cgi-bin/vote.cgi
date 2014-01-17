#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use CGI::Simple;

my $cgi = CGI::Simple->new;

my $title         = $cgi->param('title');
my $initial_group = $cgi->param('initial_group');
my $res_status    = $cgi->param('status');

my $request_method = $cgi->request_method();
if ($request_method eq 'POST') {
    my $serial_number      = $cgi->param('serial_number');
    my $serial_number_file = sprintf(
        "../data_files/serial_numbers/%s/%s",
        substr($serial_number, 0, 2),
        $serial_number,
    );

    my $status;
    if (-f $serial_number_file) {
        my $tsv_file      = "../data_files/songs/$initial_group.tsv";

        my $songs;
        open my $fh, '<', $tsv_file;
        while (chomp(my $line = <$fh>)) {
            my @song_data = split /\t/, $line;
            push @$songs, {
                title  => $song_data[0],
                polled => $song_data[1],
            };
        }

        open my $frh, '<', $serial_number_file;
        flock $frh, 1;
        open my $fwh, '>', $tsv_file;
        flock $fwh, 2;
        seek $fwh, 0, 2;

        for my $song (@$songs) {
            if ($song->{title} eq $title) {
                $song->{polled}++;
            }
            print $fwh "$song->{title}\t$song->{polled}" . "\n";
        }
        rename $serial_number_file, "${serial_number_file}_USED";

        $status = 200;
    }
    else {
        # invalid serial
        $status = 400;
    }
    print $cgi->redirect("song.cgi?initial_group=$initial_group&title=$title&status=$status");
}
