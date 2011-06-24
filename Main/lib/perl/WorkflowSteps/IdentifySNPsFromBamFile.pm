package ApiCommonWorkflow::Main::WorkflowSteps::IdentifySNPsFromBamFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $genomicSeqsFile = $self->getParamValue('genomicSeqsFile');

  my $bamFile = $self->getParamValue('bamFile');

  my $outputFile =  $self->getParamValue('outputFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $varScanJarFile = $self->getConfig('varScanJarFile');

  my $samtoolsPath = $self->getConfig('samtoolsPath');

  my $cmd = "identifySNPsFromBamFile.pl --genomeFastaFile $workflowDataDir/$genomicSeqsFile --varScanJarFile $varScanJarFile --bamFile $workflowDataDir/$bamFile --samtoolsPath $samtoolsPath";

  
  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  }else {
      if ($test){
	  $self->runCmd(0, "echo test > $workflowDataDir/$outputFile");
      }else{
	    $self->runCmd($test, $cmd);
      }
  }

}

sub getParamDeclaration {
  return (
	  'inputFile',
	  'genomicSeqsFile',
	  'bamFile',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

