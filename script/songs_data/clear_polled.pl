#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use DBIx::Sunny;
use DBD::mysql;
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
my $db_config = do "$FindBin::Bin/../../config/$opts{ENV}.pl";
my $dbh = DBIx::Sunny->connect(@{$db_config->{DBI}});

my $table   = 'songs';
my $builder = SQL::Maker->new(driver => 'mysql');

my ($sql, @binds) = $builder->update(
    $table,
    [polled => 0],
    [polled => {'!=' => 0}],
);

$dbh->query($sql, @binds);
