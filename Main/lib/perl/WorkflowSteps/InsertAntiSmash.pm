package ApiCommonWorkflow::Main::WorkflowSteps::InsertAntiSmash;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $workflowDataDir = $self->getWorkflowDataDir();

    my $extDbSpec = $self->getParamValue('extDbSpec');

    my $ncbiTaxonId = $self->getParamValue('ncbiTaxonId');

    my $gffFile = $self->getParamValue('gffFile');

    my $gffFileFullPath = "$workflowDataDir/$gffFile";

    my $args = " --gffFile $gffFileFullPath --ncbiTaxonId $ncbiTaxonId --extDbSpec '$extDbSpec'";

    $self->testInputFile('inputGffFile', "$gffFileFullPath");
    $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertAntiSmash", $args);

}
