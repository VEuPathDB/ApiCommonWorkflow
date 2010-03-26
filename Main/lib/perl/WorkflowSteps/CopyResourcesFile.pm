package ApiCommonWorkflow::Main::WorkflowSteps::CopyResourcesFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $resourcesFile = $self->getParamValue('resourcesFile');
  my $toFile = $self->getParamValue('toFile');

  # get global properties
  my $downloadDir = $self->getGlobalConfig('downloadDir');

  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$toFile");
  } else {
      if ($test) {
	  if ($resourcesFile =~/\*/){#if file name contains wild character 
	     my($directory, $filename) = $resourcesFile =~ m/(.*\/)(.*)$/;
	     $self->testInputFile('resourcesFile',"$filename","$downloadDir/$directory");	  
	  }else{
	      $self->testInputFile('resourcesFile', "$downloadDir/$resourcesFile");
	  }
	  $self->runCmd(0,"echo test > $workflowDataDir/$toFile");
      }else{
	  $self->runCmd(0, "gunzip $downloadDir/$resourcesFile.gz") if (-e "$downloadDir/$resourcesFile.gz");
	  $self->runCmd($test, "cp $downloadDir/$resourcesFile $workflowDataDir/$toFile");
      }
  }
}

sub getParamsDeclaration {
  return (
          'resourcesFile',
          'toFile',
         );
}

sub getConfigDeclaration {
  return (
         # [name, default, description]
         # ['', '', ''],
         );
}


