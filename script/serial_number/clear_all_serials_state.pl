#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use IdolSongVote;

my $c = IdolSongVote->new;
$c->batch('ClearAllSerialsState')->run(@ARGV);
