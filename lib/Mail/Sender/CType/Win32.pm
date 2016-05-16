package Mail::Sender::Win32;

use strict;
use warnings;
use Mail::Sender ();

my $error = do {
    local $@;
    eval {
        require Win32API::Registry;
    };
    $@;
};


unless ( $error ) {
    no strict 'subs';
    no warnings 'redefine';
    import Win32API::Registry qw(RegOpenKeyEx KEY_READ HKEY_CLASSES_ROOT RegQueryValueEx);

    # replace the GuessCType sub with this one!
    *Mail::Sender::GuessCType = sub {
        my $ext = shift;
        $ext =~ s/^.*\././;
        my ($key, $type, $data);
        RegOpenKeyEx(HKEY_CLASSES_ROOT, $ext, 0, KEY_READ, $key)
            or return 'application/octet-stream';
        RegQueryValueEx($key, "Content Type", [], $type, $data, [])
            or return 'application/octet-stream';
        return $data || 'application/octet-stream';
    };
}

1;
