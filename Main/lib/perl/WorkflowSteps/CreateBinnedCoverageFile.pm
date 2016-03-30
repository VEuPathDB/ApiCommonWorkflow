package ApiCommonWorkflow::Main::WorkflowSteps::CreateBinnedCoverageFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    # get parameter values
    my $bamFile = $self->getParamValue("bamFile"); 
    my $window = $self->getParamValue("windowSize");
    my $workflowDataDir = $self->getWorkflowDataDir();
    my $outputFile = $self->getParamValue("outputFile");
    my $samtoolsIndex = $self->getParamValue("samtoolsIndex");

    my $cmd = "generateBinnedCoverageFile.pl --bamFile $workflowDataDir/$bamFile --window $window --outputFile $workflowDataDir/$outputFile --samtoolsIndex $workflowDataDir/$samtoolsIndex";

    if ($undo) {
        $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
    }else{
        #$self->testInputFile("bamFile", "$workflowDataDir/$bamFile");
        $self->testInputFile("samtoolsIndex", "$workflowDataDir/$samtoolsIndex");
        if($test) {
            $self->runCmd(0, "echo test > $workflowDataDir/$outputFile");
        }
        $self->runCmd($test, $cmd);
    }
}

1; 
