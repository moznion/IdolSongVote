#!/usr/bin/env carton exec -- perl
use strict;
use warnings;
use utf8;
use Text::Xslate;
use Encode;

print "Content-Type: text/html; charset=UTF-8 \n\n";
print encode_utf8(Text::Xslate->new->render("tmpl/index.tx", {}));
