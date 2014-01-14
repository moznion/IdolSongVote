#!/usr/bin/env carton exec -- perl
use strict;
use warnings;
use utf8;
use Text::Xslate;
use Encode;

print "Content-type: text/html \n\n";
print encode_utf8(Text::Xslate->new->render("tmpl/index.tx", {}));
