use strict;
use warnings;
use Test::More;


use IdolSongVote;
use IdolSongVote::Web;
use IdolSongVote::Web::View;
use IdolSongVote::Web::ViewFunctions;

use IdolSongVote::DB::Schema;
use IdolSongVote::Web::Dispatcher;


pass "All modules can load.";

done_testing;
