package ApiCommonWorkflow::Main::WorkflowSteps::InsertSimpleRadAnalysisFromConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $analysisWorkingDir = $self->getParamValue('analysisWorkingDir');

  my $configFile = "$analysisWorkingDir/config.txt";
      
  my $args = "--inputDir $analysisWorkingDir --configFile $configFile --analysisResultView DataTransformationResult  --naFeatureView ArrayElementFeature";

  if ($test) {
    $self->testInputFile('analysisWorkingDir', "$analysisWorkingDir");
  }

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertAnalysisResult", $args);

}

sub getParamDeclaration {
  return (
	  'analysisWorkingDir',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

