package ApiCommonWorkflow::Main::WorkflowSteps::CalculateExpressionStatsForTimeSeries;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;
  my @configLines;
  my $dataDir = $self->getParamValue('doTranscriptExpressionDir');
  my $configFile = $self->getParamValue('configFile');
  my $workflowDataDir = $self->getWorkflowDataDir();

  open (cf, "< $workflowDataDir/$dataDir/$configFile");
  while (<cf>) {
    chomp;
    push (@configLines,$_)
  }

  my $mappingFile = $configLines[0];

  my $profileSetSpecs = $configLines[1]; 

  my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');

  my $args = "--externalDatabaseSpec '$extDbRlsSpec'  --profileSetSpecs '$profileSetSpecs'";

  $args .= " --timePointsMappingFile '$workflowDataDir/$dataDir/$mappingFile'" unless ($mappingFile eq "NO_MAPPING_FILE");

  $self->testInputFile('inputDir', "$workflowDataDir/$dataDir/$mappingFile") unless ($mappingFile eq "NO_MAPPING_FILE");

    if ($undo){
    } else{
      $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::CalculateProfileSummaryStats", $args);
    }

}

1;
