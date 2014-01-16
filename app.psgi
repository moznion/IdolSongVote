use strict;
use warnings;

use FindBin;
use Plack::Builder;
use Plack::App::CGIBin;
use Plack::App::File;

my $app = Plack::App::CGIBin->new(root => "$FindBin::Bin/cgi-bin")->to_app;
builder {
    enable "Static",
      path => qr{^/(?:js|css|bootstrap)/},
      root => './static/';
    mount '/'        => Plack::App::File->new(file => "./static/index.html")->to_app;
    mount '/cgi-bin' => $app,
}
