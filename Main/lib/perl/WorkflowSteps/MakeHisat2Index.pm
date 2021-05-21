package ApiCommonWorkflow::Main::WorkflowSteps::MakeHisat2Index;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

use File::Basename;

sub run{
    my ($self, $test, $undo) = @_;

    my $workflowDataDir = $self->getWorkflowDataDir();

    my $hisat2Dir = $self->getParamValue("hisat2Dir");
    my $indexName = $self->getParamValue("indexName");
    my $fastaFile = $self->getParamValue("fastaFile");


    my $cmd = "hisat2-build $workflowDataDir/$fastaFile $workflowDataDir/$hisat2Dir/$indexName";

    if ($undo) {
        $self->runCmd(0, "rm -r $workflowDataDir/$hisat2Dir/$indexName*.ht2");
    }else{
          $self->runCmd($test, $cmd);
    }
}

1;
