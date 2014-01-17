#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use lib "lib";
use Encode;
use Fcntl qw(:flock SEEK_END);
use IdolSongVote::CGI::Simple;

my $cgi = IdolSongVote::CGI::Simple->new;

my $title         = $cgi->param('title');
my $initial_group = $cgi->param('initial_group');

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
        my $polled_log_file = '../data_files/songs/polled.log';
        open my $fwh, '>>:encoding(utf-8)', $polled_log_file or die "Can't open polled log file to append: $!";
        if (rename $serial_number_file, "${serial_number_file}_USED") {
            print $fwh "$title\t$initial_group\n";
            $status = 200;
        }
        else {
            $status = 400;
        }
    }
    else {
        # invalid serial
        $status = 400;
    }

    print $cgi->redirect(
        sprintf(
            "song.cgi?initial_group=%s&title=%s&status=%s",
            encode_utf8($initial_group), encode_utf8($title), $status
        )
    );
}
