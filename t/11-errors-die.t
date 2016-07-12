#!perl

use strict;
use warnings;
use Mail::Sender ();
use Try::Tiny qw(try catch);
use Test::More;

my $sender = Mail::Sender->new({on_errors => 'die',});

done_testing();
