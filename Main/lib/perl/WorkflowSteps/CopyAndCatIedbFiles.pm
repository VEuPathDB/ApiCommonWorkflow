package ApiCommonWorkflow::Main::WorkflowSteps::CopyAndCatIedbFiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;


    my $inputDirRelativeToDownloadsDir = $self->getParamValue('inputDirRelativeToDownloadsDir');

    #Now we use one IEDB file for all species, test this for all organisms.
    #my $organismName = $self->getParamValue('organismName');

    my $outputDir = $self->getParamValue('outputDir');


    my $localDataDir = $self->getLocalDataDir();
    my $downloadDir = $self->getGlobalConfig('downloadDir');

    my $inputDir="$downloadDir/$inputDirRelativeToDownloadsDir";
    my $cmd = "cat ";
    my @inputFileNames = $self->getInputFiles($test,$inputDir,'','txt');
    my $size=scalar @inputFileNames;

    if (scalar @inputFileNames==0){
	die "No input files. Please check inputDir: $inputDir\n";
    }else {
	$cmd .= join (" " ,@inputFileNames);
    }

   $cmd .= " >$localDataDir/$outputDir/IEDBExport.txt";

    if ($undo) {
      $self->runCmd(0, "rm -f $localDataDir/$outputDir/IEDBExport.txt");
    } else {
    if ($test) {
      $self->testInputFile('inputDir', "$inputDir");
      $self->testInputFile('outputDir', "$localDataDir/$outputDir");
    }
      $self->runCmd($test, $cmd);
    }
}

sub getParamsDeclaration {
    return ('inputDirRelativeToDownloadsDir',
            'organismName',
            'outputDir'
           );
}


sub getConfigDeclaration {
    return (
            # [name, default, description]
           );
}

