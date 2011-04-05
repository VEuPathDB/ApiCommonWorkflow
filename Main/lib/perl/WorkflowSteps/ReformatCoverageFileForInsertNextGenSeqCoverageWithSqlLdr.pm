package ApiCommonWorkflow::Main::WorkflowSteps::ReformatCoverageFileForInsertNextGenSeqCoverageWithSqlLdr;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');

  my $outputFile =  $self->getParamValue('outputFile');

  my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');

  my $genomeExtDbSpec =  $self->getParamValue('genomeExtDbSpec');

  my $sampleName =  $self->getParamValue('sampleName');

  my $multiple =  $self->getParamValue('multiple');
   
  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmdReformat = "generateCoveragePlotInputFile.pl  --filename $workflowDataDir/$inputFile --RNASeqExtDbSpecs '$extDbRlsSpec' --genomeExtDbSpecs '$genomeExtDbSpec' --sample '$sampleName' --multiple $multiple > $workflowDataDir/$outputFile";

  
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
	  'inputFile',
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

