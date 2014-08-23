package ApiCommonWorkflow::Main::WorkflowSteps::MakeProbeGeneMappingFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $outputFile = $self->getParamValue('outputFile');
  my $probeExtDbSpec = $self->getParamValue('probeExtDbSpec');
  my $geneExtDbSpec = $self->getParamValue('geneExtDbSpec');
  my $aefSense = $self->getBooleanParamValue('isOneChannel')? 'sense' : 'either';
  my $delimiter = $self->getBooleanParamValue('isOneChannel')? '\\t' : ',';
  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "mapArrayElementsToGenes.pl --aefExtDbSpec '$probeExtDbSpec' --geneExtDbSpec  '$geneExtDbSpec' --aefSense '$aefSense' --outputFile $workflowDataDir/$outputFile --delimiter '$delimiter'";


  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  } else {
      if ($test) {
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
      }
      $self->runCmd($test,$cmd);
  }
}

1;
