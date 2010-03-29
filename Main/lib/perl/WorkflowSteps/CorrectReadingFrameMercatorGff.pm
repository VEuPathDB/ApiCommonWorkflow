package ApiCommonWorkflow::Main::WorkflowSteps::CorrectReadingFrameMercatorGff;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;


    my $inputFastaFile = $self->getParamValue('inputFastaFile');
    my $inputGffFile = $self->getParamValue('inputGffFile');
    my $outputGffFile = $self->getParamValue('outputGffFile');

    my $localDataDir = $self->getLocalDataDir();


    my $cmd = "fixMercatorOffsetsInGFF.pl --f $localDataDir/$inputFastaFile --g $localDataDir/$inputGffFile --o $localDataDir/$outputGffFile";



    if ($undo) {
      $self->runCmd(0, "rm -fr $localDataDir/$outputGffFile");
    } else {
	if ($test) {
	    $self->runCmd(0,"mkdir -p $localDataDir/$outputDir");
	    $self->runCmd(0,"echo hello > $localDataDir/$outputGffFile");
	}else{
	    $self->runCmd($test, $cmd);
	}
    }
}

sub getParamsDeclaration {
    return ('inputFastaFile',
            'inputGffFile',
            'outputGffFile'
           );
}


sub getConfigDeclaration {
    return (
            # [name, default, description]

           );
}
