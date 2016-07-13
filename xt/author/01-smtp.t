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
$| = 1; # autoflush

plan skip_all => "fork not supported on this platform"
    unless $Config::Config{d_fork} || $Config::Config{d_pseudofork} ||
        (($^O eq 'MSWin32' || $^O eq 'NetWare') and
        $Config::Config{useithreads} and
        $Config::Config{ccflags} =~ /-DPERL_IMPLICIT_SYS/);

# First we make ourself a daemon in another process
my $D = shift || '';
if ($D eq 'daemon') {
    my $srv = IO::Socket::INET->new(Listen => 1);
    die("Cannot create listener on localhost: $!") unless $srv;
    print $srv->sockhost, ':', $srv->sockport, "\n";
    while (my $conn = $srv->accept) {
        my $smtp = Test::MS_SMTPWithAuth->new(socket => $conn);
        $smtp->process();
        $conn->close();
        # stop everything if kill:me was supplied via PLAIN
        last if $smtp->killme();
    }
}
else {
    my $perl = $Config{'perlpath'};
    $perl = $^X if $^O eq 'VMS' or -x $^X and $^X =~ m,^([a-z]:)?/,i;
    open(my $daemon, "$perl $0 daemon |") or plan(skip_all=>"Can't exec daemon: $!");

    my $line = <$daemon>;
    chomp $line;
    my ($host, $port) = split /:/, $line, 2;

    plan tests => 12;

    test_no_auth($host,$port);
    test_login_auth($host,$port);
    test_plain_auth($host,$port);
    # sending PLAIN user=kill, pass=me to the daemon stops it
    send_killme($host,$port);
}
exit();

sub test_no_auth {
    my ($host,$port) = @_;
    my $sender = Mail::Sender->new({
        on_errors => 'die',
        smtp => $host,
        port => $port,
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
    my ($host,$port) = @_;

    my $sender = Mail::Sender->new({
        auth => 'LOGIN',
        authid => 'who',
        authpwd => 'what',
        on_errors => 'die',
        smtp => $host,
        port => $port,
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
    my ($host,$port) = @_;
    my $sender = Mail::Sender->new({
        auth => 'PLAIN',
        authid => 'who',
        authpwd => 'what',
        on_errors => 'die',
        smtp => $host,
        port => $port,
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

sub send_killme {
    my ($host,$port) = @_;
    my $sender = Mail::Sender->new({
        auth => 'PLAIN',
        authid => 'kill',
        authpwd => 'me',
        on_errors => 'die',
        smtp => $host,
        port => $port,
        from => 'your@address.com'
    });
    isa_ok($sender, 'Mail::Sender', 'new: killme: got a proper instance');
    my $res;
    my $err;
    try {
        $res = $sender->MailMsg({to=>'foo@bar.com',msg=>"What's good?"});
    }
    catch {
        $err = $_;
    };
    ok($res, 'MailMsg: killme: got a proper response.');
    is($err, undef, 'MailMsg: killme: got no errors');
}
