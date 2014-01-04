package IdolSongVote::DB::Row::SerialNumbers;
use strict;
use warnings;
use utf8;
use parent qw(Teng::Row);

sub is_available {
    my ($self) = @_;

    if ($self->is_used) {
        return 0;
    }

    return 1;
}

sub mark_as_used {
    my ($self) = @_;

    $self->{teng}->update(
        'serial_numbers',
        {is_used => 1},
        {serial_number => $self->serial_number},
    );
}

1;
