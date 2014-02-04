package ApiCommonWorkflow::Main::WorkflowSteps::CreateBinnedCoverageFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    # get parameter values
    my $bamFile = $self->getParamValue("bamFile"); 
    my $genome = $self->getParamValue("genomicSeqsFile"); 
    my $window = $self->getParamValue("windowSize");
    my $workflowDataDir = $self->getWorkflowDataDir();
    my $outputFile = $self->getParamValue("outputFile");
    my $experimentDir = $self->getParamValue("experimentDir");

    my $cmd = "generateBinnedCoverageFile.pl --bamFile $workflowDataDir/$bamFile --genome $workflowDataDir/$genome --window $window --outputFile $workflowDataDir/$outputFile -- experimentDir $experimentDir";

    if ($undo) {
        $self->runCmd(0, "rm -f $workflowDataDir/$genome.fai");
        $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
    }else{
        if($test) {
            $self->runCmd(0, "echo test > $workflowDataDir/$genome.fai");
            $self->runCmd(0, "echo test > $workflowDataDir/$outputFile");
        }else{
            $self->runCmd($test, $cmd);
        }
    }
}

sub getParamDeclaration {
    return (
        'bamFile',
        'genome',
        'window',
        'outputFile',
        'experimentDir'
    );
}

sub getConfigDeclaration {
    return (
        # [name, default, description]
    );
}
1; 
