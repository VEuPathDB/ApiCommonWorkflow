package ApiCommonWorkflow::Main::WorkflowSteps::SymLinkMaskedGenomeFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

# Symlinks the RepeatMasked genome when MaskGenome produced one, otherwise the
# unmasked genome.  Huge non-EBI genomes skip RepeatMasker and have no EBI
# blocked.seq to copy, so no masked fasta exists for them.
sub run {
  my ($self, $test, $undo) = @_;

  my $maskedGenomeFile = $self->getParamValue('maskedGenomeFile');
  my $unmaskedGenomeFile = $self->getParamValue('unmaskedGenomeFile');
  my $toFile = $self->getParamValue('toFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$toFile");
    return;
  }

  my $fromFile = -e "$workflowDataDir/$maskedGenomeFile"
    ? $maskedGenomeFile
    : $unmaskedGenomeFile;

  $self->error("Neither the masked genome '$workflowDataDir/$maskedGenomeFile' nor the unmasked genome '$workflowDataDir/$unmaskedGenomeFile' exists")
    unless -e "$workflowDataDir/$fromFile";

  $self->log("Linking $toFile to $fromFile");

  $self->runCmd(0, "ln -sf $workflowDataDir/$fromFile $workflowDataDir/$toFile");
}

1;
