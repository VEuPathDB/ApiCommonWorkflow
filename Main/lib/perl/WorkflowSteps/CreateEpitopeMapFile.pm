package ApiCommonWorkflow::Main::WorkflowSteps::CreateEpitopeMapFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;


    my $inputDir = $self->getParamValue('inputDir');
    my $queryDir = $self->getParamValue('queryDir');
    my $proteinsFile = $self->getParamValue('proteinsFile');
    my $blastDbDir = $self->getParamValue('blastDbDir');
    my $outputDir = $self->getParamValue('outputDir');
    my $idRegex = $self->getParamValue('idRegex');

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $downloadDir = $self->getSharedConfig('downloadDir');
    my $ncbiBlastPath = $self->getConfig('ncbiBlastPath');

    my $cmd = "createEpitopeMappingFileWorkflow  --ncbiBlastPath $ncbiBlastPath --inputDir $workflowDataDir/$inputDir --queryDir $workflowDataDir/$queryDir --outputDir $workflowDataDir/$outputDir --blastDatabase $workflowDataDir/$blastDbDir/AnnotatedProteins.fsa --idRegex '$idRegex' --subjectFile $workflowDataDir/$proteinsFile";



    if ($undo) {
      $self->runCmd(0, "rm -fr $workflowDataDir/$outputDir");
    } else {
	if ($test) {
	    $self->testInputFile('proteinsFile', "$workflowDataDir/$proteinsFile");
	    $self->testInputFile('inputDir', "$workflowDataDir/$inputDir");
	    $self->runCmd(0,"mkdir -p $workflowDataDir/$outputDir");
	    $self->runCmd(0,"echo hello > $workflowDataDir/$outputDir/IEDBExport.out");
	}else{
	    $self->runCmd($test, $cmd);
	}
    }
}

sub getParamsDeclaration {
    return ('inputDir',
            'blastDbDir',
            'proteinsFile',
            'outputDir'
           );
}


sub getConfigDeclaration {
    return (
            # [name, default, description]
              ['ncbiBlastPath', "", ""]
           );
}

