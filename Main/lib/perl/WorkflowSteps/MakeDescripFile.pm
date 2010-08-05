package ApiCommonWorkflow::Main::WorkflowSteps::MakeDescripFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
    my ($self, $test, $undo) = @_;

    # get parameters
    my $descripFile->getParamValue('descripFile');
    my $descripString->getParamValue('descripString');

    my $apiSiteFilesDir = $self->getSharedConfig('apiSiteFilesDir');

    my $cmdDec = "writeDownloadFileDecripWithDescripString --descripString '$descripString' --outputFile $apiSiteFilesDir/$descripFile";

    if ($undo) {
        $self->runCmd(0, "rm -f $apiSiteFilesDir/$descripFile");
    } else {
	if ($test) {
	}else{
	    $self->runCmd($test, $cmdDec);
	}
    }
}


sub getParamsDeclaration {
    return ('descripFile',
            'descripString',
           );
}


sub getConfigDeclaration {
    return (
            # [name, default, description]
           );
}

