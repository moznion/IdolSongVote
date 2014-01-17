package IdolSongVote::Util;
use strict;
use warnings;
use FindBin;

my $place_holder = '\[%IdolSongVote_CONTENT_PLACE%\]';

sub embed_content_to_base_html {
    my ($content) = @_;

    my $base_html = _load_base_html();
    $base_html =~ s/$place_holder/$content/;
    return $base_html;
}

sub _load_base_html {
    open my $fh, '<', "$FindBin::Bin/tmpl/base.html";
    do { local $/; <$fh>; }
}
1;
