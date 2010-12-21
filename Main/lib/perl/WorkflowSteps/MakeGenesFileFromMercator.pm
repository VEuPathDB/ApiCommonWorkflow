package ApiCommonWorkflow::Main::WorkflowSteps::MakeGenesFileFromMercator;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;
    my $mercatorOutputDir = $self->getParamValue('mercatorOutputDir');
    my $cndSrcBin = $self->getParamValue('cndSrcBin');
    my $outputDir = $self->getParamValue('outputDir');

    my $workflowDataDir = $self->getWorkflowDataDir();

    my $cmd = '';
    if ($undo) {
	$self->runCmd(0, "rm -fr $workflowDataDir/$outputDir");

    }else{
	if ($test) {
	    $self->runCmd(0,"mkdir -p $workflowDataDir/$outputDir");
	    $self->runCmd(0,"echo hello > $workflowDataDir/$outputDir/allGenes.txt");
	}else{
	    $cmd = "makeGenesFromMercator --mercatorOutputDir $mercatorOutputDir --t 'protein_coding' --cndSrcBin $cndSrcBin --uga --to --verbose > allGeneClusters.txt";
	    $self->runCmd($test, $cmd);
	    $cmd = "makeGenesFromMercator --mercatorOutputDir $mercatorOutputDir --t 'rna_coding' --uga --to --verbose >> allGeneClusters.txt";
	    $self->runCmd($test, $cmd);

	    $cmd = "grep ^cluster_ allGeneClusters.txt > allGenes.txt";

	    $self->runCmd($test,$cmd);
	}
    }
}

sub getParamsDeclaration {
    return ('mercatorOutputDir',
            'outputDir',
            'cndSrcBin',
           );
}


sub getConfigDeclaration {
    return (
            # [name, default, description]
              ['ncbiBlastPath', "", ""]
           );
}

