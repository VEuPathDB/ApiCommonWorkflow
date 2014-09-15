package ApiCommonWorkflow::Main::WorkflowSteps::RunCufflinksForCNVs;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run{
    my ($self, $test, $undo) = @_;

    #get parameter values
    my $workflowDataDir = $self->getWorkflowDataDir();
    my $genomicSeqsFile = $self->getParamValue("genomicSeqsFile");
    my $outputFile = $self->getParamValue("outputFile");
    my $bamFile = $self->getParamValue("bamFile");
    my $gtfFile = $self->getParamValue("gtfFile");

    $self->runCmd(0, "mkdir -p $workflowDataDir/Cufflinks");

    my $cmd = "cufflinks -u -N -p 4 -b $genomicSeqsFile -G $gtfFile -o $workflowDataDir/Cufflinks $bamFile";


    if ($undo){
        $self->runCmd(0, "rm -rf $workflowDataDir/Cufflinks");
    }else{
        $self->testInputFile('genomicSeqsFile', $genomicSeqsFile);
        $self->testInputFile('bamFile', $bamFile);
        if ($test){
            $self->runCmd(0, "echo test > $workflowDataDir/Cufflinks/test");
        }
        $self->runCmd($test, $cmd);
    }
}

1;
