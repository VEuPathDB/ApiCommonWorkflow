package ApiCommonWorkflow::Main::WorkflowSteps::GenerateGenomeMappingGff;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use File::Basename;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputUniqueFile = $self->getParamValue('inputUniqueFile');

  my $inputNonUniqueFile = $self->getParamValue('inputNonUniqueFile');

  my $outputFile =  $self->getParamValue('outputFile');

  my $allowedMismatches =  $self->getParamValue('allowedMismatches');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd1 = "generateProbeGenomeMappingGff  --inputFile $workflowDataDir/$inputUniqueFile --allowedMismatches $allowedMismatches  --outputFile $workflowDataDir/$outputFile.unique";

  my $cmd2 = "generateProbeGenomeMappingGff  --inputFile $workflowDataDir/$inputNonUniqueFile --allowedMismatches $allowedMismatches  --outputFile $workflowDataDir/$outputFile.NonUnique";

  my $cmd3 = "cat  $workflowDataDir/$outputFile.unique  $workflowDataDir/$outputFile.NonUnique > $workflowDataDir/$outputFile";


    
  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile.NonUnique");
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile.unique");
  }else {
      if ($test){
	  $self->runCmd(0, "echo test> $workflowDataDir/$outputFile");
      }else{
	  $self->runCmd($test, $cmd1);
	  $self->runCmd($test, $cmd2);
	  $self->runCmd($test, $cmd3);
      }
  }

}

sub getParamDeclaration {
  return (
	  'inputFile',
	  'outputFile',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

