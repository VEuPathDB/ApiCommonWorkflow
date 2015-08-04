package ApiCommonWorkflow::Main::WorkflowSteps::AddStrainSuffixToVariations;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $inputFile = $self->getParamValue('inputFile');
  my $outputFile = $self->getParamValue('outputFile');
  my $suffix = $self->getParamValue('suffix');

  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $organismStrain = $self->getOrganismInfo($test, $organismAbbrev)->getStrainAbbrev();

  my $workflowDataDir = $self->getWorkflowDataDir();

  # Add suffix to variation rows except for the reference
  my $cmd = "snpAddStrainSuffixToVariations.pl --inputFile $workflowDataDir/$inputFile --outputFile $workflowDataDir/$outputFile --suffix $suffix --referenceStrain $organismStrain --doNotOutputReference";

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  } else {
    $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
      if ($test) {
        $self->runCmd(0, "echo test > $workflowDataDir/$outputFile");
      }
    $self->runCmd($test, $cmd);
  }
}

1;


