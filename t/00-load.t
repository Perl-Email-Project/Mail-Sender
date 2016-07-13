#!perl
use strict;
use warnings;
use Test::More;

BEGIN {
    use_ok( 'Mail::Sender' ) || BAIL_OUT("Can't use the module.");
}

# check that we can do all static functions
can_ok('Mail::Sender',
    qw(enc_base64 enc_qp enc_plain enc_xtext),
    qw(ResetGMTdiff GuessCType getusername),
);

{
    # encoding
    isa_ok(Mail::Sender::enc_base64(), 'CODE', 'enc_base64: empty call gets subref');
    isa_ok(Mail::Sender::enc_base64("UTF-8", "foo"), 'CODE', 'enc_base64: got a sub ref back');
    isa_ok(Mail::Sender::enc_qp(), 'CODE', 'enc_base64: empty call - got a sub ref back');
    isa_ok(Mail::Sender::enc_qp("UTF-8", "foo"), 'CODE', 'enc_base64: got a sub ref back');
    isa_ok(Mail::Sender::enc_plain(), 'CODE', 'enc_base64: empty call - got a sub ref back');
    isa_ok(Mail::Sender::enc_plain("UTF-8", "foo"), 'CODE', 'enc_base64: got a sub ref back');
    is(Mail::Sender::enc_xtext("foo"), 'foo', 'enc_base64: got encoded content');
}

{
    # test username
    my $username = Mail::Sender::getusername();
    ok($username, 'getusername: found a username');
    is(Mail::Sender::getusername(), $username, 'getusername: called a second time for state');
}

{
    # test GMT offset
    my $diff = Mail::Sender::ResetGMTdiff();
    like($diff, qr/^[+-][0-9]+$/, 'ResetGMTdiff: properly set');
    is($diff, $Mail::Sender::GMTdiff, 'ResetGMTdiff: properly set');
    ok($Mail::Sender::GMTdiff, 'ResetGMTdiff: properly set');
}

{
    # GuessCType
    my $type = Mail::Sender::GuessCType();
    is($type, 'application/octet-stream', 'GuessCType: empty call');

    $type = Mail::Sender::GuessCType('');
    is($type, 'application/octet-stream', 'GuessCType: empty string');

    $type = Mail::Sender::GuessCType('foo.unknownsomething');
    is($type, 'application/octet-stream', 'GuessCType: unknown extension');

    $type = Mail::Sender::GuessCType('foo.gif');
    is($type, 'image/gif', 'GuessCType: gif lowercase extension');

    $type = Mail::Sender::GuessCType('foo.gIf');
    is($type, 'image/gif', 'GuessCType: gif multicase extension');

    $type = Mail::Sender::GuessCType('foo.GIF');
    is($type, 'image/gif', 'GuessCType: gif uppercase extension');

    # Add a type
    $Mail::Sender::CTypes{SUPERSPECIAL} = 'text/super';
    $type = Mail::Sender::GuessCType('foo.superspecial');
    is($type, 'text/super', 'GuessCType: superspecial added MIME type');
}

done_testing();
