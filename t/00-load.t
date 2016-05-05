use strict;
use warnings;
use Test::More;

BEGIN {
    use_ok( 'Mail::Sender' ) || BAIL_OUT("Can't use the module.");
}

# check that we can do all static functions
can_ok('Mail::Sender', qw(enc_base64 enc_qp enc_plain enc_xtext),
    qw(ResetGMTdiff getusername),
    qw(HOSTNOTFOUND SOCKFAILED CONNFAILED SERVNOTAVAIL COMMERROR USERUNKNOWN),
    qw(TRANSFAILED TOEMPTY NOMSG NOFILE FILENOTFOUND NOTMULTIPART SITEERROR),
    qw(NOTCONNECTED NOSERVER NOFROMSPECIFIED INVALIDAUTH LOGINERROR UNKNOWNAUTH),
    qw(ALLRECIPIENTSBAD FILECANTREAD DEBUGFILE STARTTLS IO_SOCKET_SSL),
    qw(TLS_UNSUPPORTED_BY_ME TLS_UNSUPPORTED_BY_SERVER UNKNOWNENCODING),
    qw(GuessCType)
);

{
    # test username
    my $username = Mail::Sender::getusername();
    ok($username, 'getusername: found a username');
    is(Mail::Sender::getusername(), $username, 'getusername: called a second time for state');
}

{
    # test error functions
    my ($num, $err);

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::HOSTNOTFOUND('crappola');
    is($num, -1, 'HOSTNOTFOUND: proper number');
    is($err, 'The SMTP server crappola was not found', 'HOSTNOTFOUND: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::SOCKFAILED('');
    is($num, -2, 'SOCKFAILED: proper number');
    is($err, 'socket() failed: No such file or directory', 'SOCKFAILED: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::CONNFAILED('');
    is($num, -3, 'CONNFAILED: proper number');
    is($err, 'connect() failed: Input/output error', 'CONNFAILED: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::SERVNOTAVAIL('');
    is($num, -4, 'SERVNOTAVAIL: proper number');
    is($err, 'Service not available. Server closed the connection unexpectedly', 'SERVNOTAVAIL: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::SERVNOTAVAIL('crappola');
    is($num, -4, 'SERVNOTAVAIL: proper number');
    is($err, 'Service not available. Reply: crappola', 'SERVNOTAVAIL: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::COMMERROR('');
    is($num, -5, 'COMMERROR: proper number');
    is($err, 'No response from server', 'COMMERROR: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::COMMERROR('crappola');
    is($num, -5, 'COMMERROR: proper number');
    is($err, 'Server error: crappola', 'COMMERROR: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::USERUNKNOWN();
    is($num, -6, 'USERUNKNOWN: proper number');
    is($err, 'Local user "" unknown on host ""', 'USERUNKNOWN: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::USERUNKNOWN('crappola','crappola');
    is($num, -6, 'USERUNKNOWN: proper number');
    is($err, 'Local user "crappola" unknown on host "crappola"', 'USERUNKNOWN: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::USERUNKNOWN('crappola','crappola', 'Local user');
    is($num, -6, 'USERUNKNOWN: proper number');
    is($err, 'Local user "crappola" unknown on host "crappola"', 'USERUNKNOWN: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::USERUNKNOWN('crappola','crappola', 'crappola');
    is($num, -6, 'USERUNKNOWN: proper number');
    is($err, 'crappola for "crappola" on host "crappola"', 'USERUNKNOWN: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::USERUNKNOWN('crappola','crappola', '123 ');
    is($num, -6, 'USERUNKNOWN: proper number');
    is($err, 'Error for "crappola" on host "crappola"', 'USERUNKNOWN: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::TRANSFAILED();
    is($num, -7, 'TRANSFAILED: proper number');
    is($err, 'Transmission of message failed ()', 'TRANSFAILED: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::TRANSFAILED('crappola');
    is($num, -7, 'TRANSFAILED: proper number');
    is($err, 'Transmission of message failed (crappola)', 'TRANSFAILED: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::TOEMPTY();
    is($num, -8, 'TOEMPTY: proper number');
    is($err, 'Argument $to empty', 'TOEMPTY: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::NOMSG();
    is($num, -9, 'NOMSG: proper number');
    is($err, 'No message specified', 'NOMSG: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::NOFILE();
    is($num, -10, 'NOFILE: proper number');
    is($err, 'No file name specified', 'NOFILE: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::FILENOTFOUND();
    is($num, -11, 'FILENOTFOUND: proper number');
    is($err, 'File "" not found', 'FILENOTFOUND: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::FILENOTFOUND('crappola');
    is($num, -11, 'FILENOTFOUND: proper number');
    is($err, 'File "crappola" not found', 'FILENOTFOUND: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::NOTMULTIPART();
    is($num, -12, 'NOTMULTIPART: proper number');
    is($err, ' not available in singlepart mode', 'NOTMULTIPART: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::NOTMULTIPART('crappola');
    is($num, -12, 'NOTMULTIPART: proper number');
    is($err, 'crappola not available in singlepart mode', 'NOTMULTIPART: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::SITEERROR();
    is($num, -13, 'SITEERROR: proper number');
    is($err, 'Site specific error', 'SITEERROR: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::NOTCONNECTED();
    is($num, -14, 'NOTCONNECTED: proper number');
    is($err, 'Connection not established', 'NOTCONNECTED: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::NOSERVER();
    is($num, -15, 'NOSERVER: proper number');
    is($err, 'No SMTP server specified', 'NOSERVER: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::NOFROMSPECIFIED();
    is($num, -16, 'NOFROMSPECIFIED: proper number');
    is($err, 'No From: address specified', 'NOFROMSPECIFIED: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::INVALIDAUTH();
    is($num, -17, 'INVALIDAUTH: proper number');
    is($err, 'Authentication protocol  is not accepted by the server', 'INVALIDAUTH: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::INVALIDAUTH('crappola');
    is($num, -17, 'INVALIDAUTH: proper number');
    is($err, 'Authentication protocol crappola is not accepted by the server', 'INVALIDAUTH: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::INVALIDAUTH('crappola','crappola');
    is($num, -17, 'INVALIDAUTH: proper number');
    is($err, "Authentication protocol crappola is not accepted by the server,\nresponse: crappola", 'INVALIDAUTH: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::LOGINERROR();
    is($num, -18, 'LOGINERROR: proper number');
    is($err, 'Login not accepted', 'LOGINERROR: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::UNKNOWNAUTH();
    is($num, -19, 'UNKNOWNAUTH: proper number');
    is($err, 'Authentication protocol  is not implemented by Mail::Sender', 'UNKNOWNAUTH: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::UNKNOWNAUTH('crappola');
    is($num, -19, 'UNKNOWNAUTH: proper number');
    is($err, 'Authentication protocol crappola is not implemented by Mail::Sender', 'UNKNOWNAUTH: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::ALLRECIPIENTSBAD();
    is($num, -20, 'ALLRECIPIENTSBAD: proper number');
    is($err, 'All recipients are bad', 'ALLRECIPIENTSBAD: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::FILECANTREAD();
    is($num, -21, 'FILECANTREAD: proper number');
    is($err, 'File "" cannot be read: No such file or directory', 'FILECANTREAD: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::FILECANTREAD('crappola');
    is($num, -21, 'FILECANTREAD: proper number');
    is($err, 'File "crappola" cannot be read: No such file or directory', 'FILECANTREAD: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::DEBUGFILE();
    is($num, -22, 'DEBUGFILE: proper number');
    is($err, undef, 'DEBUGFILE: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::DEBUGFILE('crappola');
    is($num, -22, 'DEBUGFILE: proper number');
    is($err, 'crappola', 'DEBUGFILE: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::STARTTLS();
    is($num, -23, 'STARTTLS: proper number');
    is($err, 'STARTTLS failed:  ', 'STARTTLS: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::STARTTLS('crappola');
    is($num, -23, 'STARTTLS: proper number');
    is($err, 'STARTTLS failed: crappola ', 'STARTTLS: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::STARTTLS('crappola', 'crappola');
    is($num, -23, 'STARTTLS: proper number');
    is($err, 'STARTTLS failed: crappola crappola', 'STARTTLS: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::IO_SOCKET_SSL();
    is($num, -24, 'IO_SOCKET_SSL: proper number');
    is($err, 'IO::Socket::SSL->start_SSL failed: ', 'IO_SOCKET_SSL: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::IO_SOCKET_SSL('crappola');
    is($num, -24, 'IO_SOCKET_SSL: proper number');
    is($err, 'IO::Socket::SSL->start_SSL failed: crappola', 'IO_SOCKET_SSL: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::TLS_UNSUPPORTED_BY_ME();
    is($num, -25, 'TLS_UNSUPPORTED_BY_ME: proper number');
    is($err, 'TLS unsupported by the script: ', 'TLS_UNSUPPORTED_BY_ME: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::TLS_UNSUPPORTED_BY_ME('crappola');
    is($num, -25, 'TLS_UNSUPPORTED_BY_ME: proper number');
    is($err, 'TLS unsupported by the script: crappola', 'TLS_UNSUPPORTED_BY_ME: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::TLS_UNSUPPORTED_BY_SERVER();
    is($num, -26, 'TLS_UNSUPPORTED_BY_SERVER: proper number');
    is($err, 'TLS unsupported by server', 'TLS_UNSUPPORTED_BY_SERVER: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::UNKNOWNENCODING();
    is($num, -27, 'UNKNOWNENCODING: proper number');
    is($err, q(Unknown encoding ''), 'UNKNOWNENCODING: proper string');

    $num = undef; $err = undef;
    ($num,$err) = Mail::Sender::UNKNOWNENCODING('crappola');
    is($num, -27, 'UNKNOWNENCODING: proper number');
    is($err, q(Unknown encoding 'crappola'), 'UNKNOWNENCODING: proper string');

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
