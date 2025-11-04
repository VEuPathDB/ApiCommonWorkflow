
package ApiCommonWorkflow::Main::WorkflowSteps::DumpJBrowseFlatFiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $jbrowseDir = $self->getParamValue('jbrowseDir');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $seqSizes = $self->getParamValue('seqSizes');

  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$jbrowseDir/*.gff.gz");
      $self->runCmd(0, "rm -f $workflowDataDir/$jbrowseDir/*.bed.gz");
      $self->runCmd(0, "rm -f $workflowDataDir/$jbrowseDir/*.tbi");
      $self->runCmd(0, "rm -f $workflowDataDir/$jbrowseDir/*.bw");
  } else {
      if ($test) {
          $self->runCmd(0, "echo test > $workflowDataDir/$jbrowseDir/test.txt");
      }
      $self->runCmd($test, "jbrowseDumpAllFeatures --output_directory $workflowDataDir/$jbrowseDir --organism_abbrev $organismAbbrev --seq_sizes $workflowDataDir/$seqSizes");
  }
}

1;
