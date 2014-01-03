#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use DBI;
use DBD::mysql;
use SQL::Maker;
use FindBin;
use Capture::Tiny qw/capture_stdout/;
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
my $dbh = DBI->connect(@{$db_config->{DBI}});

my $table = 'songs';
my $builder = SQL::Maker->new(driver => 'mysql');

my $songs = capture_stdout {
    system("phantomjs $FindBin::Bin/scrape_songs_data.js");
};

my $i = 0;
for my $song (split /\n/, $songs) {
    last if $i >= 661;

    my ($title, $first_char) = split /\t/, $song;
    next if !$title || !$first_char;

    my ($sql, @binds) = $builder->insert(
        $table,
        +{
            title      => $title,
            first_char => $first_char,
            polled     => 0,
        },
    );

    my $sth = $dbh->prepare($sql);
    my $insert_result = $sth->execute(@binds);
    if ($insert_result) {
        $i++;
    }
}
