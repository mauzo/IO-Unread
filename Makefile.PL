use 5.6.0;
use Inline::MakeMaker;

WriteMakefile(
    NAME		=> 'IO::Unread',
    VERSION_FROM	=> 'Unread.pm',
    PREREQ_PM		=> { 'Inline::C'  => '0.44',
                             'PerlIO'     => '1.00',
                             'Test::More' => '0.46'
                           }, 
    ABSTRACT_FROM       => 'Unread.pm',
    AUTHOR              => 'Ben Morrow <ben@morrow.me.uk>'
);
