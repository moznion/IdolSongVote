#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use CGI::Simple;
use CGI::Simple::Cookie;
use Encode;
use Text::LTSV;
use Text::Xslate;

use constant DOMAIN => '';

my $cgi = CGI::Simple->new;

my $title         = $cgi->param('title');
my $initial_group = $cgi->param('initial_group');

my $request_method = $cgi->request_method();
if ($request_method eq 'GET') {
    my $songs  = Text::LTSV->new->parse_file("../data_files/songs/$initial_group.ltsv");
    my ($song) = grep { $_->{title} eq $title } @$songs;

    my $flash_error   = $cgi->cookie('flash_error');
    my $flash_success = $cgi->cookie('flash_success');
    my $flash_error_cookie   = set_flash_error_cookie('');
    my $flash_success_cookie = set_flash_success_cookie('');

    print "Set-Cookie: $flash_error_cookie\n";
    print "Set-Cookie: $flash_success_cookie\n";
    print "Content-type: text/html \n\n";
    print encode_utf8(Text::Xslate->new->render("tmpl/vote.tx", {
        song          => $song,
        initial_group => $initial_group,
        flash_error   => $flash_error,
        flash_success => $flash_success,
    }));
}
elsif ($request_method eq 'POST') {
    my $serial_number      = $cgi->param('serial_number');
    my $serial_number_dir  = substr($serial_number, 0, 2);
    my $serial_number_file = "../data_files/serial_numbers/$serial_number_dir/$serial_number";
    my $serial_number_lock = "$serial_number.lock";

    if (!(-d $serial_number_lock) && -f $serial_number_file) {
        mkdir $serial_number_lock;

        my $ltsv_file      = "../data_files/songs/$initial_group.ltsv";
        my $ltsv_file_lock = "$ltsv_file.lock";

        while (-d $ltsv_file_lock) {
            select undef, undef, undef, rand(0.5);
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

        my $cookie = set_flash_success_cookie('投票しました');
        print "Set-Cookie: $cookie\n";
    }
    else {
        # invalid serial
        my $cookie = set_flash_error_cookie('不正なシリアルナンバーです');
        print "Set-Cookie: $cookie\n";
    }
    print $cgi->redirect("vote.cgi?initial_group=$initial_group&title=$title");
}

sub set_flash_error_cookie {
    my ($error_message) = @_;

    my $message = $error_message ? encode_utf8($error_message)
                                 : '';
    CGI::Simple::Cookie->new(
        -name    => 'flash_error',
        -values  => $message,
        -domain  => DOMAIN,
        -path    => '/cgi-bin/vote.cgi',
    );
}

sub set_flash_success_cookie {
    my ($success_message) = @_;

    my $message = $success_message ? encode_utf8($success_message)
                                   : '';
    CGI::Simple::Cookie->new(
        -name    => 'flash_success',
        -values  => $message,
        -domain  => DOMAIN,
        -path    => '/cgi-bin/vote.cgi',
    );
}
