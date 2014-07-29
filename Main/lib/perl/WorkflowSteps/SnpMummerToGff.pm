package ApiCommonWorkflow::Main::WorkflowSteps::SnpMummerToGff;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $inputFile = $self->getParamValue('inputFile');
  my $gffFile = $self->getParamValue('gffFile');
  my $outputFile = $self->getParamValue('outputFile');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');

  my $strainAbbrev = $self->getOrganismInfo($test, $organismAbbrev)->getStrainAbbrev();
  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "snpFastaMUMmerGff --gff_file $workflowDataDir/$gffFile --mummer_file $workflowDataDir/$inputFile --output_file $workflowDataDir/$outputFile --reference_strain $strainAbbrev --gff_format gff2 --skip_multiple_matches --error_log step.err";


  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  } else {
    $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
    $self->testInputFile('gffFile', "$workflowDataDir/$gffFile");

      if ($test) {
	  $self->runCmd(0, "echo test > $workflowDataDir/$outputFile");
      }
    $self->runCmd($test, $cmd);
  }
}

1;


