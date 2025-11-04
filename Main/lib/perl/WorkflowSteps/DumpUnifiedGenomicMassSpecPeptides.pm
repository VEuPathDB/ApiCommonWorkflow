
package ApiCommonWorkflow::Main::WorkflowSteps::DumpUnifiedGenomicMassSpecPeptides;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $globPattern = $self->getParamValue('globPattern');
  my $outputFile = $self->getParamValue('outputFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $fullGlobPattern = "$workflowDataDir/$globPattern";
  my $fullOutputFile = "$workflowDataDir/$outputFile";

  my $zcatSortCmd = "zcat $fullGlobPattern | sort -k1,1 -k4,4n > $fullOutputFile";
  my $bgzipCmd = "bgzip $fullOutputFile";
  my $tabixCmd = "tabix -p gff ${fullOutputFile}.gz";

  if ($undo) {
      $self->runCmd(0, "rm -f ${fullOutputFile}.gz");
      $self->runCmd(0, "rm -f ${fullOutputFile}.gz.tbi");
  } else {
      if ($test) {
          $self->runCmd(0, "echo test > ${fullOutputFile}.gz");
          $self->runCmd(0, "echo test > ${fullOutputFile}.gz.tbi");
      }
      $self->runCmd($test, $zcatSortCmd);
      $self->runCmd($test, $bgzipCmd);
      $self->runCmd($test, $tabixCmd);
  }
}

1;
