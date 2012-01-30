package ApiCommonWorkflow::Main::WorkflowSteps::CalculateExpressionStatsForTimeSeries;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;
  my @configLines;
  my $configFile = $self->getParamValue('configFile');
  open (cf, "< $configFile");
  while (<cf>) {
    chomp;
    push (@configLines,$_)
  }

  unless ($configLines[0] eq "NOT_A_TIME_SERIES") {
    my $profileSetSpecs = $configLines[1]; 

    my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');

    my $mappingFile = @configLines[0];

    my $workflowDataDir = $self->getWorkflowDataDir();

    my $args = "--externalDatabaseSpec '$extDbRlsSpec'  --profileSetSpecs '$profileSetSpecs'";

    $args .= " --timePointsMappingFile '$workflowDataDir/$mappingFile'" unless ($mappingFile eq "NO_MAPPING_FILE");




    if ($test) {
      $self->testInputFile('inputDir', "$workflowDataDir/$mappingFile") if $mappingFile;
    }

    $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::CalculateProfileSummaryStats", $args);

  }
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

