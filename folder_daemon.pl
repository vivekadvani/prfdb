#! /usr/bin/perl -w
use strict;
use POSIX;
use DBI;

use lib 'lib';
use PRFConfig;
use PRFdb;
use RNAMotif_Search;
use RNAFolders;
use Input;

my $config = $PRFConfig::config;
chdir($config->{basedir});
my $time_to_die = 0;
#chroot($directory) or die "Could not change directory into $directory: $!\n";

my $pid = fork;
exit if $pid;
die "Could not fork: $!\n" unless defined($pid);

POSIX::setsid() or die "Could not start a new process group: $!\n";
$SIG{INT} = $SIG{TERM} = $SIG{HUP} = \&signal_handler;

until ($time_to_die) {
  sleep(2);
  ## Code goes here.
  ## Process:
  # 1.  Open queue file, read last line; gather species, accession, start
  # 1a. Sleep if empty
  # 2.  Rewrite queue file without last line
  # 3.  Query db for existing information on species, accession, start
  # 4.  Next if exists.
  # 4a. Fold via algorithms
  # 5. Fill db

  ## Check queue file.
  my $public_datum = Check_Queue('public');
  if (defined($public_datum)) {  ## The public queue is not empty
    my $existsp = Check_Db($public_datum);
  }
  else {  ## The public queue is empty
    my $private_datum = Check_Queue('private');
    if (defined($private_datum)) {  # The queue is not empty
      my $existsp = Check_Db($private_datum);
    }
    else {  ## Both queues are empty
      sleep(10);
    }
  }  ## End the public queue is empty
}    ## End until it is time to die


sub Check_Queue {
  my $type = shift;
  my $qfile = $type . '_queue';
  my $return = {};
  open (FH, "+<$qfile") or die "can't update queue: $qfile: $!";
  my $addr= undef;
  my $line_bak;
  while (my $line = <FH> ) {
	$addr = tell(FH) unless eof(FH);
	$line_bak = $line;
  }
  return(undef) unless defined($line_bak);
  chomp $line_bak;
  my ($species, $accession) = split(/\t/, $line_bak);
  $return->{species} = $species;
  $return->{accession} = $accession;
  truncate(FH, $addr);
  return($return);
}

sub Check_Db {
  my $datum = shift;
  my $db = new PRFdb;
  my $motifs = new RNAMotif_Search;
  ## First see that there is rna motif information
  my $info = $db->Get_RNAmotif($datum->{species}, $datum->{accession});
  if ($info) {  ## If the motif information _does_ exist, check the folding information
 foreach my $start (keys %{$info}) {  ## For every start site in the sequence
      my $folding = $db->Get_RNAfolds($datum->{species}, $datum->{accession}, $start);
      if ($folding) {  ## Both have motif and folding
        print "HAVE FOLDING AND MOTIF!\n";
        sleep(1);
        return(1);
      }
      else {  ## Do have a motif for the sequence, do not have folding information
        print "HAVE MOTIF, NO FOLDING\n";
        my $filename = $db->Motif_to_Fasta($info->{$start}{filedata});
        my $slippery = $db->Get_Slippery($db->Get_Sequence($datum->{species}, $datum->{accession}), $start);
        my $fold_search = new RNAFolders(file => $filename,
                                       accession => $datum->{accession},
                                       start => $start,
                                       slippery => $slippery,
                                       species => $datum->{species},);
      my $nupack_info = $fold_search->Nupack();
      $db->Put_Nupack($nupack_info);
      unlink($filename);
      } ## End if you have a motif but no folding information
    } ## End recursing over the starts in a given sequence
  }  ## End if there is a motif for this sequence
  else { ## No folding information
    my $sequence = $db->Get_Sequence($datum->{species}, $datum->{accession});
    my $slipsites = $motifs->Search($sequence);
    $db->Put_RNAmotif($datum->{species}, $datum->{accession}, $slipsites);
    print "NO MOTIF, NO FOLDING\n";
    foreach my $start (keys %{$slipsites}) {
      print "STARTING FOLD FOR $start in $datum->{accession}\n";
      my $slippery = $db->Get_Slippery($sequence, $start); 
      my $fold_search = new RNAFolders(file => $slipsites->{$start}{filename},
                                       accession => $datum->{accession},
                                       start => $start,
                                       slippery => $slippery,
                                       species => $datum->{species},);
      my $nupack_info = $fold_search->Nupack();
      $db->Put_Nupack($nupack_info);
      unlink($slipsites->{$start}{filename});
    } ##End checking slipsites for a locus when have not motif nor folding information
  } ## End no motif nor folding information.
}

sub signal_handler {
  $time_to_die = 1;
}
