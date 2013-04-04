 package ApiCommonWorkflow::Main::WorkflowSteps::ParseProteoAnnotatorResults;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use File::Basename;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;
  
  my $inputDir = $self->getParamValue('inputDir');
  my $sampleName = $self->getParamValue('sampleName');
  my $inputFileName = $self->getParamValue('summaryFileName');
  
  my $inputFile = $inputDir."/".$inputFileName;
  $inputFile =~ s/\/+/\//g;
  
  my ($basename,$path,$suffix) =fileparse($inputFile);
  
  my $outputFile = $inputDir.'/'.$sampleName.'.tab';

  if ($undo) {
    $self->runCmd(0, "rm -f $outputFile");
  } else {
      if ($test) {
	  $self->runCmd(0,"echo test > $outputFile");
      } else {
	  $self->runCmd($test,"$ParseProteoAnnotatorSummaryFile.pl --inputFile $inputFile --decoyTag $decoyTag --outputFile $outputFile");
      }
  }
}

sub getParamsDeclaration {
  return (
      'inputFile',
      'decoyTag',
      );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	  ['ParseProteoAnnotatorResults', "", ""],
	 );
}