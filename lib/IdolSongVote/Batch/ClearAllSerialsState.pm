package IdolSongVote::Batch::ClearAllSerialsState;
use strict;
use warnings;
use utf8;
use Class::Accessor::Lite(
    new => 1,
    ro  => [qw/c/],
);

sub run {
    my ($self) = @_;
    my $c = $self->c;

    my $table = 'serial_numbers';

    $c->db->update(
        $table,
        {is_used => 0},
        [is_used => {'!=' => 0}],
    );
}
1;
