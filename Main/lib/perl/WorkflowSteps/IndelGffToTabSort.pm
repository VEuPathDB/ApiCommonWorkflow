package ApiCommonWorkflow::Main::WorkflowSteps::IndelGffToTabSort;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $outputFile = $self->getParamValue('outputFile');
  my $gffVersion =  $self->getParamValue('gffVersion');

  my $merge1UndoneStrains = $self->getParamValue('merge1UndoneStrains');
  my $merge2UndoneStrains = $self->getParamValue('merge2UndoneStrains');
  my $merge3UndoneStrains = $self->getParamValue('merge3UndoneStrains');


  my $strain = $self->getParamValue('strain');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "indelSampleGFFToTabSort.pl --snp_gff $workflowDataDir/$inputFile --out_file $workflowDataDir/$outputFile --gff_version $gffVersion";

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");

    $self->runCmd(0, "echo $strain >>$workflowDataDir/$merge1UndoneStrains");
    $self->runCmd(0, "echo $strain >>$workflowDataDir/$merge2UndoneStrains");
    $self->runCmd(0, "echo $strain >>$workflowDataDir/$merge3UndoneStrains");

  } else {
    $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
      if ($test) {
	  $self->runCmd(0, "echo test > $workflowDataDir/$outputFile");
      }
    $self->runCmd($test, $cmd);
  }
}

1;
