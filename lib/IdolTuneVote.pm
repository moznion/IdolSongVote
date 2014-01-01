package IdolTuneVote;
use strict;
use warnings;
use utf8;
our $VERSION='0.01';
use 5.008001;
use IdolTuneVote::DB::Schema;
use IdolTuneVote::DB;

use parent qw/Amon2/;
# Enable project local mode.
__PACKAGE__->make_local_context();

my $schema = IdolTuneVote::DB::Schema->instance;

sub db {
    my $c = shift;
    if (!exists $c->{db}) {
        my $conf = $c->config->{DBI}
            or die "Missing configuration about DBI";
        $c->{db} = IdolTuneVote::DB->new(
            schema       => $schema,
            connect_info => [@$conf],
            # I suggest to enable following lines if you are using mysql.
            # on_connect_do => [
            #     'SET SESSION sql_mode=STRICT_TRANS_TABLES;',
            # ],
        );
    }
    $c->{db};
}

1;
__END__

=head1 NAME

IdolTuneVote - IdolTuneVote

=head1 DESCRIPTION

This is a main context class for IdolTuneVote

=head1 AUTHOR

IdolTuneVote authors.

