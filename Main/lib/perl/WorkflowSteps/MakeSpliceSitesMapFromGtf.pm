package ApiCommonWorkflow::Main::WorkflowSteps::MakeSpliceSitesMapFromGtf;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $workflowDataDir = $self->getWorkflowDataDir();

    # get parameter values
    my $gtfDir = $self->getParamValue("gtfDir");
    my $gtfFile = $self->getParamValue("gtfFile");
    my $outputFile = $self->getParamValue("outputFile");
       
    my $cmd = "cat $workflowDataDir/$gtfDir/$gtfFile| gtf_splicesites | iit_store -o $workflowDataDir/$gtfDir/$outputFile";

    if ($undo) {
        $self->runCmd(0, "rm -f $workflowDataDir/$gtfDir/$outputFile.iit");
    }else{
        if($test) {
            $self->runCmd(0, "echo test > $workflowDataDir/$gtfDir/$outputFile.iit");
        }
        $self->runCmd($test, $cmd);
    }
}

1; 
