package ApiCommonWorkflow::Main::WorkflowSteps::WriteSamplePropFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run{
    my ($self, $test, $undo) = @_;
    
    my $workflowDataDir = $self->getWorkflowDataDir();
    my $clusterResultsDir = $self->getParamValue('clusterResultsDir');
    my $outFile =  "$workflowDataDir/$clusterResultsDir/samplePropFile.txt"; 
    my $sampleName = $self->getParamValue('sampleName');
    my $inputName = $self->getParamValue('inputName');
    my $fragmentLength = $self->getParamValue('fragmentLength');
    

    my $cmd = "writeSamplePropFile.pl --outFile $outFile --sampleName $sampleName --inputName $inputName --fragmentLength $fragmentLength";	

    if ($undo){
        $self->runCmd(0, "rm -f $outFile");
    }
    else{
        $self->runCmd($test, $cmd);
    }
}

1;
