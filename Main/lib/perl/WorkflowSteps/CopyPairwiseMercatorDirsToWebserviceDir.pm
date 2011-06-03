package ApiCommonWorkflow::Main::WorkflowSteps::CopyPairwiseMercatorDirsToWebserviceDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $mercatorDir = $self->getParamValue('mercatorDir');

    my $relativeDir = $self->getParamValue('relativeDir');

    my $websiteFilesDir = $self->getWebsiteFilesDir($test);

    my $outputDir   = "$websiteFilesDir/$relativeDir/mercator";

    my $workflowDataDir = $self->getWorkflowDataDir();
    opendir(MERCATORDIR,"$workflowDataDir/$mercatorDir") or $self->error("Could not open $workflowDataDir/$mercatorDir for reading.\n");

    foreach my $subDir (readdir MERCATORDIR){
	next if ($subDir =~ m/^\./);
	if ($undo) {
	    $self->runCmd(0, "rm -fr $outputDir");
	}else{
	    if ($test) {
		$self->runCmd(0,"mkdir -p $outputDir/$subDir");
	    }else {
		$self->runCmd($test,"mkdir -p $outputDir/$subDir");
		$self->runCmd($test,"cp -R $workflowDataDir/$mercatorDir/$subDir/mercator-output/alignments $outputDir/$subDir");
		$self->runCmd($test,"cp -R $workflowDataDir/$mercatorDir/$subDir/mercator-output/*.agp $outputDir/$subDir");
	    }
	}
    }

 
}

sub getParamsDeclaration {
    return ('mercatorDir',
	    'workflowDataDir',
           );
}


sub getConfigDeclaration {
    return (
            # [name, default, description]

           );
}

