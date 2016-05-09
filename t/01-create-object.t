use strict;
use warnings;
use Mail::Sender;
use Test::More;

my $sender = Mail::Sender->new({tls_allowed => 0});
isa_ok($sender, 'Mail::Sender', 'new: Got a proper object instance');

SKIP: {
    skip "No SMTP server set in the default config", 3 unless $sender->{smtp};

    ok( $sender->{smtpaddr}, "smtpaddr defined");

    my $res = $sender->Connect();
    ok( (ref($res) or $res >=0), "->Connect()")
        or do { diag("Error: $Mail::Sender::Error"); exit};

    ok( ($sender->{'supports'} and ref($sender->{'supports'}) eq 'HASH'), "found out what extensions the server supports");
};

done_testing();
