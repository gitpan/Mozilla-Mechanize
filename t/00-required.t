#!/usr/bin/perl

# $CVSHeader: Mozilla-Mechanize/t/00-required.t,v 1.1.1.1 2005/09/25 00:09:34 slanning Exp $

use strict;
use warnings;

use Test::More tests => 1;

BEGIN { use_ok('Mozilla::Mechanize') }
