#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use lib "lib";
use Encode;
use HTML::Escape qw/escape_html/;
use IdolSongVote::Util;
use IdolSongVote::CGI::Simple;

my $cgi = IdolSongVote::CGI::Simple->new;
my $initial_group = $cgi->param('initial_group');

my $crlf = $cgi->crlf();
print "Content-Type: text/html; charset=UTF-8 $crlf$crlf";

my $content = <<'...';
<h3>曲一覧</h3>
<ul>
...

open my $fh, '<:encoding(utf-8)', "../data_files/songs/$initial_group.tsv" or die "Can't open songs tsv file to read: $!";
while (my $line = <$fh>) {
    chomp($line);
    my @song_data = split /\t/, $line;

    my $initial_group = escape_html($initial_group);
    my $title = escape_html($song_data[0]);
    $content .= qq{<li><a href="song.cgi?initial_group=$initial_group&title=$title">$title</a></li>};
}
$content .= '</ul>';

my $html = IdolSongVote::Util::embed_content_to_base_html($content);
print $html;
