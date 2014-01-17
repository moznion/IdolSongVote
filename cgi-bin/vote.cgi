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
        my $polled_log_file = '../data_files/songs/polled.log';

        open my $frh, '<', $serial_number_file;
        flock $frh, 1;
        open my $fwh, '>>', $polled_log_file;
        flock $fwh, 2;
        seek $fwh, 0, 2;

        print $fwh sprintf("%s\t%s\n", encode_utf8($title), encode_utf8($initial_group));
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
