#!/usr/bin/env carton exec -- perl

use strict;
use warnings;
use utf8;
use CGI::Simple;
use Encode;
use Text::LTSV;
use Text::Xslate;

my $cgi = CGI::Simple->new;

print "Content-type: text/html \n\n";

if (my $initial_group = $cgi->param('initial_group')) {
    my @songs;
    for my $song (@{Text::LTSV->new->parse_file("../data_files/songs/$initial_group.ltsv")}) {
        push @songs, {
            title         => $song->{title},
            initial_group => $initial_group,
        };
    }

    print encode_utf8(Text::Xslate->new->render("tmpl/songs.tx", {
        songs => \@songs,
    }));
}
elsif (my $search_query = $cgi->param('q')) {
    my $songs = Text::LTSV->new->parse_file("../data_files/songs/all.ltsv");
    my @filtered_songs = grep {$_->{title} =~ /$search_query/i} @$songs;

    print encode_utf8(Text::Xslate->new->render("tmpl/songs.tx", {
        songs => \@filtered_songs,
    }));
}
