package ApiCommonWorkflow::Main::WorkflowSteps::GenerateHomerCvgPlots;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run{
    my ($self, $test, $undo) = @_;
    
    my $mainResDir = $self->getParamValue('mainResDir');    
    my $inBamFile = "$mainResDir/results.bam";
    my $outDir = "$bowtieResDir/homer/";  
    my $topLevelSeqSizeFile = $self->getParamValue('topLevelSeqSizeFile');
    
    my $cmd = "generateHomerCvgPlots.pl --inBamFile $inBamFile --outDir $outDir --topLevelSeqSizeFile $topLevelSeqSizeFile";
    
    if ($undo){
        $self->runCmd(0, "rm -rf $outDir");
    }
    else{
        $self->runCmd($test, $cmd);
    }
}

1;
