package ApiCommonWorkflow::Main::WorkflowSteps::InsertGeneOrChromosomeCNVs;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $useSqlLdr = $self->getBooleanParamValue('useSqlLdr');
  my $inputDir = $self->getParamValue('inputDir');
  my $configFile = $self->getParamValue('configFile');
  my $analysisResultView = $self->getParamValue('analysisResultView');  
  my $sourceIdType = $self->getParamValue('sourceIdType');

  my $naFeatureView;
  # naFeatureView is only required if source ids will be derived from NaFeature
  if ($sourceIdType eq 'NaFeature'){
    $naFeatureView = $self->getParamValue('naFeatureView');
  }
      
  my $args = "--inputDir '$workflowDataDir/$inputDir' --configFile '$workflowDataDir/$inputDir/$configFile' --analysisResultView $analysisResultView  --sourceIdType $sourceIdType";

  $args.=" --useSqlLdr" if($useSqlLdr); 
  $args.=" --naFeatureView $naFeatureView" if($naFeatureView);


  $self->testInputFile('inputDir', "$workflowDataDir/$inputDir");
  $self->testInputFile('configFile', "$workflowDataDir/$inputDir/$configFile");


  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertCNVAnalysisResult", $args);

}

1;
