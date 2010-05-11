package ApiCommonWorkflow::Main::WorkflowSteps::MakeMercatorGffFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;


    my $organism = $self->getParamValue('organismFullName');
    my $outputFile;

    if($self->getParamValue('outputFile')){

	$outputFile = $self->getParamValue('outputFile');
    }else{

	$outputFile = $organism;

	$outputFile =~ s/\s+/_/g;

	$outputFile = $outputFile.".gff";
    }
 

    my $workflowDataDir = $self->getWorkflowDataDir();
 
  
    my $cmd = "mercatorGffDump.pl  --outputFile $workflowDataDir/$outputFile --organism '$organism'";



    if ($undo) {
      $self->runCmd(0, "rm -fr $workflowDataDir/$outputFile");
    } else {
	if ($test) {
	    $self->runCmd(0,"echo hello > $workflowDataDir/$outputFile");
	}else{
	    $self->runCmd($test, $cmd);
	}
    }
}

sub getParamsDeclaration {
    return (
            'organism',
            'outputFile'
           );
}


sub getConfigDeclaration {
    return (
            # [name, default, description]
              ['ncbiBlastPath', "", ""]
           );
}

