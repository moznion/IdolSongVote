#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use lib "lib";
use CGI::Simple;
use Encode;
use HTML::Escape qw/escape_html/;
use IdolSongVote::Util;

my $cgi = CGI::Simple->new;

my $title         = decode_utf8($cgi->param('title'));
my $initial_group = decode_utf8($cgi->param('initial_group'));
my $res_status    = decode_utf8($cgi->param('status'));

my $crlf = $cgi->crlf();
print "Content-Type: text/html; charset=UTF-8 $crlf$crlf";

my $content = '<script src="../js/flash_message.js"></script>';

if ($res_status) {
    if ($res_status == 200) {
        $content .= '<div class="flash-success">✓ 投票しました</div>'
    }
    elsif ($res_status == 400) {
        $content .= '<div class="flash-error">✗ 不正なシリアルナンバーです</div>'
    }
}

my $song;
open my $fh, '<', "../data_files/songs/$initial_group.tsv";
while (my $line = <$fh>) {
    chomp($line);
    my @song_data = map {decode_utf8($_)} split /\t/, $line;
    if ($song_data[0] eq $title) {
        $song = \@song_data;
        last;
    }
}

my $escaped_song_title    = escape_html($song->[0]);
my $escaped_song_polled   = escape_html($song->[1]);
my $escaped_initial_group = escape_html($initial_group);
$content .= <<"...";
<h3>投票する曲: $escaped_song_title</h3>
<h3>投票数: $escaped_song_polled</h3>
<br />
<form action="vote.cgi" method="post">
  <p>
    シリアルナンバー: <input type="text" name="serial_number" size="40">
    <input type="submit" class="btn btn-default" value="この曲に投票する！">
  </p>
  <input type="hidden" name="initial_group" value="$escaped_initial_group">
  <input type="hidden" name="title" value="$escaped_song_title">
</form>
...

my $html = IdolSongVote::Util::embed_content_to_base_html($content);
print $html;
