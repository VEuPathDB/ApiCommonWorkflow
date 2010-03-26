 package ApiCommonWorkflow::Main::WorkflowSteps::FormatNcbiBlastFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use File::Basename;

sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $outputBlastDbDir = $self->getParamValue('outputBlastDbDir');
  my $formatterArgs = $self->getParamValue('formatterArgs');


  my $ncbiBlastPath = $self->getConfig('ncbiBlastPath');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my ($filename, $relativeDir) = fileparse($inputFile);

  my $fileToFormat = "$workflowDataDir/$inputFile";

  if ($outputBlastDbDir ne $relativeDir) {
    $fileToFormat = "$workflowDataDir/$outputBlastDbDir/$filename";
  }

  if ($undo) {
    if ($outputBlastDbDir ne $relativeDir) {
      $self->runCmd(0,"rm -f $fileToFormat");
    }
    $self->runCmd(0, "rm -f ${fileToFormat}.p*");
  } else {
      if ($outputBlastDbDir ne $relativeDir) {
	  $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
	  $self->runCmd(0,"ln -s $workflowDataDir/$inputFile $fileToFormat");
      }
      if ($test) {
	  $self->runCmd(0,"echo test > $workflowDataDir/$outputBlastDbDir/format.pin");
      }else {
	  $self->runCmd($test,"$ncbiBlastPath/formatdb -i $fileToFormat -p $formatterArgs");
      }
  }
}

sub getParamsDeclaration {
  return ('inputFile',
	  'formatterArgs'
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	  ['ncbiBlastPath', "", ""],
	 );
}


