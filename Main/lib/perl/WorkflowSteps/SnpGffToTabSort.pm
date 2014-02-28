package ApiCommonWorkflow::Main::WorkflowSteps::SnpGffToTabSort;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $outputFile = $self->getParamValue('outputFile');
  my $gffVersion =  $self->getParamValue('gffVersion');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "snpSampleGFFToTabSort.pl --snp_gff $workflowDataDir/$inputFile --out_file $workflowDataDir/$outputFile --gff_version $gffVersion";

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  } else {
      if ($test) {
	  $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
	  $self->runCmd(0, "echo test > $workflowDataDir/$outputFile");
      }else{
	  $self->runCmd($test, $cmd);
      }
  }

}

sub getConfigDeclaration {
  return (
         # [name, default, description]
         # ['', '', ''],
         );
}
