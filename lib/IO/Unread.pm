package IO::Unread;

use warnings;
use strict;

use Carp;
use XSLoader;
use Symbol qw/qualify_to_ref/;
use subs qw/_unread/;

our $VERSION = '0.06';

XSLoader::load __PACKAGE__, $VERSION;

sub unread (*@) {
    no warnings 'uninitialized';

    my $fh = do {
        local $^W = 0;
        qualify_to_ref shift, caller;
    };
    my $str = @_ ? (join "", reverse @_) : $_;

    my $rv = eval { _unread $fh, $str };

    if($@) {
        warnings::enabled "io" and carp $@;
	return undef;
    }
    $rv or return "0 but true";
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
onto a filehandle. If your perl is built with perlio layers, any amount 
can be pushed: it is stored in a special C<:pending> layer until read back.

=head2 unread FILEHANDLE, LIST

C<unread> unreads LIST onto FILEHANDLE. If LIST is omitted, C<$_> is unread.
Returns the number of characters unread on success, C<undef> on failure. Warnings 
are produced under category C<io>.

Note that C<unread $FH, 'a', 'b'> is equivalent to

  unread $FH, 'a';
  unread $FH, 'b';

, ie. to C<unread $FH, 'ba'> rather than C<unread $FH, 'ab'>.

Also note that C<unread> is always exported into your namespace.

=head1 BUGS

Doesn't work without perlio.

=head1 AUTHOR

Copyright (C) 2003 Ben Morrow <IO-Unread@morrow.me.uk>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<PerlIO>, L<perlfunc/"ungetc">

=cut
