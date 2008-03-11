# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 1.t'

#########################

use Test::More tests => 4 + 1 + 4*2 + 1 + 5*3 + 7*2 + 1;
BEGIN { use_ok('IO::Unread', qw/unread/) };

can_ok('IO::Unread', qw/unread _unread/);
can_ok('main', qw/unread/);
is prototype(\&IO::Unread::unread), "*@", 'prototype check';

$\ = "";
$/ = " "; # to avoid any newline problems

{
    open my $OUT, ">test" or die "cannot test: cannot create file: $!";
    binmode $OUT;
    print $OUT "ab " x 5;
}

open my $IN, "<test" or die "cannot test: cannot open test file: $!";

my $rv;

eval { $rv = unread $IN, "" };
ok !$@,                'my() FH (eval)';
is $rv, "0 but true",  "unread nothing";
is <$IN>, "ab ",       "unread nothing (readback)";

$rv = unread $IN, "c";
is $rv, 1,             "unread scalar";
is <$IN>, "cab ",      "unread scalar (readback)";

$rv = unread $IN, "d", "e";
is $rv, 2,             "unread list";
is <$IN>, "edab ",     "unread list (readback)";

$_ = "ff";
$rv = unread $IN;
is $rv, 2,             'unread $_';
is <$IN>, "ffab ",     'unread $_ (readback)';

is <$IN>, "ab ",       'read more new data';

close $IN;

open IN, "<test" or die "cannot test: cannot open test file: $!";

eval { $rv = unread IN, "c" };
ok !$@,          'bare FH (eval)';
is $rv, 1,       'bare FH';
is <IN>, "cab ", 'bare FH (readback)';

eval { $rv = unread *IN, "q" };
ok !$@,          'glob (eval)';
is $rv, 1,       'glob';
is <IN>, "qab ", 'glob (readback)';

eval { $rv = unread \*IN, "d" };
ok !$@,          'globref (eval)';
is $rv, 1,       'globref';
is <IN>, "dab ", 'globref (readback)';

eval { $rv = unread IN => "e" };
ok !$@,          'string FH (eval)';
is $rv, 1,       'string FH';
is <IN>, "eab ",  'string FH (readback)';

close IN;

SKIP: {
    eval { require IO::File };

    skip "You don't have IO::File", 3 unless defined $IO::File::VERSION;

    my $z = new IO::File "test", "r" or die "cannot test: can't open test file: $!";
    
    eval { $rv = unread $z, "c" };
    ok !$@,          'IO::Handle (eval)';
    is $rv, 1,       'IO::Handle';
    is <$z>, "cab ", 'IO::Handle (readback)';
    
    $z->close;
}

no warnings "io";

eval { $rv = unread IN, "a" };
ok !$@,           'closed FH (eval)';
ok !defined($rv), 'closed FH (fail)';

eval { $rv = unread NOTAFH, "a" };
ok !$@,           'undef FH (eval)';
ok !defined($rv), 'undef FH (fail)';

eval { $rv = unread $NOTAFH, "a" };
ok !$@,           'undef scalar (eval)';
ok !defined($rv), 'undef scalar (fail)';

eval { $rv = unread undef };
ok !$@,           'undef (eval)';
ok !defined($rv), 'undef (fail)';

eval { $rv = unread \*NOGLOB, "a" };
ok !$@,           'ref to undef glob (eval)';
ok !defined($rv), 'ref to undef glob (fail)';

my $x = "aaaa";
eval { $rv = unread $x, "a" };
ok !$@,           'stringy scalar (eval)';
ok !defined($rv), 'stringy scalar (fail)';

$x = 42;
eval { $rv = unread $x, "a" };
ok !$@,           'numeric scalar (eval)';
ok !defined($rv), 'numeric scalar (fail)';

my $y = \$x;
eval { $rv = unread $y, "a" };
ok $@,           'ref to scalar (eval)';

open NOTAFH, "<test"; # shut -w up
open NOGLOB, "<test";

unlink "test";
