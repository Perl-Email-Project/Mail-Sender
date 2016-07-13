#!perl

use strict;
use warnings;
use Mail::Sender ();
use Try::Tiny qw(try catch);
use Test::More;
use Data::Dumper::Concise;
my $sender;
my $err;

%Mail::Sender::default = ();
try {
    $sender = Mail::Sender->new({on_errors => 'die',});
}
catch {
    $err = $_;
};
isa_ok($sender, 'Mail::Sender', 'new: Proper object instance');
is($err, undef, 'new: no errors');

$err = undef;
try {
    $sender = $sender->new({smtp=>'foo2,.bar2341324,.com'});
}
catch {
    $err = $_;
};
isa_ok($sender, 'Mail::Sender', 'new: bad smtp: failed instance');
like($err, qr/The SMTP server foo2,\.bar2341324,\.com was not found/, 'new: bad smtp: no errors');

done_testing();
