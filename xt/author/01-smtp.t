#!perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";

use Config;
use Data::Dumper::Concise;
use IO::Socket::INET;
use Test::MS_SMTPWithAuth;
use Test::More;
use Try::Tiny qw(try catch);

use Mail::Sender qw();


plan skip_all => "fork not supported on this platform"
    unless $Config::Config{d_fork} || $Config::Config{d_pseudofork} ||
        (($^O eq 'MSWin32' || $^O eq 'NetWare') and
        $Config::Config{useithreads} and
        $Config::Config{ccflags} =~ /-DPERL_IMPLICIT_SYS/);

my $srv = IO::Socket::INET->new(Listen => 1);
plan skip_all => "cannot create listener on localhost: $!" if ! $srv;

my $pid;
if (!defined($pid = fork())) {
    # fork returned undef, so failed
    plan skip_all => "cannot fork: $!";
}
elsif ($pid == 0) {
    # child process
    while (my $conn = $srv->accept) {
        my $smtp = Test::MS_SMTPWithAuth->new(socket => $conn);
        $smtp->set_callback(RCPT => \&validate_recipient);
        $smtp->set_callback(DATA => \&queue_message);
        $smtp->process();
        $conn->close();
    }
}
else {
    # parent process
    plan tests => 9;

    test_no_auth();
    test_login_auth();
    test_plain_auth();
    kill(-9,$pid);
}

sub test_no_auth {
    my $sender = Mail::Sender->new({
        on_errors => 'die',
        smtp => $srv->sockhost,
        port => $srv->sockport,
        from => 'your@address.com'
    });
    isa_ok($sender, 'Mail::Sender', 'new: got a proper instance');
    my $res;
    my $err;
    try {
        $res = $sender->MailMsg({to=>'foo@bar.com',msg=>"What's good?"});
    }
    catch {
        $err = $_;
    };
    ok($res, 'MailMsg: got a proper response.');
    is($err, undef, 'MailMsg: got no errors');
}

sub test_login_auth {
    my $sender = Mail::Sender->new({
        auth => 'LOGIN',
        authid => 'who',
        authpwd => 'what',
        on_errors => 'die',
        smtp => $srv->sockhost,
        port => $srv->sockport,
        from => 'your@address.com'
    });
    isa_ok($sender, 'Mail::Sender', 'new: got a proper instance');
    my $res;
    my $err;
    try {
        $res = $sender->MailMsg({to=>'foo@bar.com',msg=>"What's good?"});
    }
    catch {
        $err = $_;
    };
    ok($res, 'MailMsg: got a proper response.');
    is($err, undef, 'MailMsg: got no errors');
}

sub test_plain_auth {
    my $sender = Mail::Sender->new({
        auth => 'PLAIN',
        authid => 'who',
        authpwd => 'what',
        on_errors => 'die',
        smtp => $srv->sockhost,
        port => $srv->sockport,
        from => 'your@address.com'
    });
    isa_ok($sender, 'Mail::Sender', 'new: got a proper instance');
    my $res;
    my $err;
    try {
        $res = $sender->MailMsg({to=>'foo@bar.com',msg=>"What's good?"});
    }
    catch {
        $err = $_;
    };
    ok($res, 'MailMsg: got a proper response.');
    is($err, undef, 'MailMsg: got no errors');
}

sub validate_recipient {
    my ($session, $recipient) = @_;
    my $domain;
    if ($recipient =~ /@(.*?)>?\s*$/) {
        $domain = $1;
    }
    if (not defined $domain) {
        return(0, 513, 'Syntax error.');
    }
    unless ($domain eq 'bar.com') {
        return(0, 554, "$recipient: Recipient address rejected: Relay access denied");
    }
    return(1, 250, 'domain accepted');
}

sub queue_message {
    my($session, $data) = @_;

    my $sender = $session->get_sender();
    my @recipients = $session->get_recipients();

    return(0, 554, 'Error: no valid recipients')
        unless(@recipients);

    # my $msgid = add_queue($sender, \@recipients, $data) or return(0);

    return(1, 250, "message queued from $sender");
}
