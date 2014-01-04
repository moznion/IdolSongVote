package IdolSongVote::Web::Plugin::FlashMessage;
use strict;
use warnings;
use utf8;
use Amon2::Util;

my %keys;

sub init {
    my ($class, $c, $conf) = @_;

    Amon2::Util::add_method($c, flash => \&_flash);
}

sub _flash {
    my ($c, $key, $value) = @_;

    my $flush_message = $c->session->get($key);
    if ($value) {
        $c->session->set($key, $value);
        $flush_message = $value;
    }
    else {
        $c->session->remove($key);
    }

    return $flush_message;
}

1;
