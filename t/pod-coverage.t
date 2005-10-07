#!/usr/bin/perl -Tw
use Test::More;
eval "use Test::Pod::Coverage 1.04";
plan skip_all => 'POD coverage tests are intended for developers';
#plan skip_all => "Test::Pod::Coverage 1.04 required for testing POD coverage" if $@;
all_pod_coverage_ok();
