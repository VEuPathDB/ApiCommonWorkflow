package ApiCommonWorkflow::Main::WorkflowSteps::CopyPairwiseMercatorDirsToWebserviceDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;


    my $mercatorDir = $self->getParamValue('mercatorDir');
    my $apiSiteFilesDir   = $self->getParamValue('apiSiteFilesDir');

    opendir(MERCATORDIR,"$mercatorDir");

    
    foreach my $subDir (readdir MERCATORDIR){
	
	if ($undo) {
	    $self->runCmd(0, "rm -fr $apiSiteFilesDir/*");
	}else{
	    if ($test) {
		$self->runCmd(0,"mkdir -p $apiSiteFilesDir/$subDir");
		$self->runCmd(0,"cp -R $mercatorDir/$subDir/mercator-output/alignments $apiSiteFilesDir/$subDir");
		$self-runCmd(0,"cp -R $mercatorDir/$subDir/mercator-output/*.agp $apiSiteFilesDir/$subDir");
	    }else{		
		$self->runCmd($test,"mkdir -p $apiSiteFilesDir/$subDir");
		$self->runCmd($test,"cp -R $mercatorDir/$subDir/mercator-output/alignments $apiSiteFilesDir/$subDir");
		$self-runCmd($test,"cp -R $mercatorDir/$subDir/mercator-output/*.agp $apiSiteFilesDir/$subDir");		    
	    }
	}
	
    }

 
}

sub getParamsDeclaration {
    return ('mercatorDir',
            'apiSiteFilesDir',
           );
}


sub getConfigDeclaration {
    return (
            # [name, default, description]

           );
}

