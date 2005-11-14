package SeqMisc;
use strict;

sub new {
  my ($class, %arg) = @_;
  $arg{sequence} = [] if (!defined($arg{sequence}));
  srand();
  my $me = bless {
				  nt => {0 => 'A', 1 => 'U', 2 => 'C', 3=> 'G',},
				  sequence => $arg{sequence},
				  length => scalar(@{$arg{sequence}}),
				  aaseq => [],
				  dint12seq => [],
				  dint23seq => [],
				  dint31seq => [],
				  dint13seq => [],
				  codonseq => [],
				  readop => defined($arg{readop}) ? $arg{readop} : 'straight',
				  ntfreq => {},
				  dintfreq => {},
				  codonfreq => {},
				  codons => {
		 A => [['GCA', 'GCC', 'GCG', 'GCU'], ['Ala', 'Alanine' ]],
		 GCA => 'A', GCC => 'A', GCG => 'A', GCU => 'A',
		 C => [['UGC', 'UGU'],['Cys', 'Cysteine' ]],
		 UGC => 'C', UGU => 'C',
		 D => [['GAC', 'GAU'],['Asp', 'Aspartic Acid' ]],
		 GAC => 'D', GAU => 'D',
		 E => [['GAA', 'GAG'], ['Glu', 'Glutamic Acid' ]],
		 GAA => 'E', GAG => 'E',
		 F => [['UUC', 'UUU'], ['Phe', 'Phenylalanine']],
		 UUC => 'F', UUU => 'F',
		 G => [['GGA', 'GGC', 'GGG', 'GGU'], ['Gly', 'Glycine']],
		 GGA => 'G', GGC => 'G', GGG => 'G', GGU => 'G',
		 H => [['CAC', 'CAU'], ['His', 'Histidine']],
		 CAC => 'H', CAU => 'H',
		 I => [['AUA', 'AUC', 'AUU'], ['Ile', 'Isoleucine']],
		 AUA => 'I', AUC => 'I', AUU => 'I',
		 K => [['AAA', 'AAG'], ['Lys', 'Lysine']],
		 AAA => 'K', AAG => 'K',
		 L => [['UUA', 'UUG', 'CUA', 'CUC', 'CUG', 'CUU'], ['Leu', 'Leucine']],
		 UUA => 'L', UUG => 'L', CUA => 'L', CUC => 'L', CUG => 'L', CUU => 'L',
		 M => [['AUG'], ['Met', 'Methionine']],
		 AUG => 'M',
		 N => [['AAC', 'AAU'], ['Asn', 'Asparagine']],
		 AAC => 'N', AAU => 'N',
		 P => [['CCA', 'CCC', 'CCG', 'CCU'], ['Pro', 'Proline']],
		 CCA => 'P', CCC => 'P', CCG => 'P', CCU => 'P',
		 Q => [['CAA', 'CAG'], ['Gln', 'Glutamine']],
		 CAA => 'Q', CAG => 'Q',
		 R => [['CGA', 'CGC', 'CGG', 'CGU', 'AGG', 'AGA'], ['Arg', 'Arginine']],
		 CGA => 'R', CGC => 'R', CGG => 'R', CGU => 'R', AGG => 'R', AGA => 'R',
		 S => [['UCA', 'UCC', 'UCG', 'UCU', 'ACG', 'AGU', 'AGC'], ['Ser', 'Serine']],
		UCA => 'S', UCC => 'S', UCG => 'S', UCU => 'S',  ACG => 'S', AGU => 'S', AGC=> 'S',
		 T => [['ACA', 'ACC', 'ACG', 'ACU'], ['Thr', 'Threonine']],
		 ACA => 'T', ACC => 'T', ACG => 'T', ACU => 'T',
		 V => [['GUA', 'GUC', 'GUG', 'GUU'], ['Val', 'Valine']],
		 GUA => 'V', GUC => 'V', GUG => 'V', GUU => 'V',
		 W => [['UGG'], ['Trp', 'Tryptophan']],
		 UGG => 'W',
		 Y => [['UAC', 'UAU'], ['Tyr', 'Tyrosine']],
		 UAC => 'Y', UAU => 'Y',
		 '*' => [['UAA', 'UGA', 'UAG'], ['Ter', 'Termination']],
		 UAA => '*', UGA => '*', UAG => '*',
							},
				 }, $class;
  #  print "TEST: $me->{readop}\n";
  my @ntseq = @{$me->{sequence}};
  #  print "TEST: $length\n";
  my (@aaseq, @codonseq, @dint12seq, @dint23seq, @dint31seq, @dint13seq);
  if ($me->{readop} eq 'orf') {
	my @init = ('A', 'T', 'G');
	next until (splice(@ntseq, 0, 3) eq @init);
  }

  my $finished = 0;
  my $count = 0;
  while (scalar(@ntseq) > 2 and $finished == 0) {
	$count = $count + 3;
	$me->{dintfreq}{12}{join('', $ntseq[0], $ntseq[1])}++;
	$me->{dintfreq}{23}{join('', $ntseq[1], $ntseq[2])}++;
	$me->{dintfreq}{13}{join('', $ntseq[0], $ntseq[2])}++;
	if ($count == $me->{length}) {
	  $me->{dintfreq}{31}{join('', $ntseq[2], '*')}++;
	}
	else {
	  $me->{dintfreq}{31}{join('', $ntseq[2], $ntseq[3])}++;
	}
	my ($one, $two, $three) = splice(@ntseq, 0, 3);
	my $codon_string = join('', $one, $two, $three);
	if (!defined($me->{codons}{$codon_string})) {
	  print "$codon_string is not defined!\n";
	}
	push(@aaseq, $me->{codons}{$codon_string});
	push(@codonseq, $codon_string);
	push(@dint12seq, join('', $one, $two));
	push(@dint23seq, join('', $two, $three));
#	push(@dint13seq, join('', $one, $ntseq[0]));
	($count == $me->{length})    ?
	  push(@dint31seq, join('', $three, '*'))   :
		push(@dint31seq, join('', $three, $ntseq[0]));
	$me->{codonfreq}{$codon_string}++;
	$me->{ntfreq}{$one}++;
	$me->{ntfreq}{$two}++;
	$me->{ntfreq}{$three}++;

	$finished++ if ($me->{readop} eq 'orf' and ($me->{codons}{$codon_string} eq '*'));
  }  ## End while the length of sequence > 2
  $me->{aaseq} = \@aaseq;
  $me->{codonseq} = \@codonseq;
  $me->{dint12seq} = \@dint12seq;
  $me->{dint23seq} = \@dint23seq;
  $me->{dint31seq} = \@dint31seq;
  $me->{dint13seq} = \@dint13seq;

  while (scalar(@ntseq) > 0) {
	my $nt = shift @ntseq;
	$me->{ntfreq}{$nt}++;
	$count++;
  }
  return($me);
}

###  Pick random nucleotides to replace our sequence, keep picking if you choose a stop codon.
sub Random {
  my $me = shift;
  my @seq = @{$me->{sequence}};
  my @return = ();
  my $count = 0;
  my $codon_count = 0;
  while (scalar(@seq) > 0) {
	shift @seq;
	$return[$count] = $me->{nt}->{int(rand(4))};

	## Avoid premature termination codons using the codon table of interest.
	if ($codon_count == 2) {
	  my $test = $return[$count - 2] . $return[$count - 1] . $return[$count];
	  my $fun = $me->{codons}->{$test};
#	  print "Please tell me $test and $count and $fun\n";
	  while ($me->{codons}->{$test} eq '*') {
#		print "Stop codon! $fun";
		$return[$count - 2] = $me->{nt}->{int(rand(4))};
		$return[$count - 1] = $me->{nt}->{int(rand(4))};
		$return[$count] = $me->{nt}->{int(rand(4))};
		$test = join('', $return[$count - 2], $return[$count - 1], $return[$count]);
#		print "Now it is $test\n";
	  }  ## End while we have a ptc
	}    ## End codon check.
	($codon_count == 2) ? $codon_count = 0 : $codon_count++;
	$count++;
  }  ## End top level while
	return(\@return);
}


###  Shuffle the codons, maintain codon frequencies.
sub SameCodons {
  my $me = shift;
  my @codons = @{$me->{codonseq}};
  my @return;
  while (scalar(@codons) > 0) {
#	my $left = scalar(@codons);
#	print "TEST: $left\n";
	my $pull = int(rand(scalar(@codons)));
	my ($first, $second, $third) = split(//, $codons[$pull]);
	push(@return, $first, $second, $third);
#	push(@return, $codons[$pull]);
	splice(@codons, $pull, 1);
  }
  return(\@return);
}

sub Same31Random {
  my $me = shift;
  my @dint31seq = @{$me->{dint31seq}};
  my @return;

  my ($third, $first) = undef;
  while (scalar(@dint31seq) > 0) {

	#  The first nucleotide in the codon, checking if we are starting or ending.
	if (defined($first)) {  ## Not at the beginning of the sequence?
	  if ($first eq '*') {      ## Maybe at the end?
		return(\@return);  ## If so, drop out
	  }
	  else {  ## If not at the end push the first
		push(@return, $first);
	  }
	}  ## End the if not at the beginning of the sequence
	else {  ## at the beginning add a random nucleotide at position 1.
	  push(@return, $me->{nt}->{int(rand(4))});
	}


#	!defined($first)    ?   ## 1st nucleotide in the sequence?
#	  push(@return, $me->{nt}->{int(rand(4))})    :   ## yes
#		($first eq '*')    ?  ## End of sequence?
#		  return(\@return)    :  ## yes
#			push(@return, $first);  ## no

	#  The second nucleotide in the codon
	push(@return, $me->{nt}->{int(rand(4))});
	#  The third nucleotide in the codon
	####  Why do I do the shift here?  Think about the recreation of the nucleotide sequence
	####  for a moment in terms of the first codon and you will see :)
	($third, $first) = split(//, shift(@dint31seq));
	push(@return, $third);
  }  ## End while.
  return(\@return);
}

####  SameDint takes two args: saved_positions and freq_positions
##  saved_positions defines positions which must remain the exact same
##   from parent to child sequence.
##  freq_positions are positions which must maintain the same frequencies
##   from parent to child sequence -- thus shuffled
##  So if I call SameDint(['12'], undef) then I want the first two nucleotides
##   every codon to remain the same from parent to child, all else is randomized.
##  If I call SameDint(undef, ['12','23','31']) I want to maintain all codon dinucleotide frequencies.
sub SameDint {
 my $me = shift;
 my $saved_positions = shift;
 my $freq_positions = shift;
 ## The parent dinucleotide sequences
 my @onetwo = @{$me->{dintseq}{12}};
 my @twothree = @{$me->{dintseq}{23}};
 my @threeone = @{$me->{dintseq}{31}};
				
 my @return;
 my $count = 0;
 my $rotate = 0;
# while (scalar(@dint) > 0) {
#   if ($rotate == 1) {
#	 my @tmp;
#	 if ($saved_positions->[0] eq '12') {
#	   @tmp = split(//, shift @onetwo);
#	 }
#	 elsif ($freq_positions->[0] eq '12') {
#	   @tmp = split(//, splice(@onetwo, int(rand(scalar(@onetwo)))));
#	 }
#	 else {
#	   shift @onetwo;
#	   push(@tmp, $me->{nt}->{int(rand(4))});
#	   push(@tmp, $me->{nt}->{int(rand(4))});
#	   }
#	 $rotate++;
#   }
#   }  ## End top level while
#	my $pull = int(rand(scalar(@dint)));
#	my ($one, $two) = split(//, $dint[$pull]);
#	push(@return, $one, $two);
#	splice(@dint, $pull, 1);
#  }
  return(\@return);
}


###  Maintain amino acid frequencies but choose a random codon from those
###   available for each amino acid.
sub Sameaa {
 my $me = shift;
 my $aaref = shift;
 my @aaseq = @{$aaref};
 my @return = ();
 while (scalar(@aaseq) > 0) {
   my $aa = shift @aaseq;
#   my $newaa = $me->{codons}->{$aa}->[0]->[int(rand(scalar(@{$me->{codons}->{$aa}->[0]})))];
#   my @tmp = split(//, $newaa);
   my ($first, $second, $third) = split(//, $me->{codons}->{$aa}->[0]->[int(rand(scalar(@{$me->{codons}->{$aa}->[0]})))]);
   push(@return, $first, $second, $third);
 }
 return(\@return);
}



## Step 1:  Acquire a sequence to randomize
## Step 2:  pick an amino acid to consider out of pool of amino acids not yet considered.
## Step 3:  Choose two random codons in the sequence which code for this amino acid.
##   "Consider the consequences of swapping the 1st and jth codons."
##  Make the swap if the 1,3 dinucleotides do not change after the swap.
##  If they do change, make a list of all reciprocal swaps remaining, pick one at random, make both swaps.
##  Mark both pairs as 'swapped'
##  Recurse for all other codons for all amino acids.


sub Same31Composite {
  my $me = shift;
  my @dint31seq = @{$me->{dint31seq}};
  my @aminos = @{$me->{aaseq}};
  my @codons;

  my $first = undef;
  my ($third) = split(//, $dint31seq[0]);
  while (scalar(@dint31seq) > 0) {
	my $aa = shift @aminos;
	#  The first nucleotide in the codon, checking if we are starting or ending.
	!defined($first)    ?   ## 1st nucleotide in the sequence?
	  push(@codons, $me->Find_Alternates($aa, "..$third"))    :  ## yes
		($first eq '*')    ?  ## End of sequence?
		  return(\@codons)    :  ## yes
			push(@codons, $me->Find_Alternates($aa, "$first.$third"));
#			push(@codons, $first);  ## no
	#  The second nucleotide in the codon
#	push(@codons, $me->Find_Alternates($aa, "$first.$third"));
	#  The third nucleotide in the codon
	####  Why do I do the shift here?  Think about the recreation of the nucleotide sequence
	####  for a moment in terms of the first codon and you will see :)
	($third, $first) = split(//, shift(@dint31seq));
  }  ## End while.
  return(\@codons);
}

sub Find_Alternates {
  my $me = shift;
  my $amino = shift;
  my $spec = shift;
  my @return = ();
  my $starters = $me->{codons}->{$amino}->[0];  ### An array reference like ['GCA','GCC','GCG','GCU']
  return($starters) if ($spec eq '...');
  my ($dumbone, $dumbtwo, $dumbthree) = split(//, $spec);
  if ($dumbtwo eq '.' and $dumbone eq '.') {
	foreach my $codon (@{$starters}) {
	  my ($one, $two, $three) = split(//, $codon);
	  push(@return, $codon) if ($dumbthree eq $three);
	}
  }
  elsif ($dumbtwo eq '.') {
	foreach my $codon (@{$starters}) {
	  my ($one, $two, $three) = split(//, $codon);
	  push(@return, $codon) if ($dumbthree eq $three and $dumbone eq $one);
	}
  }
  else {
	print "What!?\n";
  }
  return(\@return);
}


sub Translate {
  my $me = shift;
  my $sequence = shift;
  $sequence =~ tr/atgcT/AUGCU/;
  if ((! $me->{sequence}) and (!defined($sequence))) {
    die("Nothing to work with");
  }
#  elsif ($me->{sequence} and defined($sequence)) {
#    die("Too much to work with");
#  }
  elsif (defined($sequence)) {
    my @seqtmp = split(//, $sequence);
    my $t = new SeqMisc(sequence => \@seqtmp);
    my $aaseq = join("", @{$t->{aaseq}});
    undef $t;
    return($aaseq);
  }
  else {
    my $aaseq = join("", @{$me->{aaseq}});
    return($aaseq);
  }
}

1;