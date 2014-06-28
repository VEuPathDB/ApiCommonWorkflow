package ApiCommonWorkflow::Main::WorkflowSteps::MakeTarArchive;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run{
    my ($self, $test, $undo) = @_;

    #get parameter values
    my $workflowDataDir = $self->getWorkflowDataDir();
    my $fileToArchive = $self->getParamValue("fileToArchive");

    my ($path, $fileName) = split (/\/([^\/]+)$/, "$workflowDataDir/$fileToArchive");

    my $cmd = "tar czf $workflowDataDir/$fileToArchive.tar.gz -C $path $fileName";
    my $cmd2 = "rm $workflowDataDir/$fileToArchive";

    if ($undo){
        if (-e "$workflowDataDir/$fileToArchive.tar.gz"){
            $self->runCmd(0, "tar xzf $workflowDataDir/$fileToArchive.tar.gz -C $path");
            $self->runCmd(0, "rm $workflowDataDir/$fileToArchive.tar.gz");
        }
    }else{
        if (-e "$workflowDataDir/$fileToArchive"){
          $self->runCmd($test, $cmd);
          $self->runCmd($test,$cmd2);
        }
    }
}

1;
