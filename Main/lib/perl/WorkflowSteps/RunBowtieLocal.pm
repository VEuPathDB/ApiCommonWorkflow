package ApiCommonWorkflow::Main::WorkflowSteps::RunBowtieLocal;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;



sub run{
    my ($self, $test, $undo) = @_;
    
    # get parameter values
    my $mateA = $self->getParamValue("readsFile");
    my $mateB = $self->getParamValue("pairedReadsFile");
    my $bowtieIndex = $self->getParamValue("bowtieIndex");
    my $isColorspace = $self->getParamValue("isColorspace");
    my $removePCRDuplicates = $self->getParamValue("removePCRDuplicates");
    my $extraBowtieParams = $self->getParamValue("extraBowtieParams");
    my $sampleName = $self->getParamValue("sampleName");
    my $deleteIntermediateFiles = $self->getParamValue("deleteIntermediateFiles");
    my $outputDirName = $self->getParamValue("outputDir");
    my $workflowDataDir = $self->getWorkflowDataDir();
    my $outputDir = "$workflowDataDir/$outputDirName";    

    my $cmd = "runBowtieMappingLocal.pl --mateA $workflowDataDir/$mateA".(-e "$workflowDataDir/$mateB" ? " --mateB $workflowDataDir/$mateB": "");
    $cmd .= " --bowtieIndex $workflowDataDir/$bowtieIndex";
    if ($extraBowtieParams ne 'none'){
        # make swaps so GetOpt::Long can take bowtieParams as a string
        $extraBowtieParams =~ s/-/_/g;
        $extraBowtieParams=~ s/ /#/g;
        $cmd .= " --extraBowtieParams $extraBowtieParams";
    }
    if ($isColorspace eq 'true'){
        $cmd.= " --isColorspace";
    }
    if ($removePCRDuplicates eq 'true'){
        $cmd .= " --removePCRDuplicates";
    }
    $cmd .= " --sampleName $sampleName";
    $cmd .= " --workingDir $outputDir";
    
    if ($undo){
        $self->runCmd(0, "rm -f $outputDir/$sampleName.bam");
    }else{
        if($test){
            $self->runCmd(0, "echo test > $outputDir/$sampleName.bam");
        }else{
            $self->runCmd($test, $cmd);
        }
    }
}


sub getParamDeclaration {
    return (
        'readsFile',
        'pairedReadsFile',
        'bowtieIndex',
        'isColorspace',
        'removePCRDuplicates',
        'extraBowtieParams',
        'sampleName',
        'deleteIntermediateFiles',
        'outputDir'
    );
}

sub getConfigDeclaration {
    return (
        # [name, default, description]
    );
}
1;
