#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use Crypt::Blowfish;
use FindBin;

my ($num) = @ARGV;

my $key = pack("H16", 'dankogai');
my $cipher = Crypt::Blowfish->new($key);

$num ||= 1000000;
for my $num (1..$num) {
    my $target     = sprintf("%08d", $num);
    my $ciphertext = $cipher->encrypt($target);

    my $serial_number = unpack("H16", $ciphertext);
    my $dir = sprintf("%s/../../data_files/serial_numbers/%s", $FindBin::Bin, substr($serial_number, 0, 2));

    unless (-d $dir) {
        mkdir $dir;
    }

    open my $fh, '>', "$dir/$serial_number";
    chmod 0707, $fh;
}
