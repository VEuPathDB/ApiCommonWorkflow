package ApiCommonWorkflow::Main::WorkflowSteps::MakeCodonUsage;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
    my ($self, $test, $undo) = @_;

    # get parameters
    my $inputFile = $self->getParamValue('inputFile');
    my $outputFile = $self->getParamValue('outputFile');
    my $descripFile = $self->getParamValue('descripFile');
    my $descripString = $self->getParamValue('descripString');

    my $cmd = <<"EOF";
      makeCodonUsage  --outFile $outputFile  --inFile $inputFile  --verbose
EOF
  my $cmdDec = "writeDownloadFileDecripWithDescripString --descripString '$descripString' --outputFile $descripFile";

    if ($undo) {
	$self->runCmd(0, "rm -f $outputFile");
        $self->runCmd(0, "rm -f $descripFile");
    } else {
	if ($test) {
	    $self->testInputFile('inputFile', "$inputFile");
	    $self->runCmd(0,"echo test > $outputFile");
	}else{
	    $self->runCmd($test,$cmd);
	    $self->runCmd($test, $cmdDec);
	}
    }
}


sub getParamsDeclaration {
    return ('inputFile',
            'outputFile',
           );
}


sub getConfigDeclaration {
    return (
            # [name, default, description]
           );
}

