package ApiCommonWorkflow::Main::WorkflowSteps::MakeChromSizesFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run{
    my ($self, $test, $undo) = @_;

    #get parameter values
    my $workflowDataDir = $self->getWorkflowDataDir();
    my $genomicSeqsDir = $self->getParamValue("genomicSeqsDir");
    my $genomeIndex = $self->getParamValue("genomeIndex");

    my $cmd = "cut -f 1,2 $workflowDataDir/$genomicSeqsDir/$genomeIndex > $workflowDataDir/$genomicSeqsDir/chrom.sizes";
    
    if ($undo) {
        $self->runCmd(0, "rm $workflowDataDir/$genomicSeqsDir/chrom.sizes");
    }else{
        if($test){
            $self->runCmd(0, "echo test > $workflowDataDir/$genomicSeqsDir/chrom.sizes");
        }
        $self->runCmd($test, $cmd);
    }
}

sub getParamDeclaration {
    return (
        'genomicSeqsDir',
        'genomeIndex'
    );
}

sub getConfigDeclaration {
    return (
        #[name, default, description]
    );
}
1;
