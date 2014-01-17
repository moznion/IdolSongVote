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
my $initial_group = decode_utf8($cgi->param('initial_group'));

my $crlf = $cgi->crlf();
print "Content-Type: text/html; charset=UTF-8 $crlf$crlf";

my $content = <<'...';
<h3>曲一覧</h3>
<ul>
...

open my $fh, '<', "../data_files/songs/$initial_group.tsv";
while (my $line = <$fh>) {
    chomp($line);
    my @song_data = split /\t/, $line;

    my $initial_group = escape_html($initial_group);
    my $title = escape_html(decode_utf8($song_data[0]));
    $content .= qq{<li><a href="song.cgi?initial_group=$initial_group&title=$title">$title</a></li>};
}
$content .= '</ul>';

my $html = IdolSongVote::Util::embed_content_to_base_html($content);
print $html;
