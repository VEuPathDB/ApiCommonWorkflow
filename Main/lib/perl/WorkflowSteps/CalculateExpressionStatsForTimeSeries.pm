package ApiCommonWorkflow::Main::WorkflowSteps::CalculateExpressionStatsForTimeSeries;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $profileSetNames = $self->getParamValue('profileSetNames');

  my $percentProfileSet = $self->getParamValue('percentProfileSet');

  my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');

  my $isLogged = ($self->getParamValue('isLogged') eq 'true') ? 1 :0;

  my $mappingFile = $self->getParamValue('mappingFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--externalDatabaseSpec '$extDbRlsSpec'  --profileSetNames '$profileSetNames' --percentProfileSet '$percentProfileSet'";

  $args .= " --timePointsMappingFile '$workflowDataDir/$mappingFile'" if $mappingFile;

  $args .= " --isLogged" if $isLogged;

  
  if ($test) {
    $self->testInputFile('inputDir', "$workflowDataDir/$mappingFile") if $mappingFile;
  }

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::CalculateProfileSummaryStats", $args);

}

sub getParamDeclaration {
  return (
	  'profileSetNames',
	  'percentProfileSet',
	  'extDbRlsSpec',
	  'isLogged',
	  'mappingFile',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

