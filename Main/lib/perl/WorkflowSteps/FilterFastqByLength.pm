package ApiCommonWorkflow::Main::WorkflowSteps::FilterFastqByLength;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run{
    my ($self, $test, $undo)= @_;

    # get parameter values
    my $workflowDataDir = $self->getWorkflowDataDir();
    my $readsFile = $self->getParamValue("readsFile");
    my $type = $self->getParamValue("sequenceFormat");
    my $minLength = $self->getParamValue("minLength");
    my $maxLength = $self->getParamValue("maxLength");
    my $outFile = $self->getParamValue("outFile");

    my $cmd = "filterFastqByLength.pl --readsFile $workflowDataDir/$readsFile --type $type --min $minLength --max $maxLength --outFile $workflowDataDir/$outFile";

    if ($undo){
        $self->runCmd(0, "rm $workflowDataDir/$outFile");
    }else{
        if ($test){
            $self->runCmd(0, "echo test > $workflowDataDir/$outFile");
        }
        $self->runCmd($test, $cmd);
    }
}

sub getParamDeclaration{
    return(
        'readsFile',
        'sequenceFormat',
        'minLength',
        'maxLength',
        'outFile'
    );
}

sub getConfigDeclaration{
    return(
        #[name, default, description]
    );
}
1;
