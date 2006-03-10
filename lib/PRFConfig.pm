package PRFConfig;
## Time-stamp: <Wed Jan 18 14:54:08 2006 Ashton Trey Belew (abelew@wesleyan.edu)>
use strict;
use AppConfig qw/:argcount :expand/;
require      Exporter;
our @ISA       = qw(Exporter);
our @EXPORT    = qw(PRF_Out PRF_Error config);    # Symbols to be exported by default
#our @EXPORT_OK = qw();  # Symbols to be exported on request
our $VERSION   = 1.00;         # Version number

$ENV{EFNDATA} = "$ENV{HOME}/browser/work";
$ENV{ENERGY_FILE} = "$ENV{HOME}/browser/work/dataS_G.rna";

my $appconfig = AppConfig->new({
                                CASE => 1,
                                CREATE => 1,
                                PEDANTIC => 0,
                                ERROR => \&Go_Away,
                                GLOBAL => {
                                           EXPAND => EXPAND_ALL,
                                           EXPAND_ENV => 1,
                                           EXPAND_UID => 1,
                                           DEFAULT => "<unset>",
                                           ARGCOUNT => 1,
                                          },
                              },
                             );
####
## Set up some reasonable defaults here
####
$PRFConfig::config->{max_struct_length} = 99;
$PRFConfig::config->{do_nupack} = 1;
$PRFConfig::config->{do_pknots} = 1;
$PRFConfig::config->{do_boot} = 1;
$PRFConfig::config->{nupack_nopairs_hack} = 0;
$PRFConfig::config->{arch_specific_exe} = 0;
$PRFConfig::config->{boot_iterations} = 100;
$PRFConfig::config->{boot_mfe_algorithms} = { pknots => \&RNAFolders::Pknots_Boot, nupack => \&RNAFolders::Nupack_Boot, };
$PRFConfig::config->{boot_randomizers} = { array => \&MoreRandom::ArrayShuffle, };
$PRFConfig::config->{db} = 'prfconfigdefault_db';
$PRFConfig::config->{host} = 'prfconfigdefault_host';
$PRFConfig::config->{user} = 'prfconfigdefault_user';
$PRFConfig::config->{pass} = 'prfconfigdefault_pass';
$PRFConfig::config->{INCLUDE_PATH} = 'html/';
$PRFConfig::config->{INTERPOLATE} = 1;
$PRFConfig::config->{POST_CHOMP} = 1;
$PRFConfig::config->{PRE_PROCESS} = 'header';
$PRFConfig::config->{EVAL_PERL} = 0;
$PRFConfig::config->{ABSOLUTE} = 1;
$PRFConfig::config->{slip_site_1} = '^n\{3\}$';
$PRFConfig::config->{slip_site_2} = '^w\{3\}$';
$PRFConfig::config->{slip_site_3} = '^h\{3\}$';
$PRFConfig::config->{slip_site_spacer_min} = 5;
$PRFConfig::config->{slip_site_spacer_max} = 9;
$PRFConfig::config->{stem1_min} = 4;
$PRFConfig::config->{stem1_max} = 20;
$PRFConfig::config->{stem1_bulge} = 0.8;
$PRFConfig::config->{stem1_spacer_min} = 1;
$PRFConfig::config->{stem1_spacer_max} = 4;
$PRFConfig::config->{stem2_min} = 4;
$PRFConfig::config->{stem2_max} = 20;
$PRFConfig::config->{stem2_bulge} = 0.8;
$PRFConfig::config->{stem2_loop_min} = 0;
$PRFConfig::config->{stem2_loop_max} = 3;
$PRFConfig::config->{stem2_spacer_min} = 0;
$PRFConfig::config->{stem2_spacer_max} = 100;
$PRFConfig::config->{using_pbs} = 0;
$PRFConfig::config->{pbs_template} = 'pbs_template';
$PRFConfig::config->{pbs_arches} = 'aix4 irix6 linux';
$PRFConfig::config->{pbs_shell} = '/bin/bash';
$PRFConfig::config->{pbs_memory} = '1600';
$PRFConfig::config->{pbs_cpu} = '1';
$PRFConfig::config->{pbs_partialname} = 'fold';
$PRFConfig::config->{perl} = '/usr/local/bin/perl';
$PRFConfig::config->{daemon_name} = 'folder_daemon.pl';
$PRFConfig::config->{num_daemons} = '20';
$PRFConfig::config->{rnamotif} = 'rnamotif';
$PRFConfig::config->{rmprune} = 'rmprune';
$PRFConfig::config->{pknots} = 'pknots';
$PRFConfig::config->{nupack} = 'Fold.out';
$PRFConfig::config->{nupack_boot} = 'Fold.out.boot';
$PRFConfig::config->{sql_id} = 'int not null auto_incremenent';
$PRFConfig::config->{sql_species} = 'varchar(80)';
$PRFConfig::config->{sql_accession} = 'varchar(40)';
$PRFConfig::config->{sql_genename} = 'varchar(90)';
$PRFConfig::config->{sql_comment} = 'text not null';
$PRFConfig::config->{sql_timestamp} = 'TIMESTAMP ON UPDATE CURRENT_TIMESTAMP DEFAULT CURRENT_TIMESTAMP';
$PRFConfig::config->{sql_timestamp} = 'TIMESTAMP ON UPDATE CURRENT_TIMESTAMP DEFAULT CURRENT_TIMESTAMP';
$PRFConfig::config->{sql_index} = $PRFConfig::config->{sql_id};

my $open = $appconfig->file('prfdb.conf');
my %data = $appconfig->varlist("^.*");
for my $config_option (keys %data) {
#  $PRFConfig::config->{$config_option} = $data{$config_option};
  $PRFConfig::config->{$config_option} = $data{$config_option};
  undef $data{$config_option};
}
$PRFConfig::config->{boot_mfe_algorithms} = eval($PRFConfig::config->{boot_mfe_algorithms});
$PRFConfig::config->{boot_randomizers} = eval($PRFConfig::config->{boot_randomizers});
$PRFConfig::config->{dsn} = "DBI:mysql:database=$PRFConfig::config->{db};host=$PRFConfig::config->{host}";
my $err = $PRFConfig::config->{errorfile};
my $out = $PRFConfig::config->{logfile};
my $error_counter = 0;
$ENV{PATH} = $ENV{PATH} . ':' . $PRFConfig::config->{bindir};

if ($PRFConfig::config->{arch_specific_exe} == 1) {

  ## If we have architecture specific executables, then
  ## They should live in directories named after their architecture
  my @modified_exes = ('rnamotif', 'rmprune', 'pknots', 'zcat');
  open(UNAME, "/usr/bin/env uname -a |");
  ## OPEN UNAME in PRFConfig
  my $arch;
  while (my $line = <UNAME>) {
    chomp $line;
    if ($line =~ /\w/) {
      $arch = $line;
    }
  }
  close(UNAME);
  ## CLOSE UNAME in PRFConfig
  chomp $arch;
  if ($arch =~ /IRIX/) {
    $ENV{PATH} = $ENV{PATH} . ':' . $PRFConfig::config->{bindir} . '/irix';
  }
  elsif ($arch =~ /Linux/) {
    $ENV{PATH} = $ENV{PATH} . ':' . $PRFConfig::config->{bindir} . '/linux';
  }
  elsif ($arch =~ /Darwin/) {
    $ENV{PATH} = $ENV{PATH} . ':' . $PRFConfig::config->{bindir} . '/osx';
  }
  elsif ($arch =~ /AIX/) {
    $ENV{PATH} = $ENV{PATH} . ':' . $PRFConfig::config->{bindir} . '/aix';
  }
  foreach my $exe (@modified_exes) {
    my $dirvar = $exe . '_dir';
    if ($arch =~ /IRIX/) {
      my $dir = $PRFConfig::config->{$dirvar};
      $dir .= '/irix';
      $PRFConfig::config->{$dirvar} = $dir;
      my $exe_path = join('', $dir, '/', $PRFConfig::config->{$exe});
      $PRFConfig::config->{$exe} = $exe_path;
    }
    elsif ($arch =~ /AIX/) {
      my $dir = $PRFConfig::config->{$dirvar};
      $dir .= '/aix';
      $PRFConfig::config->{$dirvar} = $dir;
      my $exe_path = join('', $dir, '/', $PRFConfig::config->{$exe});
      $PRFConfig::config->{$exe} = $exe_path;
    }
    elsif ($arch =~ /Darwin/) {
      my $dir = $PRFConfig::config->{$dirvar};
      $dir .= '/osx';
      $PRFConfig::config->{$dirvar} = $dir;
      my $exe_path = join('', $dir, '/', $PRFConfig::config->{$exe});
      $PRFConfig::config->{$exe} = $exe_path;
    }
    elsif ($arch =~ /Linux/) {
      my $dir = $PRFConfig::config->{$dirvar};
      $dir .= '/linux';
      $PRFConfig::config->{$dirvar} = $dir;
      my $exe_path = join('', $dir, '/', $PRFConfig::config->{$exe});
      $PRFConfig::config->{$exe} = $exe_path;
    }
    else {
      die("Architecture $arch not available.");
    }
  } ## For every modified executable

  if ($arch =~ /IRIX/) {
    $PRFConfig::config->{nupack} .= ".irix";
    $PRFConfig::config->{nupack_boot} .= ".irix";
  }
  elsif ($arch =~ /AIX/) {
    $PRFConfig::config->{nupack} .= ".aix";
    $PRFConfig::config->{nupack_boot} .= ".aix";
  }
  elsif ($arch =~ /Linux/) {
    $PRFConfig::config->{nupack} .= ".linux";
    $PRFConfig::config->{nupack_boot} .= ".linux";
  }
  elsif ($arch =~ /Darwin/) {
    $PRFConfig::config->{nupack} .= ".osx";
    $PRFConfig::config->{nupack_boot} .= ".osx";
  }
}  ## End checking if multiple architectures are in use

sub PRF_Out {
  my $message = shift;
  open(OUTFH, ">>$out") or die "Unable to open the log file $out: $!\n";
  ## OPEN OUTFH in PRF_Out
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
  my $month = $mon + 1;
  my $y = $year + 1900;
  my $datestring = "$hour:$min:$sec $mday/$month/$y";
  print OUTFH "$datestring\t$message\n";
  close(OUTFH);
  ## CLOSE OUTFH in PRF_Out
}

sub PRF_Error {
  my $message = shift;
  my $accession = shift;
  open(ERRFH, ">>$err") or die "Unable to open the log file $err: $!\n";
  ## OPEN ERRFH in PRF_Error
  my $db = new PRFdb;
  $db->Error_Db($message, $accession);
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
  my $month = $mon + 1;
  my $y = $year + 1900;
  my $datestring = "$hour:$min:$sec $mday/$month/$y";
  print ERRFH "$datestring\t$message\n";
  close(ERRFH);
  ## CLOSE ERRFH in PRF_Err
}

sub Go_Away {
  return();
}


1;

