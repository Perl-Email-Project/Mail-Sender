# NAME

Mail::Sender - module for sending mails with attachments through an SMTP server

# WAIT!  STOP RIGHT THERE!

[Mail::Sender](https://metacpan.org/pod/Mail::Sender) is going away... well, not really, but it's being officially marked as
"out of favor".  [Email::Sender](https://metacpan.org/pod/Email::Sender) is the go-to choice when you need to send Email
from Perl.  Go there, be happy!

# SYNOPSIS

    use Mail::Sender;

    my $sender = Mail::Sender->new({
      smtp => 'mail.yourdomain.com',
      from => 'your@address.com'
    });
    $sender->MailFile({
      to => 'some@address.com',
      subject => 'Here is the file',
      msg => "I'm sending you the list you wanted.",
      file => 'filename.txt'
    });

# DESCRIPTION

[Mail::Sender](https://metacpan.org/pod/Mail::Sender) provides an object-oriented interface to sending mails. It directly connects to the mail server using [IO::Socket](https://metacpan.org/pod/IO::Socket).

[Mail::Sender](https://metacpan.org/pod/Mail::Sender) is going away... well, not really, but it's being officially marked as
"out of favor".  [Email::Sender](https://metacpan.org/pod/Email::Sender) is the go-to choice when you need to send Email
from Perl.  Go there, be happy!

# ATTRIBUTES

[Mail::Sender](https://metacpan.org/pod/Mail::Sender) implements the following attributes.

\* Please note that altering an attribute after object creation is best
handled with creating a copy using `$sender = $sender->new({attribute => 'value'})`.
To obtain the current value of an attribute, break all the rules and reach in
there! `my $val = $sender->{attribute};`

## auth

    # mutating single attributes could get costly!
    $sender = $sender->new({auth => 'PLAIN'});
    my $auth = $sender->{auth}; # reach in to grab

The SMTP authentication protocol to use to login to the server currently the
only ones supported are `LOGIN`, `PLAIN`, `CRAM-MD5` and `NTLM`.
Some protocols have module dependencies. `CRAM-MD5` depends on [Digest::HMAC\_MD5](https://metacpan.org/pod/Digest::HMAC_MD5)
and `NTLM` on [Authen::NTLM](https://metacpan.org/pod/Authen::NTLM).

You may add support for other authentication protocols yourself.

## auth\_encoded

    # mutating single attributes could get costly!
    $sender = $sender->new({auth_encoded => 1});
    my $auth_enc = $sender->{auth_encoded}; # reach in to grab

If set to a true value, [Mail::Sender](https://metacpan.org/pod/Mail::Sender) attempts to use TLS (encrypted connection)
whenever the server supports it and you have [IO::Socket::SSL](https://metacpan.org/pod/IO::Socket::SSL) and [Net::SSLeay](https://metacpan.org/pod/Net::SSLeay).

The default value of this option is true! This means that if [Mail::Sender](https://metacpan.org/pod/Mail::Sender)
can send the data encrypted, it will.

## authdomain

    # mutating single attributes could get costly!
    $sender = $sender->new({authdomain => 'bar.com'});
    my $domain = $sender->{authdomain}; # reach in to grab

The domain name; used optionally by the `NTLM` authentication. Other authentication
protocols may use other options as well. They should all start with `auth` though.

## authid

    # mutating single attributes could get costly!
    $sender = $sender->new({authid => 'username'});
    my $username = $sender->{authid}; # reach in to grab

The username used to login to the server.

## authpwd

    # mutating single attributes could get costly!
    $sender = $sender->new({authpwd => 'password'});
    my $password = $sender->{authpwd}; # reach in to grab

The password used to login to the server.

## bcc

    # mutating single attributes could get costly!
    $sender = $sender->new({bcc => 'foo@bar.com'});
    $sender = $sender->new({bcc => 'foo@bar.com, bar@baz.com'});
    $sender = $sender->new({bcc => ['foo@bar.com', 'bar@baz.com']});
    my $bcc = $sender->{bcc}; # reach in to grab

Send a blind carbon copy to these addresses.

## boundary

    # mutating single attributes could get costly!
    $sender = $sender->new({boundary => '--'});
    my $boundary = $sender->{boundary}; # reach in to grab

The message boundary. You usually do not have to change this, it might only come in handy if you need
to attach a multi-part mail created by [Mail::Sender](https://metacpan.org/pod/Mail::Sender) to your message as a
single part. Even in that case any problems are unlikely.

## cc

    # mutating single attributes could get costly!
    $sender = $sender->new({cc => 'foo@bar.com'});
    $sender = $sender->new({cc => 'foo@bar.com, bar@baz.com'});
    $sender = $sender->new({cc => ['foo@bar.com', 'bar@baz.com']});
    my $cc = $sender->{cc}; # reach in to grab

Send a carbon copy to these addresses.

## charset

    # mutating single attributes could get costly!
    $sender = $sender->new({charset => 'UTF-8'});
    my $charset = $sender->{charset}; # reach in to grab

The charset of the single part message or the body of the multi-part one.

## client

    # mutating single attributes could get costly!
    $sender = $sender->new({client => 'localhost.localdomain'});
    my $client = $sender->{client}; # reach in to grab

The name of the client computer.

During the connection you send the mail server your computer's name. By default
[Mail::Sender](https://metacpan.org/pod/Mail::Sender) sends `(gethostbyname 'localhost')[0]`. If that is not the
address your needs, you can specify a different one.

## confirm

    # only delivery, to the 'from' address
    $sender = $sender->new({confirm => 'delivery'});
    # only reading, to the 'from' address
    $sender = $sender->new({confirm => 'reading'});
    # both: to the 'from' address
    $sender = $sender->new({confirm => 'delivery, reading'});
    # delivery: to specified address
    $sender = $sender->new({confirm => 'delivery: my.other@address.com'});
    my $confirm = $sender->{confirm}; # reach in to grab

Whether you want to request reading or delivery confirmations and to what addresses.

Keep in mind that confirmations are not guaranteed to work. Some servers/mail
clients do not support this feature and some users/admins may have disabled it.
So it's possible that your mail was delivered and read, but you won't get any
confirmation!

## createmessageid

    # mutating single attributes could get costly!
    $sender = $sender->new({createmessageid => sub {
        my $from = shift;
        my ($sec, $min, $hour, $mday, $mon, $year) = gmtime(time);
        $mon++;
        $year += 1900;

        return sprintf "<%04d%02d%02d_%02d%02d%02d_%06d.%s>", $year, $mon, $mday,
            $hour, $min, $sec, rand(100000), $from;
    }});
    my $cm_id = $sender->{createmessageid}; # reach in to grab

This option allows you to overwrite the function that generates the message
IDs for the emails. The option gets the "pure" sender's address as it's only
parameter and is supposed to return a string. See the ["MessageID" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#MessageID)
method.

If you want to specify a message id you can also use the `messageid` parameter
for the ["Open" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#Open), ["OpenMultipart" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#OpenMultipart),
["MailMsg" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#MailMsg) or ["MailFile" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#MailFile) methods.

## ctype

    # mutating single attributes could get costly!
    $sender = $sender->new({ctype => 'text/plain'});
    my $type = $sender->{ctype}; # reach in to grab

The content type of a single part message or the body of the multi-part one.

Please do not confuse these two. The ["multipart" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#multipart) parameter is
used to specify the overall content type of a multi-part message (for example any
HTML document with inlined images) while `ctype` is an ordinary content type
for a single part message or the body of a multi-part message.

## debug

    # mutating single attributes could get costly!
    $sender = $sender->new({debug => '/path/to/debug/file.txt'});
    $sender = $sender->new({debug => $file_handle});
    my $debug = $sender->{debug}; # reach in to grab

All the conversation with the server will be logged to that file or handle.
All lines in the file should end with `CRLF` (the Windows and Internet format).

If you pass the path to the log file, [Mail::Sender](https://metacpan.org/pod/Mail::Sender) will overwrite it.
If you want to append to the file, you have to open it yourself and pass the
filehandle:

    open my $fh, '>>', '/path/to/file.txt' or die "Can't open: $!";
    my $sender = Mail::Sender->new({
        debug => $fh,
    });

## debug\_level

    # mutating single attributes could get costly!
    $sender = $sender->new({debug_level => 1});
    # 1: only log server communication, skip all msg data
    # 2: log server comm. and message headers
    # 3: log server comm., message and part headers
    # 4: log everything (default behavior)
    my $level = $sender->{debug_level}; # reach in to grab

Only taken into account if the `debug` attribute is specified.

## encoding

    # mutating single attributes could get costly!
    $sender = $sender->new({encoding => 'Quoted-printable'});
    my $encoding = $sender->{encoding}; # reach in to grab

Encoding of a single part message or the body of a multi-part message.

If the text of the message contains some extended characters or very long lines,
you should use `encoding => 'Quoted-printable'` in the call to ["Open" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#Open),
["OpenMultipart" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#OpenMultipart), ["MailMsg" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#MailMsg) or ["MailFile" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#MailFile).

If you use some encoding you should either use ["SendEnc" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#SendEnc) or
encode the data yourself!

## ESMPT

    # mutating single attributes could get costly!
    $sender = $sender->new({
        ESMTP => {
            NOTIFY => 'SUCCESS,FAILURE,DELAY',
            RET => 'HDRS',
            ORCPT => 'rfc822;my.other@address.com',
            ENVID => 'iuhsdfobwoe8t237',
        },
    });
    my $esmtp = $sender->{ESMTP}; # reach in to grab

This option contains data for SMTP extensions. For example, it allows you to
request delivery status notifications according to [RFC1891](https://tools.ietf.org/html/rfc1891).
If the SMTP server you connect to doesn't support this extension, the options
will be ignored.  You do not need to worry about encoding the `ORCPT` or `ENVID`
parameters.

- `ENVID` - Used to propagate an identifier for this message transmission
envelope, which is also known to the sender and will, if present, be returned
in any Delivery Status Notifications issued for this transmission.
- `NOTIFY` - To specify the conditions under which a delivery status
notification should be generated. Should be either `NEVER` or a comma-separated
list of `SUCCESS`, `FAILURE` and `DELAY`.
- `ORCPT` - Used to convey the original (sender-specified) recipient address.
- `RET` - To request that Delivery Status Notifications containing an indication
of delivery failure either return the entire contents of a message or only the
message headers. Must be either `FULL` or `HDRS`.

## fake\_cc

    # mutating single attributes could get costly!
    $sender = $sender->new({fake_cc => 'foo@bar.com'});
    my $fake_cc = $sender->{fake_cc}; # reach in to grab

The address that will be shown in headers. If not specified, the ["cc" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#cc) attribute will be used.

## fake\_from

    # mutating single attributes could get costly!
    $sender = $sender->new({fake_from => 'foo@bar.com'});
    my $fake_from = $sender->{fake_from}; # reach in to grab

The address that will be shown in headers. If not specified, the ["from" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#from) attribute will be used.

## fake\_to

    # mutating single attributes could get costly!
    $sender = $sender->new({fake_to => 'foo@bar.com'});
    my $fake_to = $sender->{fake_to}; # reach in to grab

The recipient's address that will be shown in headers. If not specified, the ["to" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#to) attribute will be used.

If the list of addresses you want to send your message to is long or if you do
not want the recipients to see each other's address set the ["fake\_to" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#fake_to) parameter to
some informative, yet bogus, address or to the address of your mailing/distribution list.

## from

    # mutating single attributes could get costly!
    $sender = $sender->new({from => 'foo@bar.com'});
    my $from = $sender->{from}; # reach in to grab

The sender's email address.

## headers

    # mutating single attributes could get costly!
    $sender = $sender->new({headers => 'Content-Type: text/plain'});
    $sender = $sender->new({headers => {'Content-Type' => 'text/plain'}});
    my $headers = $sender->{headers}; # reach in to grab

You may use this parameter to add custom headers into the message.
The parameter may be either a string containing the headers in the right format
or a hash containing the headers and their values.

## keepconnection

    # mutating single attributes could get costly!
    $sender = $sender->new({keepconnection => 1);
    $sender = $sender->new({keepconnection => 0});
    my $keepcon = $sender->{keepconnection}; # reach in to grab

If set to a true value, it causes the [Mail::Sender](https://metacpan.org/pod/Mail::Sender) to keep the connection
open for several messages. The connection will be closed if you call the
["Close" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#Close) method with a true value or if you call
["Open" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#Open), ["OpenMultipart" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#OpenMultipart), ["MailMsg" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#MailMsg)
or ["MailFile" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#MailFile) with the `smtp` attribute. This means that if you
want the object to keep the connection, you should pass the `smtp` either to
["new" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#new) or only to the first ["Open" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#Open),
["OpenMultipart" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#OpenMultipart), ["MailMsg" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#MailMsg)
or ["MailFile" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#MailFile)!

## multipart

    # mutating single attributes could get costly!
    $sender = $sender->new({multipart => 'Mixed'});
    my $multi = $sender->{multipart}; # reach in to grab

The `MIME` subtype for the whole message (`Mixed/Related/Alternative`). You may
need to change this setting if you want to send an HTML body with some inline
images, or if you want to post the message in plain text as well as HTML
(alternative).

## on\_errors

    # mutating single attributes could get costly!
    $sender = $sender->new({on_errors => 'undef'}); # return undef on error
    $sender = $sender->new({on_errors => 'die'}); # raise an exception
    $sender = $sender->new({on_errors => 'code'}); # return the negative error code (default)
    # -1 = $smtphost unknown
    # -2 = socket() failed
    # -3 = connect() failed
    # -4 = service not available
    # -5 = unspecified communication error
    # -6 = local user $to unknown on host $smtp
    # -7 = transmission of message failed
    # -8 = argument $to empty
    # -9 = no message specified in call to MailMsg or MailFile
    # -10 = no file name specified in call to SendFile or MailFile
    # -11 = file not found
    # -12 = not available in singlepart mode
    # -13 = site specific error
    # -14 = connection not established. Did you mean MailFile instead of SendFile?
    # -15 = no SMTP server specified
    # -16 = no From: address specified
    # -17 = authentication protocol not accepted by the server
    # -18 = login not accepted
    # -19 = authentication protocol is not implemented
    # -20 = all recipients were rejected by the server
    # -21 = file specified as an attachment cannot be read
    # -22 = failed to open the specified debug file for writing
    # -23 = STARTTLS failed (for SSL or TLS encrypted connections)
    # -24 = IO::Socket::SSL->start_SSL failed
    # -25 = TLS required by the specified options, but the required modules are not available. Need IO::Socket::SSL and Net::SSLeay
    # -26 = TLS required by the specified options, but the server doesn't support it
    # -27 = unknown encoding specified for the mail body, part or attachment. Only base64, quoted-printable, 7bit and 8bit supported.
    my $on_errors = $sender->{on_errors}; # reach in to grab
    say $Mail::Sender::Error; # contains a textual description of last error.

This option allows you to affect the way [Mail::Sender](https://metacpan.org/pod/Mail::Sender) reports errors.
All methods return the `$sender` object if they succeed.

`$Mail::Sender::Error` `$sender->{'error'}` and `$sender->{'error_msg'}`
are set in all cases.

## port

    # mutating single attributes could get costly!
    $sender = $sender->new({port => 25});
    my $port = $sender->{port}; # reach in to grab

The TCP/IP port used form the connection. By default `getservbyname('smtp', 'tcp')||25`.
You should only need to use this option if your mail server waits on a nonstandard port.

## priority

    # mutating single attributes could get costly!
    $sender = $sender->new({priority => 1});
    # 1. highest
    # 2. high
    # 3. normal
    # 4. low
    # 5. lowest
    my $priority = $sender->{priority}; # reach in to grab

The message priority number.

## replyto

    # mutating single attributes could get costly!
    $sender = $sender->new({replyto => 'foo@bar.com'});
    my $replyto = $sender->{replyto}; # reach in to grab

The reply to address.

## skip\_bad\_recipients

    # mutating single attributes could get costly!
    $sender = $sender->new({skip_bad_recipients => 1);
    $sender = $sender->new({skip_bad_recipients => 0});
    my $skip = $sender->{skip_bad_recipients}; # reach in to grab

If this option is set to false, or not specified, then [Mail::Sender](https://metacpan.org/pod/Mail::Sender) stops
trying to send a message as soon as the first recipient's address fails. If it
is set to a true value, [Mail::Sender](https://metacpan.org/pod/Mail::Sender) skips the bad addresses and tries to
send the message at least to the good ones. If all addresses are rejected by the
server, it reports a `All recipients were rejected` message.

If any addresses were skipped, the `$sender->{'skipped_recipients'}` will
be a reference to a hash containing the failed address and the server's response.

## smtp

    # mutating single attributes could get costly!
    $sender = $sender->new({smtp => 'smtp.bar.com'});
    my $smtp = $sender->{smtp}; # reach in to grab

The IP address or domain of your SMTP server.

## ssl\_...

The `ssl_version`, `ssl_verify_mode`, `ssl_ca_path`, `ssl_ca_file`,
`ssl_verifycb_name`, `ssl_verifycn_schema` and `ssl_hostname` options (if
specified) are passed to ["start\_SSL" in IO::Socket::SSL](https://metacpan.org/pod/IO::Socket::SSL#start_SSL). The default version is
`TLSv1` and verify mode is `IO::Socket::SSL::SSL_VERIFY_NONE`.

If you change the `ssl_verify_mode` to `SSL_VERIFY_PEER`, you may need to
specify the `ssl_ca_file`. If you have [Mozilla::CA](https://metacpan.org/pod/Mozilla::CA) installed, then setting
it to `Mozilla::CA::SSL_ca_file()` may help.

## subject

    # mutating single attributes could get costly!
    $sender = $sender->new({subject => 'An email is coming!'});
    my $subject = $sender->{subject}; # reach in to grab

The subject of the message.

## tls\_allowed

    # mutating single attributes could get costly!
    $sender = $sender->new({tls_allowed => 1}); # true, default
    $sender = $sender->new({tls_allowed => 0}); # false
    my $tls = $sender->{tls_allowed}; # reach in to grab

If set to a true value, [Mail::Sender](https://metacpan.org/pod/Mail::Sender) will attempt to use TLS (encrypted
connection) whenever the server supports it.  This requires that you have
[IO::Socket::SSL](https://metacpan.org/pod/IO::Socket::SSL) and [Net::SSLeay](https://metacpan.org/pod/Net::SSLeay).

## tls\_required

    # mutating single attributes could get costly!
    $sender = $sender->new({tls_required => 1}); # true, require TLS encryption
    $sender = $sender->new({tls_required => 0}); # false, plain. default
    my $required = $sender->{tls_required};

If you set this option to a true value, the module will fail if it's unable to use TLS.

## to

    # mutating single attributes could get costly!
    $sender = $sender->new({to => 'foo@bar.com'});
    $sender = $sender->new({to => 'foo@bar.com, bar@baz.com'});
    $sender = $sender->new({to => ['foo@bar.com', 'bar@baz.com']});
    my $to = $sender->{to}; # reach in to grab

The recipient's addresses. This parameter may be either a comma separated list
of email addresses or a reference to a list of addresses.

# METHODS

[Mail::Sender](https://metacpan.org/pod/Mail::Sender) implements the following methods.

## Attach

    # set parameters in an ordered list
    # -- description, ctype, encoding, disposition, file(s)
    $sender = $sender->Attach(
        'title', 'application/octet-stream', 'Base64', 'attachment; filename=*', '/file.txt'
    );
    $sender = $sender->Attach(
        'title', 'application/octet-stream', 'Base64', 'attachment; filename=*',
        ['/file.txt', '/file2.txt']
    );
    # OR use a hashref
    $sender = $sender->Attach({
        description => 'some title',
        charset => 'US-ASCII', # default
        encoding => 'Base64', # default
        ctype => 'application/octet-stream', # default
        disposition => 'attachment; filename=*', # default
        file => ['/file1.txt'], # file names
        content_id => '#', # for auto-increment number, or * for filename
    });

Sends a file as a separate part of the mail message. Only in multi-part mode.

## Body

    # set parameters in an ordered list
    # -- charset, encoding, content-type
    $sender = $sender->Body('US-ASCII', '7BIT', 'text/plain');
    # OR use a hashref
    $sender = $sender->Body({
        charset => 'US-ASCII', # default
        encoding => '7BIT', # default
        ctype => 'text/plain', # default
        msg => '',
    });

Sends the head of the multi-part message body. You can specify the charset and the encoding.

## Cancel

    $sender = $sender->Cancel;

Cancel an opened message.

["SendFile" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#SendFile) and other methods may set `$sender->{'error'}`.
In that case "undef $sender" calls `$sender->Cancel` not `$sender->Close`!!!

## ClearErrors

    $sender->ClearErrors();

Make the various error variables `undef`.

## Close

    $sender->Close();
    $sender->Close(1); # force override keepconnection

Close and send the email message. If you pass a true value to the method the
connection will be closed even if the `keepconnection` was specified. You
should only keep the connection open if you plan to send another message
immediately. And you should not keep it open for hundreds of emails even if you
do send them all in a row.

This method should be called automatically when destructing the object, but you
should not rely on it. If you want to be sure your message WAS processed by the
server, you SHOULD call ["Close" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#Close) explicitly.

## Connect

This method gets called automatically. Do not call it yourself.

## Connected

    my $bool = $sender->Connected();

Returns an `undef` or true value to let you know if you're connected to the
mail server.

## EndPart

    $sender = $sender->EndPart($ctype);

Closes a multi-part part.

If the `$ctype` is not present or evaluates to false, only the current
SIMPLE part is closed! Don't do that unless you are really sure you know what
you are doing.

It's best to always pass to the `->EndPart()` the content type of the
corresponding `->Part()`.

## GetHandle

    $sender->Open({...});
    my $handle = $sender->GetHandle();
    $handle->print("Hello world.\n");
    my ($mday,$mon,$year) = (localtime())[3,4,5];
    $handle->print(sprintf("Today is %04d/%02d/%02d.", $year+1900, $mon+1, $mday));
    close $handle;

Returns a file handle to which you can print the message or file to attach. The
data you print to this handle will be encoded as necessary. Closing this handle
closes either the message (for single part messages) or the part.

## MailFile

    # set parameters in an ordered list
    # -- from, reply-to, to, smtp, subject, headers, message, files(s)
    $sender = $sender->MailFile('from@foo.com','reply-to@bar.com','to@baz.com')
    # OR use a hashref -- see the attributes section for a
    # list of appropriate parameters.
    $sender = $sender->MailFile({file => ['/file1','/file2'], msg => "Message"});

Sends one or more files by mail. If a message in `$sender` is opened, it gets closed and a
new message is created and sent. `$sender` is then closed.

The `file` parameter may be a string file name, a comma-separated list of
filenames, or an array reference of filenames.

Keep in mind that parameters like `ctype`, `charset` and `encoding` will be
used for the attached file, not the body of the message. If you want to specify
those parameters for the body, you have to use `b_ctype`, `b_charset` and
`b_encoding`.

## MailMsg

    # set parameters in an ordered list
    # -- from, reply-to, to, smtp, subject, headers, message
    $sender = $sender->MailMsg('from@foo.com','reply-to@bar.com','to@baz.com')
    # OR use a hashref -- see the attributes section for a
    # list of appropriate parameters.
    $sender = $sender->MailMsg({from => "foo@bar.com", msg => "Message"});

Sends a message. If a message in `$sender` is opened, it gets closed and a
new message is created and sent. `$sender` is then closed.

## new

    # Create a new sender instance with only the 'from' address
    my $sender = Mail::Sender->new('from_address@bar.com');
    # Create a new sender with any attribute above set in a hashref
    my $sender = Mail::Sender->new({attribute => 'value', });
    # Create a new sender as a copy of an existing one
    my $copy = $sender->new({another_attr => 'bar',});

Prepares a sender. Any attribute can be set during instance creation.  This doesn't
start any connection to the server. You have to use `$sender->Open` or
`$sender->OpenMultipart` to start talking to the server.

The attributes are used in subsequent calls to `$sender->Open` and
`$sender->OpenMultipart`. Each such call changes the saved variables. You
can set `smtp`, `from` and other options here and then use the info in all messages.

## Open

    # set parameters in an ordered list
    # -- from, reply-to, to, smtp, subject, headers
    $sender = $sender->Open('from@foo.com','reply-to@bar.com','to@baz.com');
    # OR use a hashref -- see the attributes section for a
    # list of appropriate parameters.
    $sender = $sender->Open({to=>'to@baz.com', subject=>'Incoming!!!'});

Opens a new message. The only additional parameter that may not be specified
directly in ["new" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#new) is `messageid`. If you set this option, the
message will be sent with that `Message-ID`, otherwise a new Message ID will
be generated out of the sender's address, current date+time and a random number
(or by the function you specified in the `createmessageid` attribute).

After the message is sent `$sender->{messageid}` will contain the Message-ID
with which the message was sent.

## OpenMultipart

    # set parameters in an ordered list
    # -- from, reply-to, to, smtp, subject, headers, boundary
    $sender = $sender->OpenMultipart('from@foo.com','reply-to@bar.com');
    # OR use a hashref -- see the attributes section for a
    # list of appropriate parameters.
    $sender = $sender->OpenMultipart({to=>'to@baz.com', subject=>'Incoming!!!'});

Opens a multipart message.

## Part

    # set parameters in an ordered list
    # -- description, ctype, encoding, disposition, content_id, Message
    $sender = $sender->Part(
        'something', 'text/plain', '7BIT', 'attachment; filename="send.pl"'
    );
    # OR use a hashref -- see the attributes section for a
    # list of appropriate parameters.
    $sender = $sender->Part({
        description => "desc",
        ctype => "application/octet-stream", # default
        encoding => '7BIT', # default
        disposition => 'attachment', # default
        content_id => '#', # for auto-increment number, or * for filename
        msg => '', # You don't have to specify here, you may use SendEnc()
                    # to add content to the part.
    });

Prints a part header for the multipart message and (if specified) the contents.

## print

An alias for ["SendEnc" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#SendEnc).

## QueryAuthProtocols

    my @protocols = $sender->QueryAuthProtocols();
    my @protocols = $sender->QueryAuthProtocols( $smtpserver);

Queries the server specified in the attributes or in the parameter to this
method for the authentication protocols it supports.

## Send

    $sender = $sender->Send(@strings);

Prints the strings to the socket. It doesn't add any line terminations or encoding.
You should use `\r\n` as the end-of-line!

UNLESS YOU ARE ABSOLUTELY SURE YOU KNOW WHAT YOU ARE DOING YOU SHOULD USE
["SendEnc" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#SendEnc) INSTEAD!

## SendEnc

    $sender = $sender->SendEnc(@strings);

Prints the bytes to the socket. It doesn't add any line terminations. Encodes
the text using the selected encoding: `none | Base64 | Quoted-printable`.
You should use `\r\n` as the end-of-line!

## SendEx

    $sender = $sender->SendEx(@strings);

Prints the strings to the socket. Doesn't add any end-of-line characters.
Changes all end-of-lines to `\r\n`. Doesn't encode the data!

UNLESS YOU ARE ABSOLUTELY SURE YOU KNOW WHAT YOU ARE DOING YOU SHOULD USE
["SendEnc" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#SendEnc) INSTEAD!

## SendFile

Alias for ["Attach" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#Attach)

## SendLine

    $sender = $sender->SendLine(@strings);

Prints the strings to the socket. Each byte string is terminated by `\r\n`. No
encoding is done. You should use `\r\n` as the end-of-line!

UNLESS YOU ARE ABSOLUTELY SURE YOU KNOW WHAT YOU ARE DOING YOU SHOULD USE
["SendLineEnc" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#SendLineEnc) INSTEAD!

## SendLineEnc

    $sender = $sender->SendLineEnc(@strings);

Prints the strings to the socket and adds the end-of-line character at the end.
Encodes the text using the selected encoding: `none | Base64 | Quoted-printable`.

Do NOT mix up ["Send" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#Send), ["SendEx" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#SendEx), ["SendLine" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#SendLine),
or ["SendLineEx" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#SendLineEx) with ["SendEnc" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#SendEnc) or ["SendLineEnc" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#SendLineEnc)!
["SendEnc" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#SendEnc) does some buffering necessary for correct Base64
encoding, and ["Send" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#Send) and ["SendEx" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#SendEx) are not aware of that.

Usage of ["Send" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#Send), ["SendEx" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#SendEx), ["SendLine" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#SendLine),
and ["SendLineEx" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#SendLineEx) in non `xBIT` parts is not recommended. Using
`Send(encode_base64($string))` may work, but more likely it will not! In
particular, if you use several such to create one part, the data is very likely
to get crippled.

## SendLineEx

    $sender = $sender->SendLineEnc(@strings);

Prints the strings to the socket. Adds an end-of-line character at the end.
Changes all end-of-lines to `\r\n`. Doesn't encode the data!

UNLESS YOU ARE ABSOLUTELY SURE YOU KNOW WHAT YOU ARE DOING YOU SHOULD USE
["SendLineEnc" in Mail::Sender](https://metacpan.org/pod/Mail::Sender#SendLineEnc) INSTEAD!

# FUNCTIONS

[Mail::Sender](https://metacpan.org/pod/Mail::Sender) implements the following functions.

## GuessCType

    my $ctype = Mail::Sender::GuessCType($filename, $filepath);

Guesses the content type based on the filename or the file contents. This
function is used when you attach a file and do not specify the content type.
It is not exported by default!

## MessageID

    my $id = Mail::Sender::MessageID('from@foo.com');

Generates a "unique" message ID for a given from address.

## ResetGMTdiff

    Mail::Sender::ResetGMTdiff();

The module computes the local vs. GMT time difference to include in the
timestamps added into the message headers. As the time difference may change
due to summer savings time changes you may want to reset the time difference
occasionally in long running programs.

# BUGS

I'm sure there are many. Please let me know if you find any.

The problem with multi-line responses from some SMTP servers (namely
[qmail](http://www.qmail.org/top.html)) is solved at last.

# SEE ALSO

[Email::Sender](https://metacpan.org/pod/Email::Sender)

There are lots of mail related modules on CPAN. Be wise, use [Email::Sender](https://metacpan.org/pod/Email::Sender)!

# AUTHOR

Jan Krynický <`Jenda@Krynicky.cz`> [http://Jenda.Krynicky.cz](http://Jenda.Krynicky.cz)

# CONTRIBUTORS

- Brian Blakley <`bblakley@mp5.net`>,
- Chase Whitener <`capoeirab@cpan.org`>,
- Ed McGuigan <`itstech1@gate.net`>,
- John Sanche <`john@quadrant.net`>
- Rodrigo Siqueira <`rodrigo@insite.com.br`>,

# LICENSE AND COPYRIGHT

Copyright (c) 1997-2014 Jan Krynický <`Jenda@Krynicky.cz`>. All rights reserved.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
