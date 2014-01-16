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

my $nc = $cgi->crlf();
print "Content-Type: text/html; charset=UTF-8 $nc$nc";

open my $fh, '<', '../tmpl/base.html';
my $html = '';
while (my $line = <$fh>) {
    $html .= $line;
}
my $content = <<'...';
<h3>曲一覧</h3>
<ul>
...

my $initial_group = $cgi->param('initial_group');
my @songs;
for my $song (@{Text::LTSV->new->parse_file("../data_files/songs/$initial_group.ltsv")}) {
    push @songs, {
        title         => decode_utf8($song->{title}),
        initial_group => decode_utf8($initial_group),
    };
}

$content .= construct_songs_li(\@songs);
$content .= '</ul>';
$html =~ s/$place_holder/$content/;

print $html;

sub construct_songs_li {
    my ($songs) = @_;

    my $list = '';
    for my $song (@$songs) {
        my $initial_group = escape_html($song->{initial_group});
        my $title = escape_html($song->{title});
        $list .= qq{<li><a href="song.cgi?initial_group=$initial_group&title=$title">$title</a></li>};
    }
    return $list;
}
