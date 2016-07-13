package Test::MS_SMTPWithAuth;

use strict;
use warnings;
use Carp;
use Data::Dumper::Concise;
use base qw(Net::Server::Mail::SMTP);

sub init {
    my ( $self, @args ) = @_;
    my $rv = $self->SUPER::init(@args);
    return $rv unless $rv eq $self;
    $self->{kill} = 0;
    $self->def_verb( EHLO => 'ehlo' );
    $self->def_verb( AUTH => 'auth' );
    $self->set_callback(RCPT => \&_validate_recipient);
    $self->set_callback(DATA => \&_queue_message);

    return $self;
}

sub killme {
    return shift->{kill};
}

sub get_protoname {
    return 'ESMTP';
}

sub _auth_login_pass {
    my ($self, $pass) = @_;
    return unless $pass;
    $pass =~ s/^\s*//;
    $pass =~ s/\s*$//;
    if ($pass eq 'd2hhdA==') {
        $self->reply(235, 'ok, go ahead (#2.0.0)');
        return;
    }
    return ( 535 );
}

sub _auth_login_username {
    my ($self, $user) = @_;
    return unless $user;
    $user =~ s/^\s*//;
    $user =~ s/\s*$//;
    if ($user eq 'd2hv') {
        $self->make_event(
            name       => 'AUTH',
            arguments  => [],
            on_success => sub {
                $self->next_input_to(\&_auth_login_pass);
            },
            success_reply => [ 334, 'UGFzc3dvcmQ6'],
        );
        return;
    }
    return ( 535 );
}

sub _auth_plain {
    my ($self, $creds) = @_;
    return unless $creds;
    $creds =~ s/^\s*//;
    $creds =~ s/\s*$//;
    if ($creds eq 'AHdobwB3aGF0') {
        $self->reply(235, 'ok, go ahead (#2.0.0)');
        return;
    }
    elsif ($creds eq 'AGtpbGwAbWU=') {
        $self->{kill} = 1;
        $self->reply(235, 'ok, go ahead (#2.0.0)');
        return;
    }
    return ( 535 );
}

sub _validate_recipient {
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

sub _queue_message {
    my($session, $data) = @_;

    my $sender = $session->get_sender();
    my @recipients = $session->get_recipients();

    return(0, 554, 'Error: no valid recipients')
        unless(@recipients);

    # my $msgid = add_queue($sender, \@recipients, $data) or return(0);

    return(1, 250, "message queued from $sender");
}

sub auth {
    my ($self, $auth_type) = @_;
    unless ( defined $auth_type && length $auth_type ) {
        $self->reply( 501, 'Syntax error in parameters or arguments' );
        return;
    }
    $auth_type = uc($auth_type);
    if ($auth_type eq 'PLAIN') {
        $self->make_event(
            name       => 'AUTH',
            arguments  => [],
            on_success => sub {
                $self->next_input_to(\&_auth_plain);
            },
            success_reply => [ 334, ],
        );
        return;
    }
    elsif ($auth_type eq 'LOGIN') {
        $self->make_event(
            name       => 'AUTH',
            arguments  => [],
            on_success => sub {
                $self->next_input_to(\&_auth_login_username);
            },
            success_reply => [ 334, 'VXNlcm5hbWU6'],
        );
        return;
    }
    return;
}

sub ehlo {
    my ( $self, $hostname ) = @_;
    unless ( defined $hostname && length $hostname ) {
        $self->reply( 501, 'Syntax error in parameters or arguments' );
        return;
    }
    my $response = $self->get_hostname . ' Service ready';
    $self->make_event(
        name       => 'EHLO',
        arguments  => [ $hostname, ['AUTH', 'auth'] ],
        on_success => sub {

            # according to the RFC, EHLO ensures "that both the SMTP client
            # and the SMTP server are in the initial state"
            $self->step_reverse_path(1);
            $self->step_forward_path(0);
            $self->step_maildata_path(0);
        },
        success_reply => [ 250, [ $response, ('AUTH PLAIN LOGIN') ] ],
    );

    return;
}

sub helo {
    my ( $self, $hostname ) = @_;
    $self->SUPER::helo($hostname);
}

1;
