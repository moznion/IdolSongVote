#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use CGI::Simple;
use Encode;

my $cgi = CGI::Simple->new;

my $title         = decode_utf8($cgi->param('title'));
my $initial_group = decode_utf8($cgi->param('initial_group'));

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
                title  => decode_utf8($song_data[0]),
                polled => decode_utf8($song_data[1]),
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
            print $fwh sprintf("%s\t%s\n", encode_utf8($song->{title}), encode_utf8($song->{polled}));
        }
        rename $serial_number_file, "${serial_number_file}_USED";

        $status = 200;
    }
    else {
        # invalid serial
        $status = 400;
    }
    print $cgi->redirect(
        sprintf(
            "song.cgi?initial_group=%s&title=%s&status=%s",
            encode_utf8($initial_group), encode_utf8($title), encode_utf8($status)
        )
    );
}
