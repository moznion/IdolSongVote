package t::Util;
BEGIN {
    unless ($ENV{PLACK_ENV}) {
        $ENV{PLACK_ENV} = 'test';
    }
    if ($ENV{PLACK_ENV} eq 'production') {
        die "Do not run a test script on deployment environment";
    }
}
use File::Spec;
use File::Basename;
use lib File::Spec->rel2abs(File::Spec->catdir(dirname(__FILE__), '..', 'lib'));
use parent qw/Exporter/;
use Test::More 0.98;
use Test::mysqld;

our @EXPORT = qw(
    slurp
);

{
    # utf8 hack.
    binmode Test::More->builder->$_, ":utf8" for qw/output failure_output todo_output/;
    no warnings 'redefine';
    my $code = \&Test::Builder::child;
    *Test::Builder::child = sub {
        my $builder = $code->(@_);
        binmode $builder->output,         ":utf8";
        binmode $builder->failure_output, ":utf8";
        binmode $builder->todo_output,    ":utf8";
        return $builder;
    };
}


sub slurp {
    my $fname = shift;
    open my $fh, '<:encoding(UTF-8)', $fname or die "$fname: $!";
    scalar do { local $/; <$fh> };
}

my $MYSQLD;

# initialize database
use IdolSongVote;
{
    unlink 'db/test.db' if -f 'db/test.db';
    system("sqlite3 db/test.db < sql/sqlite.sql");

    unless ($ENV{TEST_DSN}) {
        $MYSQLD = Test::mysqld->new(
            my_cnf => {
                'skip-networking' =>'',
            }
        ) or die $Test::mysqld::errstr;
        $ENV{TEST_DSN} = $MYSQLD->dsn;

        my $dbh = DBI->connect( $ENV{TEST_DSN} );

        my $sql = File::Spec->rel2abs("sql/mysql.sql");
        open my $fh, '<', $sql or plan skip_all => "Can't open schema file $sql.";
        my $lines = '';
        for my $line (<$fh>) {
            $lines .= $line;
        }
        for my $query (split /;\n/, $lines) {
            $dbh->do($query);
        }
    }
}

END { undef $MYSQLD }

1;
