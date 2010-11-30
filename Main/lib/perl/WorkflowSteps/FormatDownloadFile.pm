package ApiCommonWorkflow::Main::WorkflowSteps::FormatDownloadFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $inputFile = $self->getParamValue('inputFile');
  my $outputDir = $self->getParamValue('outputDir');
  my $args = $self->getParamValue('args');
  my $formattedFileName = $self->getParamValue('formattedFileName');
  
  my $blastPath = $self->getConfig('wuBlastPath');

  my $cmd = "$blastPath/xdformat $args -o $outputDir/$formattedFileName $inputFile";

  if($undo) {
    $self->runCmd(0, "rm -f $outputDir/${formattedFileName}.x*");
  } else{
      if($test){
	  $self->testInputFile('inputFile', "$inputFile");
	  $self->testInputFile('outputDir', "$outputDir");
	  $self->runCmd(0, "echo test > $outputDir/$formattedFileName.xnd");
      }else {
	   if($args =~/\-p/){
	       my $tempFile = "$inputFile.temp";
	       $self->runCmd($test,"cat $inputFile | perl -pe 'unless (/^>/){s/J/X/g;}' > $tempFile");
	       $self->runCmd($test,"$blastPath/xdformat $args -o $outputDir/$formattedFileName $tempFile");
	       $self->runCmd($test,"rm -fr $tempFile");
	   }else {
	       $self->runCmd($test, $cmd);
	   }
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

