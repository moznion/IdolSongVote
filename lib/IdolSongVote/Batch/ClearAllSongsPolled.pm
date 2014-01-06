package IdolSongVote::Batch::ClearAllSongsPolled;
use strict;
use warnings;
use utf8;
use Class::Accessor::Lite(
    new => 1,
    ro  => [qw/c/],
);

sub run {
    my $self = shift;
    my $c = $self->c;

    my $table = 'songs';

    $c->db->update(
        $table,
        {polled => 0},
        [polled => {'!=' => 0}],
    );
}

1;
