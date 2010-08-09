package ApiCommonWorkflow::Main::WorkflowSteps::MakeProbeGeneMappingFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $outputFile = $self->getParamValue('outputFile');
  my $aefExtDbSpec = $self->getParamValue('aefExtDbSpec');
  my $geneExtDbSpec = $self->getParamValue('geneExtDbSpec');
  my $aefSense = $self->getParamValue('aefSense');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "mapArrayElementsToGenes.pl --aefExtDbSpec '$aefExtDbSpec' --geneExtDbSpec  '$geneExtDbSpec' --aefSense '$aefSense' --outputFile $workflowDataDir/$outputFile";


  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/tbase-pbase.out");
  } else {
      if ($test) {
      }else{
	  $self->runCmd($test,$cmd);
      }
  }
}

sub getParamDeclaration {
  return (
	  'outputFile',
	  'aefExtDbSpec',
	  'geneExtDbSpec',
	  'aefSense',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

