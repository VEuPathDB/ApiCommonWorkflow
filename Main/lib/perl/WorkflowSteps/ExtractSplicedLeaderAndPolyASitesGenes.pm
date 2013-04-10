package ApiCommonWorkflow::Main::WorkflowSteps::ExtractSplicedLeaderAndPolyASitesGenes;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $type = $self->getParamValue('type');
  my $configFile = $self->getParamValue('configFile');
  my $outputUniqFile = $self->getParamValue('outputUniqFile');
  my $outputNonUniqFile = $self->getParamValue('outputNonUniqFile');
  my $experimentDatasetName = $self->getParamValue('experimentDatasetName');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd;
  my $allowed="'Splice Site' or 'Poly A'";
  if($type eq 'Splice Site'){
        $cmd="extractSpliceSiteGenes --uniqFile $workflowDataDir/$outputUniqFile --nonUniqFile $workflowDataDir/$outputNonUniqFile --configFile $workflowDataDir/$configFile --extDbName $experimentDatasetName";
  }elsif($type eq 'Poly A'){
         $cmd="extractPolyAGenes --uniqFile $workflowDataDir/$outputUniqFile --nonUniqFile $workflowDataDir/$outputNonUniqFile --configFile $workflowDataDir/$configFile --extDbName $experimentDatasetName";
  }else{
      $self->error("Invalide type '$type'. Allowed types are: $allowed");
  }

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
	  'type',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


