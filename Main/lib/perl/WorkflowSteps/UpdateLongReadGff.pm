package ApiCommonWorkflow::Main::WorkflowSteps::UpdateLongReadGff;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
    my ($self, $test, $undo) = @_;

    my $workflowDataDir = $self->getWorkflowDataDir();   
    my $gffFile = $self->getParamValue('gffFile');
    my $countFile = $self->getParamValue('countFile');
    my $gffFileOut = $self->getParamValue('gffFileOut');


  if ($undo) {
	 $self->runCmd(0,"rm -rf $workflowDataDir/$gffFileOut");  	
 } else{
	$self->runCmd($test, "updateLongReadGff.pl --gffFile $workflowDataDir/$gffFile --countFile $workflowDataDir/$countFile --outputGFF $workflowDataDir/$gffFileOut");
}
}
