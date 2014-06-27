package ApiCommonWorkflow::Main::WorkflowSteps::RunMercatorMavid;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $mercatorInputsDir = $self->getParamValue('mercatorInputsDir'); # holds lots of .gff and .fasta files
  my $mercatorOutputDir = $self->getParamValue('mercatorOutputDir');

  my $cndSrcBin = $self->getConfig('cndSrcBin');
  my $mavid = $self->getConfig('mavidExe');

  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
    $self->runCmd(0, "rm -fr $workflowDataDir/$mercatorOutputDir");
    return;
  }

  my @organismAbbrevs = $self->findOrganismAbbrevs("$workflowDataDir/$mercatorInputsDir"); # tests .fasta and .gff existence

  if (scalar(@organismAbbrevs) == 1) {
      $self->log("Only found 1 organism in input dir $workflowDataDir/$mercatorInputsDir.  No comparision needed.  Exiting.");
      return;
  }

  my $isDraftHash = $self->getIsDraftHash(\@organismAbbrevs,$test); # hash of 0/1 for each organism

  $self->runCmd(0, "rm -r $workflowDataDir/$mercatorOutputDir") if -e "$workflowDataDir/$mercatorOutputDir";

  mkdir("$workflowDataDir/$mercatorOutputDir") || $self->error("Could not make dir '$workflowDataDir/$mercatorOutputDir'\n");

  mkdir("$workflowDataDir/$mercatorOutputDir/fasta") || $self->error("Could not make dir '$workflowDataDir/$mercatorOutputDir/fasta'\n");

  mkdir("$workflowDataDir/$mercatorOutputDir/gff") || $self->error("Could not make dir '$workflowDataDir/$mercatorOutputDir/gff'\n");

  # copy inputs to output dir, as runMercator writes its output to its input dir
  $self->runCmd(0, "cp -r $workflowDataDir/$mercatorInputsDir/*.fasta $workflowDataDir/$mercatorOutputDir/fasta");
  $self->runCmd(0, "cp -r $workflowDataDir/$mercatorInputsDir/*.gff $workflowDataDir/$mercatorOutputDir/gff");


  my @dashT;
  my @dashDorN;
  foreach my $org (@organismAbbrevs) {
    push(@dashT, "$org");
    my $draftFlag = $isDraftHash->{$org}? '-d' : '-n';

    push(@dashDorN, "$draftFlag $org");
  }

  my $start = shift @dashT;
  my $t = &makeTree($start, \@dashT);

  my $dn = join(' ', @dashDorN);
  my $command = "runMercator  -t '($t);' -p $workflowDataDir/$mercatorOutputDir -c $cndSrcBin -m $mavid $dn";
  $self->runCmd($test,$command);

  $self->runCmd(0, "mkdir $workflowDataDir/$mercatorOutputDir/mercator-output") if $test;

  # remove input dirs from output dir
  $self->runCmd($test,"rm $workflowDataDir/$mercatorOutputDir/gff/*.gff");
  $self->runCmd($test,"rm $workflowDataDir/$mercatorOutputDir/fasta/*.fasta");
  $self->runCmd($test,"rm $workflowDataDir/$mercatorOutputDir/fasta/*.sdb");
  $self->runCmd($test,"rmdir $workflowDataDir/$mercatorOutputDir/gff");
  $self->runCmd($test,"rmdir $workflowDataDir/$mercatorOutputDir/fasta");

}

sub makeTree {
  my $first = shift;
  my $rest = shift;

  my $second = shift @$rest; ;
  my $baseString = "($first,$second)";

  if(scalar @$rest > 0) {
    $baseString = makeTree($baseString, $rest);
  }
  return $baseString;
}

sub findOrganismAbbrevs {
  my ($self, $mercatorInputsDir) = @_;

  opendir(INPUT, $mercatorInputsDir) or $self->error("Could not open mercator inputs dir '$mercatorInputsDir' for reading.\n");

  my @files = readdir INPUT;
  my %hash;
  my $gffCount;
  foreach my $file (sort(@files)) {
    next if ($file =~ m/^\./);
    if ($file =~ /(\S+)\.fasta$/) {
      $hash{$1} = 1;		# remember this orgAbbrev
    } elsif ($file =~ /(\S+)\.gff$/) { 
      $hash{$1} || $self->error("No matching .fasta file for $mercatorInputsDir/$file");
      $gffCount++;
    } else {
      $self->error("Unexpected file (neither .gff or .fasta): $mercatorInputsDir/$file");
    }
  }
  $self->error("Mismatched number of .fasta and .gff files in $mercatorInputsDir") unless $gffCount == keys(%hash);
  $self->error("Empty mercator inputs dir: $mercatorInputsDir") unless $gffCount;
  return keys(%hash);
}

sub getIsDraftHash {
  my ($self, $organismAbbrevs, $test) = @_;

  my $hash = {};
  foreach my $organismAbbrev (@$organismAbbrevs) {
      my $tmPrefix = $self->getTuningTablePrefix($organismAbbrev, $test);
      my $sql = "select count(*)
                       from apidbtuning.${tmPrefix}sequenceattributes sa, apidb.organism o, sres.sequenceontology so
                       where so.term_name IN ('chromosome', 'supercontig')
                       and sa.so_id = so.so_id
                       and sa.taxon_id = o.taxon_id
                       and o.abbrev = '$organismAbbrev'";
      my $cmd = "getValueFromTable --idSQL \"$sql\"";
      my $isNotDraftGenome = $self->runCmd($test, $cmd);

    $hash->{$organismAbbrev} = !$isNotDraftGenome;
  }
  return $hash;
}

1;
