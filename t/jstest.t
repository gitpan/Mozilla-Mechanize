#!/usr/bin/perl
use strict;
use warnings;

use URI::file;

use Test::More;
plan tests => 4;

use_ok 'Mozilla::Mechanize';

my $uri = URI::file->new_abs( "t/html/jstest.html" )->as_string;
my $new_uri = URI::file->new_abs( "t/html/jstestok.html" )->as_string;

my $moz = Mozilla::Mechanize->new();
isa_ok $moz, 'Mozilla::Mechanize';

$moz->get( $uri );
is $moz->title, 'JS Redirection Success', "Right title()";

# is this a IE glitch?
$new_uri =~ s|^file:///?([a-z]):|file:///\U$1:|i;
# This Windows, case-insensitive
is $moz->uri, $new_uri, "Got the new uri()";

$moz->close();
