package ApiCommonWorkflow::Main::WorkflowSteps::CnvWorkflowCheckpoint;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $sampleName = $self->getParamValue('sampleName');
  my $experimentName = $self->getParamValue('experimentName');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $sampleAnalysisDir = $self->getParamValue('sampleAnalysisDir');
  my $workflowDataDir = $self->getWorkflowDataDir();

  $experimentName =~ s/_CNV$//;
  my $snpSampleExtDbSpec = "$organismAbbrev"."_$experimentName"."_$sampleName"."_HTS_SNPSample_RSRC|dontcare";
  my $snpSampleExtDbRlsId = $self->getExtDbRlsId($test, $snpSampleExtDbSpec);

  my $cmd = "cnvWorkflowCheckpoint --snpSampleExtDbRlsId $snpSampleExtDbRlsId --sampleName $sampleName --sampleAnalysisDir $workflowDataDir/$sampleAnalysisDir";


  if ($undo) {
    $self->runCmd("rm -f $workflowDataDir/$sampleAnalysisDir/doNotDoAnalysis");
  } else {
      if ($test) {
      $self->log("Testing CNV checkpoint\n");;
      } 

      $self->runCmd($test, $cmd);
  }
  

}


1;
