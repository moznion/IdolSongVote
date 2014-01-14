#!/usr/bin/env carton exec -- perl
use strict;
use warnings;
use CGI;

my $q = CGI->new;

print join "\r\n", 'Content-Type: text/html;charset=utf-8', 'Content-Length: 4', '', '';
print "YAY\n";