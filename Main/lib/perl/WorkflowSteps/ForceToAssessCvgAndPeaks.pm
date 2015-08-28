package ApiCommonWorkflow::Main::WorkflowSteps::ForceToAssessCvgAndPeaks;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run{
    my ($self, $test, $undo) = @_;
    
    my $hasPairedEnds = $self->getBooleanParamValue('hasPairedEnds');
    my $experimentType = $self->getParamValue('experimentType');
  
    if !($experimentType eq 'histonemod' && !$hasPairedEnds) && !($experimentType eq ='mnase' && $hasPairedEnds) {
	my $note = "Please assess coverage plots.";
	if ($experimentType eq 'histonemod') {
	    $note .= " Moreover, after they are completed, examine peak calls.\n";
	}
	die $note;	
    }  
    
    if ($undo){
    }
    else{
        $self->runCmd($test, $cmd);
    }
}

1;
