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
my $songs  = Text::LTSV->new->parse_file("../data_files/songs/$initial_group.ltsv");
my ($song) = grep { $_->{title} eq $title } @$songs;

my $nc = $cgi->crlf();
print "Content-Type: text/html; charset=UTF-8 $nc$nc";

open my $fh, '<', '../tmpl/base.html';
my $html = '';
while (my $line = <$fh>) {
    $html .= $line;
}
my $content = '<script src="../js/flash_message.js"></script>';

if ($res_status == 200) {
    $content .= '<div class="flash-success">✓ 投票しました</div>'
}
elsif ($res_status == 400) {
    $content .= '<div class="flash-error">✗ 不正なシリアルナンバーです</div>'
}

my $escaped_song_title = escape_html(decode_utf8($song->{title}));
$content .= "<h3>投票する曲: $escaped_song_title</h3>";
$content .= '<h3>投票数: ' . escape_html($song->{polled}) . '</h3>';
$content .= <<'...';
<br />
<form action="vote.cgi" method="post">
  <p>
    シリアルナンバー: <input type="text" name="serial_number" size="40">
    <input type="submit" class="btn" value="この曲に投票する！">
  </p>
...
my $escaped_initial_group = escape_html($initial_group);
$content .= qq{<input type="hidden" name="initial_group" value="$escaped_initial_group">};
$content .= qq{<input type="hidden" name="title" value="$escaped_song_title">};
$content .= '</form>';
$html =~ s/$place_holder/$content/;

print $html;
