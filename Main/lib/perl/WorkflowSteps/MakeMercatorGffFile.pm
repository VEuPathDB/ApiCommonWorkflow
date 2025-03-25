package ApiCommonWorkflow::Main::WorkflowSteps::MakeMercatorGffFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;


    my $organismAbbrev = $self->getParamValue('organismAbbrev');
    my $gusConfigFile = $self->getParamValue('gusConfigFile');
    $gusConfigFile = $self->getWorkflowDataDir() . "/$gusConfigFile";

    my $organism = $self->getOrganismInfo($test, $organismAbbrev, $gusConfigFile)->getFullName();
    my $gusConfigFile = $self->getGusConfigFile();
    my $outputFile;

    if($self->getParamValue('outputFile')){

	$outputFile = $self->getParamValue('outputFile');
    }else{

	$outputFile = $organism;

	$outputFile =~ s/\s+/_/g;

	$outputFile = $outputFile.".gff";
    }
 

    my $workflowDataDir = $self->getWorkflowDataDir();

    my $cmd = "mercatorGffDump.pl  --outputFile $workflowDataDir/$outputFile --organismAbbrev '$organismAbbrev' --gusConfigFile $gusConfigFile";

    if ($undo) {
      $self->runCmd(0, "rm -fr $workflowDataDir/$outputFile");
      $self->runCmd(0, "deleteSynteny.pl --organismAbbrev $organismAbbrev --commit");
    } else {
	if ($test) {
	    $self->runCmd(0,"echo hello > $workflowDataDir/$outputFile");
	}
        $self->runCmd($test, $cmd);
    }
}

1;

