package ApiCommonWorkflow::Main::WorkflowSteps::InsertExemplarGenes;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $inputFile = $self->getParamValue('inputFile');

    my $workflowDataDir = $self->getWorkflowDataDir();

    my $args = "--file $workflowDataDir/$inputFile";

   if ($test) {
     $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
   }

   $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::CreateGenesForGeneFeatures", $args);
}

sub getConfigDeclaration {
    return (
            # [name, default, description]
           );
}

