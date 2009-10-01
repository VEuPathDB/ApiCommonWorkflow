package ApiCommonWorkflow::Main::WorkflowSteps::InsertSimpleRadAnalysisFromConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $analysisWorkingDir = $self->getParamValue('analysisWorkingDir');

  my $configFile = "$analysisWorkingDir/config.txt";

  my $analysisResultView =  $self->getParamValue('analysisResultView');

  my $naFeatureView =  $self->getParamValue('naFeatureView');

  my $useSqlLdr =  $self->getParamValue('useSqlLdr');


      
  my $args = "--inputDir $analysisWorkingDir --configFile $configFile --analysisResultView $analysisResultView  --naFeatureView $naFeatureView";

  $args.=" --useSqlLdr" if($sqlLdr); 

  if ($test) {
    $self->testInputFile('analysisWorkingDir', "$analysisWorkingDir");
  }

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertAnalysisResult", $args);

}

sub getParamDeclaration {
  return (
	  'analysisWorkingDir',
	  'analysisResultView',
	  'naFeatureView',
	  'useSqlLdr',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

