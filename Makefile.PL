use inc::Module::Install;

name           ('IO-Unread');
author         ('Ben Morrow <IO-Unread@morrow.me.uk>');
version_from   ('lib/IO/Unread.pm');
license        ('perl');

requires       ('perl'       => 5.008);
build_requires ('Inline::C'  => 0.44);
build_requires ('Test::More' => 0.46);

include('ExtUtils::AutoInstall');
auto_install();

&Inline->write;
