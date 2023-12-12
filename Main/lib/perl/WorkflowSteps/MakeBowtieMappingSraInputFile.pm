package ApiCommonWorkflow::Main::WorkflowSteps::MakeBowtieMappingSraInputFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $sraInputFile = join("/", $self->getWorkflowDataDir(),  $self->getParamValue("sraInputFile"));
  my $sraQueryString = $self->getParamValue("sraQueryString");

  if ($undo) {
      $self->runCmd(0, "rm $sraInputFile");
  } else {
      if ($test) {
	  $self->runCmd(0,"echo test > $sraInputFile");
      } 
      my @accessions = split(',', $srqQueryString);
      open(F, ">", $sraInputFile) or die "$! :Can't open config file '$sraInputFile' for writing";
      print F "run_accession";
      foreach my $accession (@accessions) {
          print F "$accession";
      }
      close(F);
  }
}

1;
