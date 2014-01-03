#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use DBI;
use DBD::mysql;
use Crypt::Blowfish;
use SQL::Maker;
use FindBin;
use Getopt::Long qw/:config posix_default no_ignore_case bundling auto_help/;

my %opts = (ENV => 'development');
GetOptions(
    \%opts, qw/
    ENV|E=s
/);

my $config_file;
unless ($opts{ENV} =~ /^(?:development|production|test)$/) {
    die "$opts{ENV}: Environment does not exist";
}
my $db_config = do "$FindBin::Bin/../config/$opts{ENV}.pl";
my $dbh = DBI->connect(@{$db_config->{DBI}});

my $key    = pack("H16", "dankogai"); # TODO キーフレーズ真面目に考えたほうが良い
my $cipher = Crypt::Blowfish->new($key);

my $table   = 'serial_numbers';
my $builder = SQL::Maker->new(driver => 'mysql');

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
