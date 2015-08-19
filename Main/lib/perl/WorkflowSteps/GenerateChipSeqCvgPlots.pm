package ApiCommonWorkflow::Main::WorkflowSteps::GenerateChipSeqCvgPlots;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run{
    my ($self, $test, $undo) = @_;
    
    my $clusterResultsDir = $self->getParamValue('clusterResultsDir');
    my $topLevelSeqSizeFile = $self->getParamValue('topLevelSeqSizeFile');
    my $experimentType = $self->getParamValue('experimentType');
    my $inputName = $self->getParamValue('inputName');
    my $fragmentLength = $self->getParamValue('fragmentLength');
    my $workflowDataDir = $self->getWorkflowDataDir();
    my $inBamFile = "$workflowDataDir/$clusterResultsDir/master/mainresult/$sampleName.bam";  
    my $outDir = "$workflowDataDir/$clusterResultsDir/master/mainresult/downstream/"; 


# Currently software for coverage plots has been assessed only for histone modification (HOMER will be used) and MNase (danpos2 will be used) experiments. As more assessments are done, the condition below should be modified appropriately. HOMER should work well also for TF binding.    
    if ($experimentType eq 'histonemod' || $experimentType eq 'mnase') {
	my $cmd = "generateChipSeqCvgPlots.pl --experimentType $experimentType --inBamFile $inBamFile --outDir $outDir --topLevelSeqSizeFile $topLevelSeqSizeFile --fragmentLength $fragmentLength";
    }	

    if ($undo){
        $self->runCmd(0, "rm -rf $outDir");
    }
    else{
        $self->runCmd($test, $cmd);
    }
}

1;
