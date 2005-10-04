#!/usr/bin/perl
use strict;
use warnings;

use URI::file;

use Test::More;
plan tests => 26;

use_ok 'Mozilla::Mechanize';

my $uri = URI::file->new_abs( "t/html/select.html" )->as_string;

my $moz = Mozilla::Mechanize->new();
isa_ok $moz, 'Mozilla::Mechanize';

ok $moz->get( $uri ), "Fetched $uri";

{
    my( $val1 ) = $moz->field( 'sel1' );
    is $val1, '1', "Preset for sel1 ($val1)";

    my @val2 = $moz->field( 'sel2' );
    is_deeply \@val2, [1, 2], "Preset for sel2 [@val2]";
}
# Test the select-one interface
{
    ok $moz->select( sel1 => '3' ), "Selected single value (3)";
    my( $val1 ) = $moz->field( 'sel1' );
    is $val1, 3, "select() set the single value ($val1)";
}
{
    my @newset = ( 5, 4 );
    ok $moz->select( sel1 => \@newset ), "select() with multiple values";
    my( $val1 ) = $moz->field( 'sel1' );
    local $" = ', ';
    is $val1, $newset[-1],
       "select(@newset) set the last of multivalues ($val1)";
}
{
    ok $moz->select( sel1 => { n => 3  } ),
       "select() with the { n => 3 } interface";
    my( $val1 ) = $moz->field( 'sel1' );
    is $val1, 3, "select() set the fifth item ($val1)";
}
{
    ok $moz->select( sel1 => { n => [ 5 ] } ),
       "select() with the { n => [ 5 ] } interface";
    my( $val1 ) = $moz->field( 'sel1' );
    is $val1, '5', "select() set the fifth item ($val1)";
}
# Test the select-multiple interface
local $" = ', ';
{
    ok $moz->select( sel2 => '3' ), "Selected single value (3)";
    my @val2 = $moz->field( 'sel2' );
    is_deeply \@val2, [ 3 ], "select() set the single value (@val2)";
}
{
    my @newset = ( 5, 4 );
    ok $moz->select( sel2 => \@newset ),
       "select( sel2 => [ @newset ] ) with multiple values";
    my @val2  = $moz->field( 'sel2' );
    is_deeply [sort {$a <=> $b} @val2], [sort {$a <=> $b} @newset],
       "select(@newset) set all multivalues (@val2)";
}
{
    ok $moz->select( sel2 => { n => 3 } ),
       "select() with the { n => 3 } interface";
    my @val2 = $moz->field( 'sel2' );
    is_deeply \@val2, [ 3 ], "select() set the fifth item (@val2)";
}
{
    ok $moz->select( sel2 => { n => [ 4, 5 ] } ),
       "select() with the { n => [ 4, 5 ] } interface";
    my @val2 = $moz->field( 'sel2' );
    is_deeply \@val2, [ 4, 5 ], "select() set the fifth item (@val2)";
}

ok $moz->select( sel1 => 1 ), "select(sel1 => 1)";
ok $moz->select( sel2 => [2,3] ), "select(sel2 => [2,3])";
ok $moz->submit, "submit the form";

my $ret_url = $moz->uri;
like $ret_url, qr/sel1=1/, "return contains 'sel1=1'";
like $ret_url, qr/sel2=2&sel2=3/, "return contains 'sel2=2&sel2=3'";

$moz->close();
