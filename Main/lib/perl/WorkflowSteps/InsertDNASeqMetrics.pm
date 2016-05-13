package ApiCommonWorkflow::Main::WorkflowSteps::InsertDNASeqMetrics;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;


  my $analysisDir = $self->getParamValue('analysisDir');
  my $studyName = $self->getParamValue('studyName');
  my $sampleName = $self->getParamValue('sampleName');
  my $sampleExtDbSpec = $self->getParamValue('sampleExtDbSpec');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--analysisDir $workflowDataDir/$analysisDir --studyName '$studyName' --assayName '$sampleName (DNA Sequencing)' --sampleExtDbSpec $sampleExtDbSpec --seqVariationNodeName '$sampleName (SequenceVariation)' --protocolName 'DNA Sequencing'";

  
    #$self->testInputFile('inputDir', "$workflowDataDir/$inputDir");
    #$self->testInputFile('configFile', "$workflowDataDir/$configFile");


  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertDNASeqMetrics", $args);

}


1;
