package ApiCommonWorkflow::Main::WorkflowSteps::LoadNrdbXrefs;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $xrefsFile = $self->getParamValue('xrefsFile');

  my $organismAbbrev = $self->getParamValue('organismAbbrev');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--DbRefMappingFile '$workflowDataDir/$xrefsFile' --columnSpec \"secondary_identifier,primary_identifier\" --organismAbbrev $organismAbbrev";

  $self->testInputFile('xrefsFile', "$workflowDataDir/$xrefsFile");


   $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertNrdbXrefs", $args);


}


##this step loads the results of mapping an NR protein record to an annotated protein based on their sequences
##the protein gi numbers and source_ids from the nrdb file record are inserted into sres.dbref
##and are linked via dots.dbrefnafeature rows to the dots.genefeature row corresponding to the annotated protein
##need to avoid mapping proteins (from nr record)  from organisms in the same project
##will alternative splicing cause a problem with this?

1;
