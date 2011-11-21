package ApiCommonWorkflow::Main::WorkflowSteps::CalculateExpressionStatsForTimeSeries;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

#  my $profileSetSpecs = $self->getParamValue('profileSetSpecs');
  my $profileSetSpecs = ""; # see redmine issue 4257

  my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');

  my $isLogged = ""; # ($self->getParamValue('isLogged') eq 'true') ? 1 :0;  see redmine 4257

  my $mappingFile = ""; # $self->getParamValue('mappingFile'); see redmine 4257

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--externalDatabaseSpec '$extDbRlsSpec'  --profileSetSpecs '$profileSetSpecs'";

  $args .= " --timePointsMappingFile '$workflowDataDir/$mappingFile'" if $mappingFile;

  $args .= " --isLogged" if $isLogged;

  
  if ($test) {
    $self->testInputFile('inputDir', "$workflowDataDir/$mappingFile") if $mappingFile;
  }

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::CalculateProfileSummaryStats", $args);

}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

