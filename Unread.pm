package IO::Unread;

use warnings;
use strict;

use Symbol qw/qualify_to_ref/;

our $VERSION = '0.03';

use Inline Config =>
  VERSION => '0.03',
  NAME    => "IO::Unread";

use Inline C => <<'EOC';

ssize_t _unread (SV *rfh, SV *str)
{
        struct io *fh;
        PerlIO    *pio;
        char      *pv;
        STRLEN     len;

        if(!rfh || SVt_RV != SvTYPE(rfh))
                return -1;

        fh = GvIO(SvRV(rfh));
        if(!fh || SVt_PVIO != SvTYPE(fh))
                return -1;

        pio = IoIFP(fh);
        if(!pio)
                return -1;

        if(!str || !(pv = SvPV(str, len)))
                return -1;

        return PerlIO_unread(pio, pv, len);
}

EOC

sub unread (*@) {
    no warnings 'uninitialized';

    $^W = 0;
    my $fh = qualify_to_ref shift, caller;
    $^W = 1;
    my $str = @_ ? join ("", reverse @_) : $_;

    my $rv = _unread $fh, $str;

    $rv < 0  and return undef;
    $rv == 0 and return "0 but true";
    return $rv;
}

sub import {
    no strict 'refs';
    my $call = caller;
    *{"${call}::unread"} = \&unread;
}

42;

=head1 NAME

IO::Unread - push more than one character back onto a filehandle

=head1 SYNOPSIS

    use IO::Unread;

    unread STDIN, "hello world\n";

    $_ = "goodbye";
    unread ARGV;

=head1 DESCRIPTION

C<IO::Unread> exports one function, C<unread>, which will push data back
onto a filehandle. If your perl is built with perlio, any amount can be pushed:
it is stored in a special C<:pending> layer and read back.

=head2 unread FILEHANDLE, LIST

C<unread> unreads LIST onto FILEHANDLE. If LIST is omitted, C<$_> is unread.

Note that C<unread $FH, 'a', 'b'> is equivalent to

  unread $FH, 'a';
  unread $FH, 'b';

, ie. to C<unread $FH, 'ba'> rather than C<unread $FH, 'ab'>.

Also note that C<unread> is always exported into your namespace.

=head1 REQUIREMENTS

C<PerlIO>, C<Inline::C>

=head1 BUGS

Doesn't work without perlio.

=head1 AUTHOR

Copyright (C) 2003 Ben Morrow <ben@morrow.me.uk>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<PerlIO>, L<perlfunc/"ungetc">

=cut
