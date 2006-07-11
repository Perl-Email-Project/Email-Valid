use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'	   => 'Email::Valid',
    'VERSION_FROM' => 'lib/Email/Valid.pm', 
    'PREREQ_PM'    => {
      'Mail::Address' => 0,
      (($^O eq 'MSWin32' or $^O eq 'Cygwin')
       ? ('IO::CaptureOutput' => 0)
       : ()
      ),
    },

    'dist'         => { 'COMPRESS'=>'gzip -9f', 'SUFFIX' => 'gz',
                        'ZIP'=>'/usr/bin/zip', 'ZIPFLAGS'=>'-rl' }
);
