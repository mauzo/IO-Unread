use Module::Build;

Module::Build->new(
    module_name     => "IO::Unread",
    license         => "perl",
    include_dirs    => ".",
    meta_merge      => {
        resources => {
            repository => "http://github.com/mauzo/IO-Unread",
        },
    },
)->create_build_script;
