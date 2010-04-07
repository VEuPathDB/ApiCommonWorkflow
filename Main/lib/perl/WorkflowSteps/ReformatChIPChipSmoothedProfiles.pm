package ApiCommonWorkflow::Main::WorkflowSteps::ReformatChIPChipSmoothedProfiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');

  my $outputFile =  $self->getParamValue('outputFile');

  my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');

  my $genomeExtDbSpec =  $self->getParamValue('genomeExtDbSpec');
   
  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "generateCoveragePlotInputFile.pl  --filename $workflowDataDir/$inputFile --RNASeqExtDbSpecs $extDbRlsSpec --genomeExtDbSpecs $genomeExtDbSpec > $workflowDataDir/$outputFile";

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
	  'inputFileDir',
	  'outputFile',
	  'extDbRlsSpec',
	  'genomeExtDbSpec',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

