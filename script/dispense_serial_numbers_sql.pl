#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use DBI;
use DBD::mysql;
use Crypt::Blowfish;
use SQL::Maker;
use FindBin;

my $key    = pack("H16", "dankogai"); # TODO キーフレーズ真面目に考えたほうが良い
my $cipher = Crypt::Blowfish->new($key);

my $table   = 'serial_numbers';
my $builder = SQL::Maker->new(driver => 'mysql');

my $db_config = do "$FindBin::Bin/../config/development.pl";
my $dbh = DBI->connect(@{$db_config->{DBI}});

for my $num (1..1000000) {
    my $target     = sprintf("%08d", $num);
    my $ciphertext = $cipher->encrypt($target);

    my ($sql, @binds) = $builder->insert(
        $table,
        +{
            serial_number => unpack("H16", $ciphertext),
            is_used       => 0,
        },
    );

    my $sth = $dbh->prepare($sql);
    $sth->execute(@binds);
}
