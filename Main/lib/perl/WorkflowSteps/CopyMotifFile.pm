package ApiCommonWorkflow::Main::WorkflowSteps::CopyMotifFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $inputFile = $self->getParamValue('inputFile');
  my $outputFile = $self->getParamValue('outputFile');

  if($undo) {
    #$self->runCmd(0, "rm -f $outputFile*");
  } else{
      if($test){
	  $self->testInputFile('inputFile', "$inputFile");
	 # $self->testInputFile('outputFile', "$outputFile");
	  $self->runCmd(0, "echo test > $outputFile");
      }else {
	  $self->runCmd($test, "cp $inputFile $outputFile");	   
       }
  }
}

sub getParamsDeclaration {
  return (
          'inputFile',
          'outputDir',
          'args',
          'formattedFileName',
         );
}

sub getConfigDeclaration {
  return (
         # [name, default, description]
         # ['', '', ''],
         );
}

