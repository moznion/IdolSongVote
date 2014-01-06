package IdolSongVote;
use strict;
use warnings;
use utf8;
our $VERSION='0.01';
use 5.008001;
use Module::Load;
use IdolSongVote::DB::Schema;
use IdolSongVote::DB;

use parent qw/Amon2/;
# Enable project local mode.
__PACKAGE__->make_local_context();

my $schema = IdolSongVote::DB::Schema->instance;

sub db {
    my $c = shift;
    if (!exists $c->{db}) {
        my $conf = $c->config->{DBI}
            or die "Missing configuration about DBI";
        $c->{db} = IdolSongVote::DB->new(
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

sub res_400 {
    my $c = shift;
    return $c->create_simple_status_page(400, 'Bad Request');
}

sub batch {
    my ($self, $name) = @_;
    $self->_load_component('Batch', $name);
}

sub _load_component {
    my ($self, $base, $name) = @_;

    $self->{"$base#$name"} //= do {
        my $klass = "IdolSongVote::${base}::$name";
        Module::Load::load($klass);
        $klass->new(c => $self);
    };
}

1;
__END__

=head1 NAME

IdolSongVote - IdolSongVote

=head1 DESCRIPTION

This is a main context class for IdolSongVote

=head1 AUTHOR

IdolSongVote authors.

