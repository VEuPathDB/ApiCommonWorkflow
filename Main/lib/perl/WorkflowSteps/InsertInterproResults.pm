package ApiCommonWorkflow::Main::WorkflowSteps::InsertInterproResults;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $resultsFile = $self->getParamValue('resultsFile');
    my $transcriptSourceId = $self->getParamValue('transcriptSourceId');
    my $geneSourceId = $self->getParamValue('geneSourceId');
    my $ncbiTaxId = $self->getParamValue('ncbiTaxId');

    my $workflowDataDir = $self->getWorkflowDataDir();
  
    my $args = <<"EOF";
--resultsFile=$workflowDataDir/$resultsFile \\
--transcriptSourceId=$transcriptSourceId \\
--geneSourceId=$geneSourceId \\
--ncbiTaxId=$ncbiTaxId \\
EOF

    if($undo) {
        $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertInterproResults", $args);
    } else {
        $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertInterproResults", $args);
    }

}

1;
