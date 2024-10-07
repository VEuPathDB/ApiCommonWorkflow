package ApiCommonWorkflow::Main::WorkflowSteps::InsertInterproResults;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $resultsFile = $self->getParamValue('resultsFile');
    my $ncbiTaxId = $self->getParamValue('ncbiTaxId');
    my $genomeExtDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');

    my $workflowDataDir = $self->getWorkflowDataDir();

    my $args = "--resultsFile=$workflowDataDir/$resultsFile --ncbiTaxId=$ncbiTaxId --genomeExtDbRlsSpec='$genomeExtDbRlsSpec'";
  
    if($undo) {
        $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertInterproResults", $args);
    } else {
        $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertInterproResults", $args);
    }

}

1;
