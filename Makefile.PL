require 5.006;

use strict;
use warnings;

use ExtUtils::MakeMaker;
use File::Spec;

# We want it if we already have it.  That way we skip the block below.
my $need_net_dns = !! eval { require Net::DNS; 1; };

unless ($need_net_dns) {
  my $found_it;
  my $ns = 'nslookup';
  foreach my $path (File::Spec->path) {
    my $file = File::Spec->catfile($path, $ns);
    $found_it = "$file.exe" if ($^O eq 'MSWin32') and -x "$file.exe" and !-d _;
    $found_it = $file if -x $file and !-d _;
  }
  $need_net_dns = ! $found_it;
}

WriteMakefile(
    'NAME'	   => 'Email::Valid',
    'VERSION_FROM' => 'lib/Email/Valid.pm',
    MIN_PERL_VERSION => '5.006',
    'PREREQ_PM'    => {
      'Test::More' => 0,
      'Mail::Address' => 0,
      'Scalar::Util'  => 0, # for blessed()
      ($need_net_dns ? ('Net::DNS' => 0) : ()),
      ((!$need_net_dns and $^O =~ /\AMSWin32|Cygwin\z/)
        ? ('IO::CaptureOutput' => 0)
        : ()
      ),
    },
    META_MERGE => {
        "meta-spec"    => { version => 2 },
        dynamic_config => 1,
    },
);
