package ApiCommonWorkflow::Main::WorkflowSteps::InsertStudyCharacteristics;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;
  my $args = join(" ", map { sprintf("--%s %s", $_, $self->getParamValue($_)) } qw/datasetName owlFile commit/);
  my $datasetName = $self->getParamValue('datasetName');
  my $args = sprintf("--datasetName %s --file %s --owlFile %s",
    $datasetName,
    join("/", $self->getWorkflowDataDir(), $datasetName, 'final', $self->getParamValue('file')),
    $self->getParamValue('owlFile'),
  );
  
  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertStudyCharacteristics", $args);

}


1;
