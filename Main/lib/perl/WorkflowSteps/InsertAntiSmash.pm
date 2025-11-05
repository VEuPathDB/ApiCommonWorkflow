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

    my $gusConfigFile = $self->getParamValue('gusConfigFile');

    my $gusConfigFileFullPath = "$workflowDataDir/$gusConfigFile";

    my $args = " --gffFile $gffFileFullPath --ncbiTaxonId $ncbiTaxonId --gusConfigFile $gusConfigFileFullPath --extDbSpec '$extDbSpec'";

    $self->testInputFile('inputGffFile', "$gffFileFullPath");
    $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertAntiSmash", $args);

}
