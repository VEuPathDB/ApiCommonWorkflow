package ApiCommonWorkflow::Main::WorkflowSteps::CopyPairwiseMercatorDirsToWebserviceDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;


    my $mercatorDir = $self->getParamValue('mercatorDir');
    my $outputDir   = $self->getParamValue('apiSiteFilesDir');
    my $workflowDataDir = $self->getWorkflowDataDir();
    my $apiSiteFilesDir   = $self->getSharedConfig('apiSiteFilesDir');
    opendir(MERCATORDIR,"$workflowDataDir/$mercatorDir") or $self->error("Could not open $workflowDataDir/$mercatorDir for reading.\n");

    
    foreach my $subDir (readdir MERCATORDIR){
	next if ($subDir =~ m/^\./);
	if ($undo) {
	    $self->runCmd(0, "rm -fr $apiSiteFilesDir/$outputDir/*");
	}else{
	    if ($test) {
		$self->runCmd(0,"mkdir -p $apiSiteFilesDir/$outputDir/$subDir");
	    }else{		
		$self->runCmd($test,"mkdir -p $apiSiteFilesDir/$outputDir/$subDir");
		$self->runCmd($test,"cp -R $workflowDataDir/$mercatorDir/$subDir/mercator-output/alignments $apiSiteFilesDir/$outputDir/$subDir");
		$self->runCmd($test,"cp -R $workflowDataDir/$mercatorDir/$subDir/mercator-output/*.agp $apiSiteFilesDir/$outputDir/$subDir");		    
	    }
	}
	
    }

 
}

sub getParamsDeclaration {
    return ('mercatorDir',
            'apiSiteFilesDir',
	    'workflowDataDir',
           );
}


sub getConfigDeclaration {
    return (
            # [name, default, description]

           );
}

