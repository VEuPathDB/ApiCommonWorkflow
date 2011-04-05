package ApiCommonWorkflow::Main::WorkflowSteps::RunMDust;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self,$test, $undo) = @_;


    my $inputSeqsFile = $self->getParamValue('inputSeqsFile');
    my $outputSeqsFile = $self->getParamValue('outputSeqsFile');

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $mdustPath = $self->getConfig('mdustPath');


    if ($undo) {
	$self->runCmd(0, "rm -f $workflowDataDir/$outputSeqsFile");
    }else{
	if ($test) {
	    $self->testInputFile('inputSeqsFile', "$workflowDataDir/$inputSeqsFile");
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputSeqsFile");
	}else{
		$self->runCmd($test,"mdust $workflowDataDir/$inputSeqsFile > $workflowDataDir/$outputSeqsFile");
	}
    }
}

sub getParamsDeclaration {
    return ('inputSeqsFile',
            'outputSeqsFile'
           );
}


sub getConfigDeclaration {
    return (
            # [name, default, description]
           );
}

sub getDocumentation {
}

sub restart {
}

sub undo {
}
