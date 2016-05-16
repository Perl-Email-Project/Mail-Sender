# NAME

Mail::Sender - module for sending mails with attachments through an SMTP server

# SYNOPSIS

    use Mail::Sender;
    $sender = Mail::Sender->new({
      smtp => 'mail.yourdomain.com', from => 'your@address.com'
    });
    $sender->MailFile({to => 'some@address.com',
     subject => 'Here is the file',
     msg => "I'm sending you the list you wanted.",
     file => 'filename.txt'});

# DESCRIPTION

`Mail::Sender` provides an object oriented interface to sending mails.
It doesn't need any outer program. It connects to a mail server
directly from Perl, using Socket.

Sends mails directly from Perl through a socket connection.

# new Mail::Sender

    new Mail::Sender ([from [,replyto [,to [,smtp [,subject [,headers [,boundary]]]]]]])
    new Mail::Sender {[from => 'somebody@somewhere.com'] , [to => 'else@nowhere.com'] [, ...]}

Prepares a sender. This doesn't start any connection to the server. You
have to use `$Sender-`Open> or `$Sender-`OpenMultipart> to start
talking to the server.

The parameters are used in subsequent calls to `$Sender-`Open> and
`$Sender-`OpenMultipart>. Each such call changes the saved variables.
You can set `smtp`, `from` and other options here and then use the info
in all messages.

P.S.: The two snippets of code both contain square brackets. They mean a different thing though. In the first case
they denote the optional parameters (square brackets had been used to mean this in various docs for a long time),
in the second case they denote actual anonymous array reference literals ... except for the last pair.
In general the squares that mean "this part is optional" will have a comma as the first character in their content,
the literal ones will not.

## Parameters

- from

    ``=> the sender's e-mail address

- fake\_from

    ``=> the address that will be shown in headers.

    If not specified we use the value of `from`.

- replyto

    ``=> the reply-to address

- to

    ``=> the recipient's address(es)

    This parameter may be either a comma separated list of email addresses
    or a reference to a list of addresses.

- fake\_to

    ``=> the recipient's address that will be shown in headers.
    If not specified we use the value of "to".

    If the list of addresses you want to send your message to is long or if you do not want
    the recipients to see each other's address set the `fake_to` parameter to some informative,
    yet bogus, address or to the address of your mailing/distribution list.

- cc

    ``=> address(es) to send a copy (CC:) to

- fake\_cc

    ``=> the address that will be shown in headers.

    If not specified we use the value of "cc".

- bcc

    ``=> address(es) to send a copy (BCC: or blind carbon copy).
    these addresses will not be visible in the mail!

- smtp

    ``=> the IP or domain address of your SMTP (mail) server

    This is the name of your LOCAL mail server, do NOT try
    to contact directly the addressee's mail server! That would be slow and buggy,
    your script should only pass the messages to the nearest mail server and leave
    the rest to it. Keep in mind that the recipient's server may be down temporarily.

- port

    ``=> the TCP/IP port used form the connection. By default getservbyname('smtp', 'tcp')||25.
    You should only need to use this option if your mail server waits on a nonstandard port.

- subject

    ``=> the subject of the message

- headers

    ``=> the additional headers

    You may use this parameter to add custom headers into the message. The parameter may
    be either a string containing the headers in the right format or a hash containing the headers
    and their values.

- boundary

    ``=> the message boundary

    You usually do not have to change this, it might only come in handy if you need
    to attach a multipart mail created by Mail::Sender to your message as a single part.
    Even in that case any problems are unlikely.

- multipart

    ``=> the MIME subtype for the whole message (Mixed/Related/Alternative)

    You may need to change this setting if you want to send a HTML body with some
    inline images, or if you want to post the message in plain text as well as
    HTML (alternative). See the examples at the end of the docs.
    You may also use the nickname "subtype".

- ctype

    ``=> the content type of a single part message or the body of the multipart one.

    Please do not confuse these two. The 'multipart' parameter is used to specify
    the overall content type of a multipart message (for example a HTML document
    with inlined images) while ctype is an ordinary content type for a single
    part message or the body of a multipart message.

- encoding

    ``=> encoding of a single part message or the body of a multipart message.

    If the text of the message contains some extended characters or
    very long lines you should use 'encoding => "Quoted-printable"' in the
    call to Open(), OpenMultipart(), MailMsg() or MailFile().

    Keep in mind that if you use some encoding you should either use SendEnc()
    or encode the data yourself !

- charset

    ``=> the charset of the single part message or the body of the multipart one

- client

    ``=> the name of the client computer.

    During the connection you send
    the mail server your computer's name. By default Mail::Sender sends
    `(gethostbyname 'localhost')[0]`.
    If that is not the address you need, you can specify a different one.

- priority

    ``=> the message priority number

    1 = highest, 2 = high, 3 = normal, 4 = low, 5 = lowest

- confirm

    ``=> whether you request reading or delivery confirmations and to what addresses:

        "delivery" - only delivery, to the C<from> address
        "reading" - only reading, to the C<from> address
        "delivery, reading" - both confirmations, to the C<from> address
        "delivery: my.other@address.com" - only delivery, to my.other@address.com
        ...

    Keep in mind though that neither of those is guaranteed to work. Some servers/mail clients do not support
    this feature and some users/admins may have disabled it. So it's possible that your mail was delivered and read,
    but you won't get any confirmation!

- ESMTP

        ESMTP => {
            NOTIFY => 'SUCCESS,FAILURE,DELAY',
            RET => 'HDRS',
            ORCPT => 'rfc822;my.other@address.com',
            ENVID => 'iuhsdfobwoe8t237',
        }

    This option contains data for SMTP extensions, for example it allows you to request delivery
    status notifications according to RFC1891.

    NOTIFY - to specify the conditions under which a delivery status notification should be generated.
    Should be either "NEVER" or a comma separated list of "SUCCESS", "FAILURE"  and "DELAY".

    ORCPT - used to convey the "original" (sender-specified) recipient address

    RET - to request that Delivery Status Notifications containing an indication of delivery
    failure either return the entire contents of a message or only the message headers. Must be either
    FULL or HDRS

    ENVID - used to propagate an identifier for this message transmission envelope, which is also
    known to the sender and will, if present, be returned in any Delivery Status Notifications  issued
    for this transmission

    You do not need to worry about encoding the ORCPT or ENVID parameters.

    If the SMTP server you connect to doesn't support this extension, the options will be ignored.

- debug

    ``=> `"/path/to/debug/file.txt"`

    or

    ``=>  \\\*FILEHANDLE

    or

    ``=> $FH

    All the conversation with the server will be logged to that file or handle.
    All lines in the file should end with CRLF (the Windows and Internet format).
    If even a single one of them does not, please let me know!

    If you pass the path to the log file, Mail::Sender will overwrite it. If you want to append to the file,
    you have to open it yourself and pass the filehandle:

        open my $DEBUG, ">> /path/to/debug/file.txt"
            or die "Can't open the debug file: $!\n"
        $sender = Mail::Sender->new({
            ...
            debug => $DEBUG,
        });

- debug\_level

    Only taken into account if the `debug` option is specified.

        1 - only log the conversation with the server, skip all message data
        2 - log the conversation and message headers
        3 - log the conversation and the message and part headers
        4 - log everything (default)

- auth

    the SMTP authentication protocol to use to login to the server
    currently the only ones supported are LOGIN, PLAIN, CRAM-MD5 and NTLM.

    Some protocols have module dependencies. CRAM-MD5 depends on
    Digest::HMAC\_MD5 and NTLM on Authen::NTLM.

    You may add support for other authentication protocols yourself. See below.

- authid

    the username used to login to the server

- authpwd

    the password used to login to the server

- authdomain

    the domain name. Used optionally by the NTLM authentication.

    Other authentication protocols may use other options as well.
    They should all start with "auth" though.

    Please see the authentication section bellow.

- auth\_encoded

    If set to a true value the LOGIN authentication assumes the authid and authpwd
    is already base64 encoded.

- tls\_allowed

    If set to a true value Mail::Sender attempts to use LTS (SSL encrypted connection) whenever
    the server supports it and you have IO::Socket::SSL and Net::SSLeay.

    The default value of this option is TRUE! This means that if Mail::Server can send the data encrypted, it will.

- tls\_required

    If you set this option to a true value, the module will fail whenever it's unable to use TLS.

- ssl\_...

    The ssl\_version, ssl\_verify\_mode, ssl\_ca\_path, ssl\_ca\_file, ssl\_verifycb\_name, ssl\_verifycn\_schema and ssl\_hostname
    options (if specified) are passed to IO::Socket::SSL->start\_SSL(). The default for the first two is 'TLSv1' and IO::Socket::SSL::SSL\_VERIFY\_NONE().

    If you change the ssl\_verify\_mode to SSL\_VERIFY\_PEER, you may need to specify also the ssl\_ca\_file. If you have Mozilla::CA installed, then setting it to
    Mozilla::CA::SSL\_ca\_file() may help.

- keepconnection

    If set to a true value causes the Mail::Sender to keep the connection open for several messages.
    The connection will be closed if you call the Close() method with a true value or if you call Open,
    OpenMultipart, MailMsg or MailFile with the "smtp" parameter.
    This means that if you want the object to keep the connection you should pass the "smtp" either to "new Mail::Sender"
    or only to the first Open, OpenMultipart, MailMsg or MailFile!

- skip\_bad\_recipients

    If this option is set to false or not specified then Mail::Sender stops trying to send a message as soon as
    the first recipient's address fails. If it is set to a true value Mail::Sender skips the bad addresses and tries
    to send the message at least to the good ones. If all addresses are rejected by the server it reports an
    "All recipients were rejected" message.

    If any addresses were skipped the `$sender->{'skipped_recipients'}` will be a reference to a hash
    containing the failed address and the server's response.

- createmessageid

    This option allows you to overwrite the function that generates the message IDs for the emails.
    The function gets the "pure" sender's address as it's only parameter and is supposed to return a string.
    See the MessageID subroutine in Mail::Sender.pm.

    If you want to specify a message id you can also use the "messageid" parameter for the Open, OpenMultipart,
    MailMsg or MailFile methods.

- on\_errors

    This option allows you to affect the way Mail::Sender reports errors.

        => 'die' - raise an exception
        => 'code' - return the negative error code (default)
        => 'undef' - return an undef

    $Mail::Sender::Error, $sender->{'error'} and $sender->{'error\_msg'} are set in all the cases.

    All methods return the $sender object if they succeed.

    P.S.: The die\_on\_errors option is deprecated. You may still use it, but it may be removed in future versions!

## Return codes

    ref to a Mail::Sender object =  success

    -1 = $smtphost unknown
    -2 = socket() failed
    -3 = connect() failed
    -4 = service not available
    -5 = unspecified communication error
    -6 = local user $to unknown on host $smtp
    -7 = transmission of message failed
    -8 = argument $to empty
    -9 = no message specified in call to MailMsg or MailFile
    -10 = no file name specified in call to SendFile or MailFile
    -11 = file not found
    -12 = not available in singlepart mode
    -13 = site specific error
    -14 = connection not established. Did you mean MailFile instead of SendFile?
    -15 = no SMTP server specified
    -16 = no From: address specified
    -17 = authentication protocol not accepted by the server
    -18 = login not accepted
    -19 = authentication protocol is not implemented
    -20 = all recipients were rejected by the server
    -21 = file specified as an attachment cannot be read
    -22 = failed to open the specified debug file for writing
    -23 = STARTTLS failed (for SSL or TLS encrypted connections)
    -24 = IO::Socket::SSL->start_SSL failed
    -25 = TLS required by the specified options, but the required modules are not available. Need IO::Socket::SSL and Net::SSLeay
    -26 = TLS required by the specified options, but the server doesn't support it
    -27 = unknown encoding specified for the mail body, part or attachment. Only base64, quoted-printable, 7bit and 8bit supported.

$Mail::Sender::Error contains a textual description of last error.

# METHODS

## Open

    Open([from [, replyto [, to [, smtp [, subject [, headers]]]]]])
    Open({[from => "somebody@somewhere.com"] , [to => "else@nowhere.com"] [,...]})

Opens a new message. If some parameters are unspecified or empty, it uses
the parameters passed to the `$Sender = Mail::Sender->new(...)`;

See `new Mail::Sender` for info about the parameters.

The only additional parameter that may not be specified directly in the `new Mail::Sender`
is messageid. If you set this option then the message will be sent with this Message-ID,
otherwise a new Message ID will be generated out of the sender's address, current date+time
and a random number (or by the function you specified in the `createmessageid` option).

After the message is sent `$sender->{messageid}` will contain the Message-ID with
which the message was sent.

Returns ref to the Mail::Sender object if successful.

## OpenMultipart

    OpenMultipart([from [, replyto [, to [, smtp [, subject [, headers [, boundary]]]]]]])
    OpenMultipart({[from => "somebody@somewhere.com"] , [to => "else@nowhere.com"] [,...]})

Opens a multipart message. If some parameters are unspecified or empty, it uses
the parameters passed to the `$Sender = Mail::Sender->new(...)`.

See `Mail::Sender/"new"` for info about the parameters.

Returns ref to the Mail::Sender object if successful.

## MailMsg

    MailMsg([from [, replyto [, to [, smtp [, subject [, headers]]]]]], message)
    MailMsg({[from => "somebody@somewhere.com"]
             [, to => "else@nowhere.com"] [,...], msg => "Message"})

Sends a message. If a mail in $sender is opened it gets closed
and a new mail is created and sent. $sender is then closed.
If some parameters are unspecified or empty, it uses
the parameters passed to the "`$Sender= Mail::Sender-`new(...)>";

See `new Mail::Sender` for info about the parameters.

The module was made so that you could create an object initialized with
all the necessary options and then send several messages without need to
specify the SMTP server and others each time. If you need to send only
one mail using MailMsg() or MailFile() you do not have to create a named
object and then call the method. You may do it like this :

    (new Mail::Sender)->MailMsg({smtp => 'mail.company.com', ...});

Returns ref to the Mail::Sender object if successful.

## MailFile

    MailFile([from [, replyto [, to [, smtp [, subject [, headers]]]]]], message, file(s))
    MailFile({[from => "somebody@somewhere.com"]
              [, to => "else@nowhere.com"] [,...],
              msg => "Message", file fs=> "File"})

Sends one or more files by mail. If a mail in $sender is opened it gets closed
and a new mail is created and sent. $sender is then closed.
If some parameters are unspecified or empty, it uses
the parameters passed to the "`$Sender= Mail::Sender-`new(...)>";

The `file` parameter may be a "filename", a "list, of, file, names" or a \\@list\_of\_file\_names.

see `new Mail::Sender` for info about the parameters.

Just keep in mind that parameters like ctype, charset and encoding
will be used for the attached file, not the body of the message.
If you want to specify those parameters for the body you have to use
b\_ctype, b\_charset and b\_encoding. Sorry.

Returns ref to the Mail::Sender object if successful.

## Send

    Send(@strings)

Prints the strings to the socket. Doesn't add any end-of-line characters.
Doesn't encode the data! You should use `\r\n` as the end-of-line!

UNLESS YOU ARE ABSOLUTELY SURE YOU KNOW WHAT YOU ARE DOING
YOU SHOULD USE SendEnc() INSTEAD!

Returns the object if successful.

## SendLine

    SendLine(@strings)

Prints the strings to the socket. Adds the end-of-line character at the end.
Doesn't encode the data! You should use `\r\n` as the end-of-line!

UNLESS YOU ARE ABSOLUTELY SURE YOU KNOW WHAT YOU ARE DOING
YOU SHOULD USE SendLineEnc() INSTEAD!

Returns the object if successful.

## print

Alias to SendEnc().

Keep in mind that you can't write :

    print $sender "...";

you have to use

    $sender->print("...");

If you want to be able to print into the message as if it was a normal file handle take a look at `GetHandle`()

## SendEnc

    SendEnc(@strings)

Prints the strings to the socket. Doesn't add any end-of-line characters.

Encodes the text using the selected encoding (none/Base64/Quoted-printable)

Returns the object if successful.

## SendLineEnc

    SendLineEnc(@strings)

Prints the strings to the socket and adds the end-of-line character at the end.
Encodes the text using the selected encoding (none/Base64/Quoted-printable).

Do NOT mix up /Send(Line)?(Ex)?/ and /Send(Line)?Enc/! SendEnc does some buffering
necessary for correct Base64 encoding, and /Send(Ex)?/ is not aware of that!

Usage of /Send(Line)?(Ex)?/ in non xBIT parts not recommended.
Using `Send(encode_base64($string))` may work, but more likely it will not!
In particular if you use several such to create one part,
the data is very likely to get crippled.

Returns the object if successful.

## SendEx

    SendEx(@strings)

Prints the strings to the socket. Doesn't add any end-of-line characters.
Changes all end-of-lines to `\r\n`. Doesn't encode the data!

UNLESS YOU ARE ABSOLUTELY SURE YOU KNOW WHAT YOU ARE DOING
YOU SHOULD USE SendEnc() INSTEAD!

Returns the object if successful.

## SendLineEx

    SendLineEx(@strings)

Prints the strings to the socket. Adds an end-of-line character at the end.
Changes all end-of-lines to `\r\n`. Doesn't encode the data!

UNLESS YOU ARE ABSOLUTELY SURE YOU KNOW WHAT YOU ARE DOING
YOU SHOULD USE SendEnc() INSTEAD!

Returns the object if successful.

## Part

    Part( I<description>, I<ctype>, I<encoding>, I<disposition> [, I<content_id> [, I<msg>]]);
    Part( {[description => "desc"], [ctype => "content/type"], [encoding => "..."],
        [disposition => "..."], [content_id => "..."], [msg => ...]});

Prints a part header for the multipart message and (if specified) the contents.
The undefined or empty variables are ignored.

- description

    The title for this part.

- ctype

    the content type (MIME type) of this part. May contain some other
    parameters, such as **charset** or **name**.

    Defaults to "application/octet-stream".

    Since 0.8.00 you may use even "multipart/..." types. Such a multipart part should be
    closed by a call to $sender->EndPart($ctype).

        ...
        $sender->Part({ctype => "multipart/related", ...});
            $sender->Part({ctype => 'text/html', ...});
            $sender->Attach({file => 'some_image.gif', content_id => 'foo', ...});
        $sender->EndPart("multipart/related");
        ...

    Please see the examples below.

- encoding

    the encoding used for this part of message. E.g. Base64, Uuencode, 7BIT
    ...

    Defaults to "7BIT".

- disposition

    This parts disposition. E.g.: 'attachment; filename="send.pl"'.

    Defaults to "attachment". If you specify "none" or "", the
    Content-Disposition: line will not be included in the headers.

- content\_id

    The content id of the part, used in multipart/related.
    If not specified, the header is not included.

- msg

    The content of the part. You do not have to specify the content here, you may use SendEnc()
    to add content to the part.

- charset

    The charset of the part.

Returns the Mail::Sender object if successful, negative error code if not.

## Body

    Body([charset [, encoding [, content-type]]]);
    Body({charset => '...', encoding => '...', ctype => '...', msg => '...');

Sends the head of the multipart message body. You can specify the
charset and the encoding. Default is "US-ASCII","7BIT",'text/plain'.

If you pass undef or zero as the parameter, this function uses the default
value:

    Body(0,0,'text/html');

Returns the Mail::Sender object if successful, negative error code if not.
You should NOT use this method in single part messages, that is, it works after OpenMultipart(),
but has no meaning after Open()!

## SendFile

Alias to Attach()

## Attach

    Attach( I<description>, I<ctype>, I<encoding>, I<disposition>, I<file>);
    Attach( { [description => "desc"] , [ctype => "ctype"], [encoding => "encoding"],
                [disposition => "disposition"], file => "file"});

    Sends a file as a separate part of the mail message. Only in multipart mode.

- description

    The title for this part.

- ctype

    the content type (MIME type) of this part. May contain some other
    parameters, such as **charset** or **name**.

    Defaults to "application/octet-stream".

- encoding

    the encoding used for this part of message. E.g. Base64, Uuencode, 7BIT
    ...

    Defaults to "Base64".

- disposition

    This parts disposition. E.g.: 'attachment; filename="send.pl"'. If you use
    'attachment; filename=\*' the \* will be replaced by the respective names
    of the sent files.

    Defaults to "attachment; filename=\*". If you do not want to include this header use
    "" as the value.

- file

    The name of the file to send or a 'list, of, names' or a
    \['reference','to','a','list','of','filenames'\]. Each file will be sent as
    a separate part.

    Please keep in mind that if you pass a string as this parameter the module
    will split it on commas! If your filenames may contain commas and you
    want to be sure they are sent correctly you have to use the reference to array
    format:

        file => [ $filename],

- content\_id

    The content id of the message part. Used in multipart/related.

        Special values:
         "*" => the name of the file
         "#" => autoincremented number (starting from 0)

Returns the Mail::Sender object if successful, negative error code if not.

## EndPart

    $sender->EndPart($ctype);

Closes a multipart part.

If the $ctype is not present or evaluates to false, only the current SIMPLE part is closed!
Don't do that unless you are really sure you know what you are doing.

It's best to always pass to the ->EndPart() the content type of the corresponding ->Part().

## Close

    $sender->Close;
    $sender->Close(1);

Close and send the email message. If you pass a true value to the method the connection will be closed even
if the "keepconnection" was specified. You should only keep the connection open if you plan to send another
message immediately. And you should not keep it open for hundreds of emails even if you do send them all in a row.

This method should be called automatically when destructing the object, but you should not rely on it. If you want to be sure
your message WAS processed by the SMTP server you SHOULD call Close() explicitly.

Returns the Mail::Sender object if successful, negative error code if not, zero if $sender was not connected at all.
The zero usually means that the Open/OpenMultipart failed and you did not test its return value.

## Cancel

    $sender->Cancel;

Cancel an opened message.

SendFile and other methods may set $sender->{'error'}.
In that case "undef $sender" calls `$sender-`>Cancel not `$sender-`>Close!!!

Returns the Mail::Sender object if successful, negative error code if not.

## QueryAuthProtocols

    @protocols = $sender->QueryAuthProtocols();
    @protocols = $sender->QueryAuthProtocols( $smtpserver);

Queries the server (specified either in the default options for Mail::Sender,
the "Mail::Sender->new" command or as a parameter to this method for
the authentication protocols it supports.

## GetHandle

Returns a "filehandle" to which you can print the message or file to attach or whatever.
The data you print to this handle will be encoded as necessary. Closing this handle closes
either the message (for single part messages) or the part.

    $sender->Open({...});
    my $handle = $sender->GetHandle();
    print $handle "Hello world.\n"
    my ($mday,$mon,$year) = (localtime())[3,4,5];
    printf $handle "Today is %04d/%02d/%02d.", $year+1900, $mon+1, $mday;
    close $handle;

P.S.: There is a big difference between the handle stored in $sender->{'socket'} and the handle
returned by this function ! If you print something to $sender->{'socket'} it will be sent to the server
without any modifications, encoding, escaping, ...
You should NOT touch the $sender->{'socket'} unless you really really know what you are doing.

# FUNCTIONS

## GuessCType

    $ctype = GuessCType $filename, $filepath;

Guesses the content type based on the filename or the file contents.
This function is used when you attach a file and do not specify the content type.
It is not exported by default!

The builtin version uses the filename extension to guess the type.
Currently there are only a few extensions defined, you may add other extensions this way:

    $Mail::Sender::CTypes{'EXT'} = 'content/type';
    ...

The extension has to be in UPPERCASE and will be matched case sensitively.

The package now includes three addins improving the guesswork. If you "use" one of them in your script,
it replaces the builtin GuessCType() subroutine with a better one:

    Mail::Sender::CType::Win32
        Win32 only, the content type is read from the registry
    Mail::Sender::CType::Ext
        any OS, a longer list of extensions from A. Guillaume
    Mail::Sender::CType::LWP
        any OS, uses LWP::MediaTypes::guess_media_type

## ResetGMTdiff

    ResetGMTdiff()

The module computes the local vs. GMT time difference to include in the timestamps
added into the message headers. As the time difference may change due to summer
savings time changes you may want to reset the time difference occasionally
in long running programs.

# CONFIG

If you create a file named Sender.config in the same directory where
Sender.pm resides, this file will be "require"d as soon as you "use
Mail::Sender" in your script. Of course the Sender.config MUST "return a
true value", that is it has to be successfully compiled and the last
statement must return a true value. You may use this to forbid the use
of Mail::Sender to some users.

You may define the default settings for new Mail::Sender objects and do
a few more things.

The default options are stored in hash %Mail::Sender::default. You may
use all the options you'd use in `new`, `Open`, `OpenMultipart`,
`MailMsg` or `MailFile`.

    E.g.
     %default = (
       smtp => 'mail.yourhost.cz',
       from => getlogin.'yourhost.cz',
       client => getlogin.'.yourhost.cz'
     );
     # of course you will use your own mail server here !

The other options you may set here (or later of course) are
$Mail::Sender::SITE\_HEADERS, $Mail::Sender::NO\_X\_MAILER and
$Mail::Sender::NO\_DATE. (These are plain old scalar variables, there is no
function or method for modifying them. Just set them to anything you need.)

The $Mail::Sender::SITE\_HEADERS may contain headers that will be added
to each mail message sent by this script, the $Mail::Sender::NO\_X\_MAILER
disables the header item specifying that the message was sent by
Mail::Sender and $Mail::Sender::NO\_DATE turns off the Date: header generation.

!!! $Mail::Sender::SITE\_HEADERS may NEVER end with \\r\\n !!!

If you want to set the $Mail::Sender::SITE\_HEADERS for every script sent
from your server without your users being able to change it you may use
this hack:

    $loginname = something_that_identifies_the_user();
    *Mail::Sender::SITE_HEADERS = \"X-Sender: $loginname via $0";
    $Mail::Sender::NO_X_MAILER = 1;

You may even "install" your custom function that will be evaluated for
each message just before contacting the server. You may change all the
options from within as well as stop sending the message.

All you have to do is to create a function named SiteHook in
Mail::Sender package. This function will get the Mail::Sender object as
its first argument. If it returns a TRUE value the message is sent,
if it returns FALSE the sending is canceled and the user gets
"Site specific error" error message.

If you want to give some better error message you may do it like this :

    sub SiteHook {
     my $self = shift;
     if (whatever($self)) {
       $self->Error( _SITEERROR);
       $Mail::Sender::Error = "I don't like this mail";
       return 0
     } else {
       return 1;
     }
    }

This example will ensure the from address is the users real address :

    sub SiteHook {
     my $self = shift;
     $self->{'fromaddr'} = getlogin.'@yoursite.com';
     $self->{'from'} = getlogin.'@yoursite.com';
     1;
    }

Please note that at this stage the from address is in two different
object properties.

$self->{'from'} is the address as it will appear in the mail, that is
it may include the full name of the user or any other comment
( "Jan Krynicky <jenda@krynicky.cz>" for example), while the
$self->{'fromaddr'} is really just the email address per se and it will
be used in conversation with the SMTP server. It must be without
comments ("jenda@krynicky.cz" for example)!

Without write access to .../lib/Mail/Sender.pm or
.../lib/Mail/Sender.config your users will then be unable to get rid of
this header. Well ... everything is doable, if they are cheeky enough ... :-(

So if you take care of some site with virtual servers for several
clients and implement some policy via SiteHook() or
$Mail::Sender::SITE\_HEADERS search the clients' scripts for "SiteHook"
and "SITE\_HEADERS" from time to time. To see who's cheating.

# AUTHENTICATION

If you get a "Local user "xxx@yyy.com" unknown on host "zzz"" message it usually means that
your mail server is set up to forbid mail relay. That is it only accepts messages to or from a local user.
If you need to be able to send a message with both the sender's and recipient's address remote, you
need to somehow authenticate to the server. You may need the help of the mail server's administrator
to find out what username and password and/or what authentication protocol are you supposed to use.

There are many authentication protocols defined for ESTMP, Mail::Sender supports
only PLAIN, LOGIN, CRAM-MD5 and NTLM (please see the docs for `new Mail::Sender`).

If you want to know what protocols are supported by your server you may get the list by this:

      /tmp# perl -MMail::Sender -e 'Mail::Sender->printAuthProtocols("the.server.com")'
    or
      c:\> perl -MMail::Sender -e "Mail::Sender->printAuthProtocols('the.server.com')"

There is one more way to authenticate. Some servers want you to login by POP3 before you
can send a message. You have to use Net::POP3 or Mail::POP3Client to do this.

## Other protocols

It is possible to add new authentication protocols to Mail::Sender. All you have to do is
to define a function Mail::Sender::Auth::PROTOCOL\_NAME that will implement
the login. The function gets one parameter ... the Mail::Sender object.
It can access these properties:

    $obj->{'socket'} : the socket to print to and read from
        you may use the send_cmd() function to send a request
        and read a response from the server
    $obj->{'authid'} : the username specified in the new Mail::Sender,
        Open or OpenMultipart call
    $obj->{'authpwd'} : the password
    $obj->{auth...} : all unknown parameters passed to the constructor or the mail
        opening/creation methods are preserved in the object. If the protocol requires
        any other options, please use names starting with "auth". E.g. "authdomain", ...
    $obj->{'error'} : this should be set to a negative error number. Please use numbers
        below -1000 for custom errors.
    $obj->{'error_msg'} : this should be set to the error message

    If the login fails you should
        1) Set $Mail::Sender::Error to the error message
        2) Set $obj->{'error_msg'} to the error message
        2) Set $obj->{'error'} to a negative number
        3) return a negative number
    If it succeeds, please return "nothing" :
        return;

Please use the protocols defined within Sender.pm as examples.

# EXAMPLES

## Object creation

    ref ($sender = Mail::Sender->new({ from => 'somebody@somewhere.com',
          smtp => 'mail.yourISP.com', boundary => 'This-is-a-mail-boundary-435427'}))
    or die "Error in mailing : $Mail::Sender::Error\n";

or

    my $sender = Mail::Sender->new(){ ... });
    die "Error in mailing : $Mail::Sender::Error\n" unless ref $sender;

or

    my $sender = Mail::Sender->new({ ..., on_errors => 'undef' })
      or die "Error in mailing : $Mail::Sender::Error\n";

You may specify the options either when creating the Mail::Sender object
or later when you open a message. You may also set the default options when
installing the module (See `CONFIG` section). This way the admin may set
the SMTP server and even the authentication options and the users do not have
to specify it again.

You should keep in mind that the way Mail::Sender reports failures depends on the 'on\_errors'=>
option. If you set it to 'die' it throws an exception, if you set it to `undef` or `'undef'` it returns
undef and otherwise it returns a negative error code!

## Simple single part message

    $sender = Mail::Sender->new({
        smtp => 'mail.yourISP.com',
        from => 'somebody@somewhere.com',
        on_errors => undef,
    })
        or die "Can't create the Mail::Sender object: $Mail::Sender::Error\n";
    $sender->Open({
        to => 'mama@home.org, papa@work.com',
        cc => 'somebody@somewhere.com',
        subject => 'Sorry, I\'ll come later.'
    })
        or die "Can't open the message: $sender->{'error_msg'}\n";
    $sender->SendLineEnc("I'm sorry, but thanks to the lusers,
        I'll come at 10pm at best.");
    $sender->SendLineEnc("\nHi, Jenda");
    $sender->Close()
        or die "Failed to send the message: $sender->{'error_msg'}\n";

or

    eval {
        $sender = Mail::Sender->new({
            smtp => 'mail.yourISP.com',
            from => 'somebody@somewhere.com',
            on_errors => 'die',
        });
        $sender->Open({
            to => 'mama@home.org, papa@work.com',
            cc => 'somebody@somewhere.com',
            subject => 'Sorry, I\'ll come later.'
        });
        $sender->SendLineEnc("I'm sorry, but thanks to the lusers,
            I'll come at 10pm at best.");
        $sender->SendLineEnc("\nHi, Jenda");
        $sender->Close();
    };
    if ($@) {
        die "Failed to send the message: $@\n";
    }

or

    $sender = Mail::Sender->new({
        smtp => 'mail.yourISP.com',
        from => 'somebody@somewhere.com',
        on_errors => 'code',
    });
    die "Can't create the Mail::Sender object: $Mail::Sender::Error\n"
        unless ref $sender;
    ref $sender->Open({
        to => 'mama@home.org, papa@work.com',
        cc => 'somebody@somewhere.com',
        subject => 'Sorry, I\'ll come later.'
    })
        or die "Can't open the message: $sender->{'error_msg'}\n";
    $sender->SendLineEnc("I'm sorry, but thanks to the lusers,
        I'll come at 10pm at best.");
    $sender->SendLineEnc("\nHi, Jenda");
    ref $sender->Close
        or die "Failed to send the message: $sender->{'error_msg'}\n";

## Using GetHandle()

    ref $sender->Open({to => 'friend@other.com', subject => 'Hello dear friend'})
       or die "Error: $Mail::Sender::Error\n";
    my $FH = $sender->GetHandle();
    print $FH "How are you?\n\n";
    print $FH <<'END';
    I've found these jokes.

     Doctor, I feel like a pack of cards.
     Sit down and I'll deal with you later.

     Doctor, I keep thinking I'm a dustbin.
     Don't talk rubbish.

    Hope you like'em. Jenda
    END

    $sender->Close;
    # or
    # close $FH;

or

    eval {
      $sender->Open({ on_errors => 'die',
               to => 'mama@home.org, papa@work.com',
                  cc => 'somebody@somewhere.com',
                  subject => 'Sorry, I\'ll come later.'});
      $sender->SendLineEnc("I'm sorry, but due to a big load of work,
    I'll come at 10pm at best.");
      $sender->SendLineEnc("\nHi, Jenda");
      $sender->Close;
    };
    if ($@) {
      print "Error sending the email: $@\n";
    } else {
      print "The mail was sent.\n";
    }

## Multipart message with attachment

    $sender->OpenMultipart({to => 'Perl-Win32-Users@activeware.foo',
                            subject => 'Mail::Sender.pm - new module'});
    $sender->Body;
    $sender->SendEnc(<<'END');
    Here is a new module Mail::Sender.
    It provides an object based interface to sending SMTP mails.
    It uses a direct socket connection, so it doesn't need any
    additional program.

    Enjoy, Jenda
    END
    $sender->Attach(
     {description => 'Perl module Mail::Sender.pm',
      ctype => 'application/x-zip-encoded',
      encoding => 'Base64',
      disposition => 'attachment; filename="Sender.zip"; type="ZIP archive"',
      file => 'sender.zip'
     });
    $sender->Close;

or

    $sender->OpenMultipart({to => 'Perl-Win32-Users@activeware.foo',
                            subject => 'Mail::Sender.pm - new version'});
    $sender->Body({ msg => <<'END' });
    Here is a new module Mail::Sender.
    It provides an object based interface to sending SMTP mails.
    It uses a direct socket connection, so it doesn't need any
    additional program.

    Enjoy, Jenda
    END
    $sender->Attach(
     {description => 'Perl module Mail::Sender.pm',
      ctype => 'application/x-zip-encoded',
      encoding => 'Base64',
      disposition => 'attachment; filename="Sender.zip"; type="ZIP archive"',
      file => 'sender.zip'
     });
    $sender->Close;

or (in case you have the file contents in a scalar)

    $sender->OpenMultipart({to => 'Perl-Win32-Users@activeware.foo',
                            subject => 'Mail::Sender.pm - new version'});
    $sender->Body({ msg => <<'END' });
    Here is a new module Mail::Sender.
    It provides an object based interface to sending SMTP mails.
    It uses a direct socket connection, so it doesn't need any
    additional program.

    Enjoy, Jenda
    END
    $sender->Part(
     {description => 'Perl module Mail::Sender.pm',
      ctype => 'application/x-zip-encoded',
      encoding => 'Base64',
      disposition => 'attachment; filename="Sender.zip"; type="ZIP archive"',
      msg => $sender_zip_contents,
     });
    $sender->Close;

## Using exceptions (no need to test return values after each function)

    use Mail::Sender;
    eval {
    (new Mail::Sender {on_errors => 'die'})
        ->OpenMultipart({smtp=> 'jenda.krynicky.cz', to => 'jenda@krynicky.cz',subject => 'Mail::Sender.pm - new version'})
        ->Body({ msg => <<'END' })
    Here is a new module Mail::Sender.
    It provides an object based interface to sending SMTP mails.
    It uses a direct socket connection, so it doesn't need any
    additional program.

    Enjoy, Jenda
    END
        ->Attach({
            description => 'Perl module Mail::Sender.pm',
            ctype => 'application/x-zip-encoded',
            encoding => 'Base64',
            disposition => 'attachment; filename="Sender.zip"; type="ZIP archive"',
            file => 'W:\jenda\packages\Mail\Sender\Mail-Sender-0.7.14.3.tar.gz'
        })
        ->Close();
    } or print "Error sending mail: $@\n";

## Using MailMsg() shortcut to send simple messages

If everything you need is to send a simple message you may use:

    if (ref ($sender->MailMsg({to =>'Jenda@Krynicky.czX', subject => 'this is a test',
                            msg => "Hi Johnie.\nHow are you?"}))) {
     print "Mail sent OK."
    } else {
     die "$Mail::Sender::Error\n";
    }

or

    if ($sender->MailMsg({
      smtp => 'mail.yourISP.com',
      from => 'somebody@somewhere.com',
      to =>'Jenda@Krynicky.czX',
      subject => 'this is a test',
      msg => "Hi Johnie.\nHow are you?"
    }) < 0) {
     die "$Mail::Sender::Error\n";
    }
    print "Mail sent OK."

## Using MailMsg and authentication

    if ($sender->MailMsg({
      smtp => 'mail.yourISP.com',
      from => 'somebody@somewhere.com',
      to =>'Jenda@Krynicky.czX',
      subject => 'this is a test',
      msg => "Hi Johnie.\nHow are you?"
      auth => 'NTLM',
      authid => 'jenda',
      authpwd => 'benda',
    }) < 0) {
     die "$Mail::Sender::Error\n";
    }
    print "Mail sent OK."

## Using MailFile() shortcut to send an attachment

If you want to attach some files:

    (ref ($sender->MailFile(
     {to =>'you@address.com', subject => 'this is a test',
      msg => "Hi Johnie.\nI'm sending you the pictures you wanted.",
      file => 'image1.jpg,image2.jpg'
     }))
     and print "Mail sent OK."
    )
    or die "$Mail::Sender::Error\n";

## Sending HTML messages

If you are sure the HTML doesn't contain any accentuated characters (with codes above 127).

    open IN, $htmlfile or die "Cannot open $htmlfile : $!\n";
    $sender->Open({ from => 'your@address.com', to => 'other@address.com',
           subject => 'HTML test',
           ctype => "text/html",
           encoding => "7bit"
    }) or die $Mail::Sender::Error,"\n";

    while (<IN>) { $sender->SendEx($_) };
    close IN;
    $sender->Close();

Otherwise use SendEnc() instead of SendEx() and "quoted-printable" instead of "7bit".

Another ... quicker way ... would be:

    open IN, $htmlfile or die "Cannot open $htmlfile : $!\n";
    $sender->Open({ from => 'your@address.com', to => 'other@address.com',
           subject => 'HTML test',
           ctype => "text/html",
           encoding => "quoted-printable"
    }) or die $Mail::Sender::Error,"\n";

    while (read IN, $buff, 4096) { $sender->SendEnc($buff) };
    close IN;
    $sender->Close();

## Sending HTML messages with inline images

    if (ref $sender->OpenMultipart({
        from => 'someone@somewhere.net', to => $recipients,
        subject => 'Embedded Image Test',
        boundary => 'boundary-test-1',
        multipart => 'related'})) {
        $sender->Attach(
             {description => 'html body',
             ctype => 'text/html; charset=us-ascii',
             encoding => '7bit',
             disposition => 'NONE',
             file => 'test.html'
        });
        $sender->Attach({
            description => 'ed\'s gif',
            ctype => 'image/gif',
            encoding => 'base64',
            disposition => "inline; filename=\"apache_pb.gif\";\r\nContent-ID: <img1>",
            file => 'apache_pb.gif'
        });
        $sender->Close() or die "Close failed! $Mail::Sender::Error\n";
    } else {
        die "Cannot send mail: $Mail::Sender::Error\n";
    }

And in the HTML you'll have this :
 ... <IMG src="cid:img1"> ...
on the place where you want the inlined image.

Please keep in mind that the image name is unimportant, it's the Content-ID what counts!

\# or using the eval{ $obj->Method()->Method()->...->Close()} trick ...

    use Mail::Sender;
    eval {
    (new Mail::Sender)
        ->OpenMultipart({
            to => 'someone@somewhere.com',
            subject => 'Embedded Image Test',
            boundary => 'boundary-test-1',
            type => 'multipart/related'
        })
        ->Attach({
            description => 'html body',
            ctype => 'text/html; charset=us-ascii',
            encoding => '7bit',
            disposition => 'NONE',
            file => 'c:\temp\zk\HTMLTest.htm'
        })
        ->Attach({
            description => 'Test gif',
            ctype => 'image/gif',
            encoding => 'base64',
            disposition => "inline; filename=\"test.gif\";\r\nContent-ID: <img1>",
            file => 'test.gif'
        })
        ->Close()
    }
    or die "Cannot send mail: $Mail::Sender::Error\n";

## Sending message with plain text and HTML alternatives

    use Mail::Sender;

    eval {
        (new Mail::Sender)
        ->OpenMultipart({
            to => 'someone@somewhere.com',
            subject => 'Alternatives',
    #        debug => 'c:\temp\zkMailFlow.log',
            multipart => 'mixed',
        })
            ->Part({ctype => 'multipart/alternative'})
                ->Part({ ctype => 'text/plain', disposition => 'NONE', msg => <<'END' })
    A long
    mail
    message.
    END
                ->Part({ctype => 'text/html', disposition => 'NONE', msg => <<'END'})
    <html><body><h1>A long</h1><p align=center>
    mail
    message.
    </p></body></html>
    END
            ->EndPart("multipart/alternative")
        ->Close();
    } or print "Error sending mail: $Mail::Sender::Error\n";

## Sending message with plain text and HTML alternatives with inline images

    use Mail::Sender;

    eval {
        (new Mail::Sender)
        ->OpenMultipart({
            to => 'someone@somewhere.com',
            subject => 'Alternatives with images',
    #        debug => 'c:\temp\zkMailFlow.log',
            multipart => 'related',
        })
            ->Part({ctype => 'multipart/alternative'})
                ->Part({ ctype => 'text/plain', disposition => 'NONE', msg => <<'END' })
    A long
    mail
    message.
    END
                ->Part({ctype => 'text/html', disposition => 'NONE', msg => <<'END'})
    <html><body><h1>A long</h1><p align=center>
    mail
    message.
    <img src="cid:img1">
    </p></body></html>
    END
            ->EndPart("multipart/alternative")
            ->Attach({
                description => 'ed\'s jpg',
                ctype => 'image/jpeg',
                encoding => 'base64',
                disposition => "inline; filename=\"0518m_b.jpg\";\r\nContent-ID: <img1>",
                file => 'E:\pix\humor\0518m_b.jpg'
            })
        ->Close();
    } or print "Error sending mail: $Mail::Sender::Error\n";

Keep in mind please that different mail clients display messages differently. You may
need to try several ways to create messages so that they appear the way you need.
These two examples looked like I expected in Pegasus Email and MS Outlook.

If this doesn't work with your mail client, please let me know and we might find a way.

## Sending a file that was just uploaded from an HTML form

    use CGI;
    use Mail::Sender;

    $query = CGI->new();

    # uploading the file...
    $filename = $query->param('mailformFile');
    if ($filename ne ""){
     $tmp_file = $query->tmpFileName($filename);
    }

    $sender = Mail::Sender->new({from => 'script@krynicky.cz',smtp => 'mail.krynicky.czX'});
    $sender->OpenMultipart({to=> 'jenda@krynicky.czX',subject=> 'test CGI attach'});
    $sender->Body();
    $sender->Send(<<'END');
    This is just a test of mail with an uploaded file.

    Jenda
    END
    $sender->Attach({
       encoding => 'Base64',
       description => $filename,
       ctype => $query->uploadInfo($filename)->{'Content-Type'},
       disposition => "attachment; filename = $filename",
       file => $tmp_file
    });
    $sender->Close();

    print "Content-Type: text/plain\n\nYes, it's sent\n\n";

## Listing the authentication protocols supported by the server

    use Mail::Sender;
    my $sender = Mail::Sender->new({smtp => 'localhost'});
    die "Error: $Mail::Sender::Error\n" unless ref $sender;
    print join(', ', $sender->QueryAuthProtocols()),"\n";

or (if you have Mail::Sender 0.8.05 or newer)

    use Mail::Sender;
    print join(', ', Mail::Sender->QueryAuthProtocols('localhost')),"\n";

or

    use Mail::Sender;
    print join(', ', Mail::Sender::QueryAuthProtocols('localhost')),"\n";

## FAQ

### Forwarding the messages created by Mail::Sender removes accents. Why?

The most likely culprit is missing or incorrect charset specified for the body or
a part of the email. You should add something like

    charset => 'iso-8859-1',
    encoding => 'quoted-printable',

to the parameters passed to Open(), OpenMultipart(), MailMsg(), Body() or Part() or

    b_charset => 'iso-8859-1',
    b_encoding => 'quoted-printable',

to the parameters for MailFile().

If you use a different charset ('iso-8859-2', 'win-1250', ...) you will of course need
to specify that charset. If you are not sure, try to send a mail with some other mail client
and then look at the message/part headers.

## Sometimes there is an equals sign at the end of an attached file when
I open the email in Outlook. What's wrong?

Outlook is. It has (had) a bug in its quoted printable decoding routines.
This problem happens only in quoted-printable encoded parts on multipart messages.
And only if the data in that part do not end with a newline. (This is new in 0.8.08, in older versions
it happened in all QP encoded parts.)

The problem is that an equals sign at the end of a line in a quoted printable encoded text means
"ignore the newline". That is

    fooo sdfg sdfg sdfh dfh =
    dfsgdsfg

should be decoded as

    fooo sdfg sdfg sdfh dfh dfsgdsfg

The problem is at the very end of a file. The part boundary (text separating different
parts of a multipart message) has to start on a new line, if the attached file ends by a newline everything is cool.
If it doesn't I need to add a newline and to denote that the newline is not part of the original file I add an equals:

    dfgd dsfgh dfh dfh dfhdfhdfhdfgh
    this is the last line.=
    --message-boundary-146464--

Otherwise I'd add a newline at the end of the file.
If you do not care about the newline and want to be sure Outlook doesn't add the equals to the file add

    bypass_outlook_bug => 1

parameter to `new Mail::Sender` or `Open`/`OpenMultipart`.

## WARNING

DO NOT mix Open(Multipart)|Send(Line)(Ex)|Close with MailMsg or MailFile.
Both Mail(Msg/File) close any Open-ed mail.
Do not try this:

    $sender = Mail::Sender->new(...);
    $sender->OpenMultipart...;
    $sender->Body;
    $sender->Send("...");
    $sender->MailFile({file => 'something.ext');
    $sender->Close;

This WON'T work!!!

## GOTCHAS

### Local user "someone@somewhere.com" doesn't exist

"Thanks" to spammers mail servers usually do not allow just anyone to post a message through them.
Most often they require that either the sender or the recipient is local to the server

### Mail::Sendmail works, Mail::Sender doesn't

If you are able to connect to the mail server and scripts using Mail::Sendmail work, but Mail::Sender fails with
"connect() failed", please review the settings in /etc/services. The port for SMTP should be 25.

### $/ and $\\

If you change the $/ ($RS, $INPUT\_RECORD\_SEPARATOR) or $\\ ($ORS, $OUTPUT\_RECORD\_SEPARATOR)
or $, ($OFS, $OUTPUT\_FIELD\_SEPARATOR) Mail::Sender may stop working! Keep in mind that those variables are global
and therefore they change the behaviour of <> and print everywhere.
And since the SMTP is a plain text protocol if you change the notion of lines you can break it.

If you have to fiddle with $/, $\\ or $, do it in the smallest possible block of code and local()ize the change!

    open my $IN, '<', $filename or die "Can't open $filename: $!\n";
    my $data = do {local $/; <$IN>};
    close $IN;

# BUGS

I'm sure there are many. Please let me know if you find any.

The problem with multiline responses from some SMTP servers (namely qmail) is solved. At last.

# SEE ALSO

MIME::Lite, MIME::Entity, Mail::Sendmail, Mail::Mailer, ...

There are lots of mail related modules on CPAN, with different capabilities and interfaces. You
have to find the right one yourself :-)

# DISCLAIMER

This module is based on SendMail.pm Version : 1.21 that appeared in
Perl-Win32-Users@activeware.com mailing list. I don't remember the name
of the poster and it's not mentioned in the script. Thank you, Mr. `undef`.

# AUTHOR

Jan Krynicky <Jenda@Krynicky.cz>
http://Jenda.Krynicky.cz

With help of Rodrigo Siqueira <rodrigo@insite.com.br>,
Ed McGuigan <itstech1@gate.net>,
John Sanche <john@quadrant.net>,
Brian Blakley <bblakley@mp5.net>,
and others.

# COPYRIGHT

Copyright (c) 1997-2014 Jan Krynicky <Jenda@Krynicky.cz>. All rights reserved.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

You are discouraged from using this module for sending SPAM! (see
http://spam.abuse.net/ for definition). It is unethical and, in many
jurisdictions, illegal.
