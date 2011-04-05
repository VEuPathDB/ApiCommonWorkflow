package ApiCommonWorkflow::Main::WorkflowSteps::ReformatChIPChipSmoothedProfiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');

  my $outputFile =  $self->getParamValue('outputFile');

  my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "reformatChIP-ChipSmoothedProfiles.pl  --inputFile $workflowDataDir/$inputFile --aefExtDbSpec '$extDbRlsSpec'> $workflowDataDir/$outputFile";

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
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

