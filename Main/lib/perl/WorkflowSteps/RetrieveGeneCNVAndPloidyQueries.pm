package ApiCommonWorkflow::Main::WorkflowSteps::RetrieveGeneCNVAndPloidyQueries;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use strict;

sub run {
    my ($self, $test, $undo) = @_;
    my $organismAbbrev = $self->getParamValue('organismAbbrev');
    my $geneSourceIdOrthologFile = join("/", $self->getWorkflowDataDir(), $self->getParamValue("geneSourceIdOrthologFile"));
    my $chrsForCalcsFile = join("/", $self->getWorkflowDataDir(), $self->getParamValue('chrsForCalcsFile'));
  
    if ($undo) {
	$self->runCmd(0, "rm -f $geneSourceIdOrthologFile");
	$self->runCmd(0, "rm -f $chrsForCalcsFile");
    } else {  
	if ($test) {
            $self->runCmd($test,"echo test > $geneSourceIdOrthologFile");
	    $self->runCmd($test,"echo test > $chrsForCalcsFile");
	} else { 
            $self->runCmd($test,"runGeneCNVAndPloidyQuery --organismAbbrev $organismAbbrev --geneSourceIdOrthologFile $geneSourceIdOrthologFile --chrsForCalcsFile $chrsForCalcsFile");
	}
    }
}

1;




