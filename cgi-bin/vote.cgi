#!/usr/bin/env carton exec -- perl

use strict;
use warnings;
use utf8;
use CGI::Simple;
use Encode;
use Text::LTSV;
use HTML::Escape qw/escape_html/;

my $place_holder = '\[%IdolSongVote_CONTENT_PLACE%\]';
my $cgi = CGI::Simple->new;

my $title         = $cgi->param('title');
my $initial_group = $cgi->param('initial_group');
my $res_status    = $cgi->param('status');

my $request_method = $cgi->request_method();
if ($request_method eq 'POST') {
    my $serial_number      = $cgi->param('serial_number');
    my $serial_number_dir  = substr($serial_number, 0, 2);
    my $serial_number_file = "../data_files/serial_numbers/$serial_number_dir/$serial_number";
    my $serial_number_lock = "$serial_number.lock";

    my $status;
    if (!(-d $serial_number_lock) && -f $serial_number_file) {
        mkdir $serial_number_lock;

        my $ltsv_file      = "../data_files/songs/$initial_group.ltsv";
        my $ltsv_file_lock = "$ltsv_file.lock";

        while (-d $ltsv_file_lock) {
            select undef, undef, undef, rand(0.5); ## no critic
        }
        mkdir $ltsv_file_lock;

        my $songs = Text::LTSV->new->parse_file($ltsv_file);

        open my $fh, '>', $ltsv_file;
        for my $song (@$songs) {
            if ($song->{title} eq $title) {
                $song->{polled}++;
            }
            my $ltsv = Text::LTSV->new(%$song);
            print $fh $ltsv->to_s . "\n";
        }
        close $fh;

        rmdir $serial_number_lock;
        rmdir $ltsv_file_lock;
        unlink $serial_number_file;

        $status = 200;
    }
    else {
        # invalid serial
        $status = 400;
    }
    print $cgi->redirect("song.cgi?initial_group=$initial_group&title=$title&status=$status");
}
