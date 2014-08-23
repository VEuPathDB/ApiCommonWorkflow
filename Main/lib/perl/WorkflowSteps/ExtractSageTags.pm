package ApiCommonWorkflow::Main::WorkflowSteps::ExtractSageTags;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $sageTagExtDbRlsSpec = $self->getParamValue('sageTagExtDbRlsSpec');
  my $outputFile = $self->getParamValue('outputFile');
  my $prependSeq = $self->getParamValue('prependSeq');

  my ($sageTagExtDbName,$sageTagExtDbRlsVer) = $self->getExtDbInfo($test,$sageTagExtDbRlsSpec);

  my $sql = "select s.composite_element_id, '$prependSeq' || s.tag as tag
             from rad.sagetag s,rad.arraydesign a
             where a.name = '$sageTagExtDbName'
             and a.version = '$sageTagExtDbRlsVer'
             and a.array_design_id = s.array_design_id";

  my $workflowDataDir = $self->getWorkflowDataDir();



    if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
    } else {
	if ($test) {
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
	}
        $self->runCmd($test,"gusExtractSequences --outputFile $workflowDataDir/$outputFile --idSQL \"$sql\" --verbose");
    }
}
  
1;
