use strict;
use warnings;

use Plack::Builder;
use Plack::App::CGIBin;

# my $cgibin =
# my $static =

builder {
    enable 'ReverseProxy';
    mount  '/'        => Plack::App::File->new(root => "static")->to_app;
    mount  '/cgi-bin' => Plack::App::CGIBin->new(
        root    => 'cgi-bin',
        exec_cb => sub { my $file = shift; $file =~ m!\.cgi$! and -x $file },
    )->to_app;
}
