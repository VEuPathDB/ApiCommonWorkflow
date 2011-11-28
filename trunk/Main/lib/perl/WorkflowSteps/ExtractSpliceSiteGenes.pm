package ApiCommonWorkflow::Main::WorkflowSteps::ExtractSpliceSiteGenes;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $configFile = $self->getParamValue('configFile');
  my $outputUniqFile = $self->getParamValue('outputUniqFile');
  my $outputNonUniqFile = $self->getParamValue('outputNonUniqFile');
  my $genomeExtDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');

  my $workflowDataDir = $self->getWorkflowDataDir();


  my $cmd="extractSpliceSiteGenes --uniqFile $workflowDataDir/$outputUniqFile --nonUniqFile $workflowDataDir/$outputNonUniqFile --configFile $workflowDataDir/$configFile";

  $cmd .= " --genomeExtDbRlsSpec '$genomeExtDbRlsSpec'" if $genomeExtDbRlsSpec;

    if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputUniqFile");
      $self->runCmd(0, "rm -f $workflowDataDir/$outputNonUniqFile");
    } else {
	if ($test) {
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputNonUniqFile");
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputUniqFile");
	}else{
	    $self->runCmd($test,$cmd);
	}
    }
}
  
sub getParamsDeclaration {
  return (
	  'configFile',
	  'outputUniqFile',
	  'outputNonUniqFile',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


