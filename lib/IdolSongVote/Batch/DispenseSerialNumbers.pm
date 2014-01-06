package IdolSongVote::Batch::DispenseSerialNumbers;
use strict;
use warnings;
use utf8;
use Crypt::Blowfish;
use Class::Accessor::Lite(
    new => 1,
    ro  => [qw/c/],
);

sub run {
    my ($self, $num) = @_;
    my $c = $self->c;

    my $key = pack("H16", $c->config->{serial_number_gen_key});
    my $cipher = Crypt::Blowfish->new($key);

    my $table   = 'serial_numbers';

    $num ||= 1000000;
    for my $num (1..$num) {
        my $target     = sprintf("%08d", $num);
        my $ciphertext = $cipher->encrypt($target);

        $c->db->insert($table,
            +{
                serial_number => unpack("H16", $ciphertext),
                is_used       => 0,
            }
        );
    }
}

1;
