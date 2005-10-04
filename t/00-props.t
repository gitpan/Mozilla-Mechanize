#!/usr/bin/perl
use strict;
use warnings;

use Test::More;
plan tests => 11;

use_ok 'Mozilla::Mechanize';
diag "Testing Mozilla::Mechanize $Mozilla::Mechanize::VERSION";

isa_ok my $moz = Mozilla::Mechanize->new(),
  "Mozilla::Mechanize";


SKIP: {
    skip "set_property isn't working yet", 9;


my $agent = $moz->agent;
isa_ok $moz->agent, "Mozilla::Mechanize::Browser";
my $df_vis = $ENV{WIM_VISIBLE} || 0;
is $agent->{visible}, $df_vis, "Visible-attrib";

SKIP: {
    # XXX:
    skip "Graphical system not available?", 1
        unless $ENV{LOGONSERVER} && !$ENV{SSH_TTY};
    $moz->set_property( visible => 1 );
    is $agent->{visible}, 1, "Visible!";
}

$moz->set_property( fullscreen => 1 );
is $agent->{fullscreen}, 1, "Fullscreen!";

$moz->set_property( fullscreen => 0 );
my %save;
for my $prop (qw( top left width height )) {
    $save{ $prop } = $agent->{ $prop };
}
my $new = { top => 0, left => 0, width => 640, height => 480 };
$moz->set_property( $new );

for my $prop (keys %$new) {
    is $agent->{ $prop }, $new->{ $prop }, "$prop => $new->{ $prop }";
}

is $moz->set_property, '', "No properties set";

$moz->set_property( visible => $df_vis, %save );

$moz->close;

}  # TODO
