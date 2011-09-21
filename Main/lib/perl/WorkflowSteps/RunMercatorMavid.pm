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

  my $isDraftHash = $self->getIsDraftHash(\@organismAbbrevs); # hash of 0/1 for each organism

  $self->runCmd(0, "rm -r $workflowDataDir/$mercatorOutputDir") if -e "$workflowDataDir/$mercatorOutputDir";

  # copy inputs to output dir, as runMercator writes its output to its input dir
  $self->runCmd(0, "cp -r $workflowDataDir/$mercatorInputsDir $workflowDataDir/$mercatorOutputDir");


  my @dashT;
  my @dashDorN;
  foreach my $org (@organismAbbrevs) {
    push(@dashT, "$org:0.1");
    my $draftFlag = $isDraftHash->{$org}? '-d' : '-n';

    push(@dashDorN, "$draftFlag $org");
  }
  my $t = join(',', @dashT);
  my $dn = join(' ', @dashDorN);
  my $command = "runMercator  -t '($t);' -p $workflowDataDir/$mercatorOutputDir -c $cndSrcBin -m $mavid $dn";
  $self->runCmd($test,$command);

  # remove input files from output dir
  $self->runCmd($test,"rm $workflowDataDir/$mercatorOutputDir/*.gff");
  $self->runCmd($test,"rm $workflowDataDir/$mercatorOutputDir/*.fasta");

}

sub findOrganismAbbrevs {
  my ($self, $mercatorInputsDir) = @_;

  opendir(INPUT, $mercatorInputsDir) or $self->error("Could not open mercator inputs dir '$mercatorInputsDir' for reading.\n");

  my %hash;
  my $gffCount;
  foreach my $file (readdir INPUT) {
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
  my ($self, $organismAbbrevs) = @_;

  my $hash = {};
  foreach my $organismAbbrev (@$organismAbbrevs) {
    $hash->{$organismAbbrev} = $self->getOrganismInfo($organismAbbrev)->getIsDraftGenome();
  }
  return $hash;
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]

	 );
}
