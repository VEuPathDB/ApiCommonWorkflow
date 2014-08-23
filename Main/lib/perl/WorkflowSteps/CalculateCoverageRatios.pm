package ApiCommonWorkflow::Main::WorkflowSteps::CalculateCoverageRatios;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;



sub run{
    my ($self, $test, $undo) = @_;
    
    # get parameter values
    my $experimentDir = $self->getParamValue("experimentDir");
    my $outputDirName = $self->getParamValue("outputDir");
    my $workflowDataDir = $self->getWorkflowDataDir();
    my $outputDir = "$workflowDataDir/$outputDirName";    
    my $chromSizesFile = $self->getParamValue("chromSizesFile");

    my $cmd = "calculateCoverageRatios.pl --experimentDir $workflowDataDir/$experimentDir --outputDir $outputDir --chromSizesFile $workflowDataDir/$chromSizesFile";
    
    if ($undo){
        $self->runCmd(0, "rm -f $outputDir/*.bed");
        $self->runCmd(0, "rm -f $outputDir/*.bw");
    }else{
        if($test){
            $self->runCmd(0, "echo test > $outputDir/test.bed");
            $self->runCmd(0, "echo test > $outputDir/test.bw");
        }
        $self->runCmd($test, $cmd);
    }
}

1;
