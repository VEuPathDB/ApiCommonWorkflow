package ApiCommonWorkflow::Main::WorkflowSteps::MakeDescripFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
    my ($self, $test, $undo) = @_;

    # get parameters
    my $descripFile = $self->getParamValue('descripFile');
    my $descripString = $self->getParamValue('descripString');

    my $cmdDec = "writeDownloadFileDecripWithDescripString --descripString '$descripString' --outputFile $descripFile";

    if ($undo) {
        $self->runCmd(0, "rm -f $descripFile");
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

