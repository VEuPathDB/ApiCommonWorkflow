package ApiCommonWorkflow::Main::WorkflowSteps::ReformatAlignmentFileForInsertNextGenSeqAlignWithSqlLdr;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputUniqueFile = $self->getParamValue('inputUniqueFile');

  my $outputFile =  $self->getParamValue('outputFile');

  my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');

  my $sampleName =  $self->getParamValue('sampleName');


  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "generateAlignmentsFromMultBlocks.pl --filename $workflowDataDir/$inputUniqueFile --sample $sampleName --extDbSpecs $extDbRlsSpec > $workflowDataDir/$outputFile";

  
  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  }else {
      if ($test){
	  $self->runCmd(0, "echo test > $workflowDataDir/$outputFile");
      }else{
	    $self->runCmd($test, $cmdReformat);
      }
  }

}

sub getParamDeclaration {
  return (
	  'inputUniqueFile',
	  'outputFile',
	  'extDbRlsSpec',
	  'sampleName',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

