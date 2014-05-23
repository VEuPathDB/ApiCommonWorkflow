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

    my $cmd = "tar czf $workflowDataDir/$fileToArchive.tar.gz $workflowDataDir/$fileToArchive";
    my $cmd2 = "rm $workflowDataDir/$fileToArchive";

    if ($undo){
        if (-e "$workflowDataDir/$fileToArchive.tar.gz"){
            $self->runCmd(0, "tar xzf $workflowDataDir/$fileToArchive.tar.gz");
            $self->runCmd(0, "rm $workflowDataDir/$fileToArchive.tar.gz");
        }
    }else{
        if (-e "$workflowDataDir/$fileToArchive"){
            if ($test){
                $self->runCmd(0, $cmd);
                $self->runCmd(0, $cmd2);
            }
            $self->runCmd($test, $cmd);
            $self->runCmd($test,$cmd2);
        }
    }
}

sub getParamDeclaration{
    return(
        'fileToArchive'
    );
}

sub getConfigDeclaration {
    return (
        #[name, default, description]
    );
}
1;
