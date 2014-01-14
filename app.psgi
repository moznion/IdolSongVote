use strict;
use warnings;

use FindBin;
use Plack::Builder;
use Plack::App::CGIBin;

my $app = Plack::App::CGIBin->new(root => "$FindBin::Bin/cgi-bin")->to_app;
builder {
    enable "Static",
      path => qr{^/(?:js|css|bootstrap)/},
      root => './static/';
    mount '/cgi-bin' => $app,
}
