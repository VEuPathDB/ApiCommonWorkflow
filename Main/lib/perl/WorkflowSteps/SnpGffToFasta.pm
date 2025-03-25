package ApiCommonWorkflow::Main::WorkflowSteps::SnpGffToFasta;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $inputFile = $self->getParamValue('inputFile');
  my $outputFastaDir = $self->getParamValue('outputFastaDir');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $gusConfigFile = $self->getParamValue('gusConfigFile');
  $gusConfigFile = $self->getWorkflowDataDir() . "/$gusConfigFile";

  my $strainAbbrev = $self->getOrganismInfo($test, $organismAbbrev, $gusConfigFile)->getStrainAbbrev();

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "snpFastaMUMmerGff --gff_file $workflowDataDir/$inputFile --reference_strain $strainAbbrev --output_file $workflowDataDir/$outputFastaDir/SNPs.fasta --make_fasta_file_only --gff_format gff2";

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputFastaDir/*SNPs.fasta");
  } else {
    $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
      if ($test) {
        $self->runCmd(0, "echo test > $workflowDataDir/$outputFastaDir/SNPs.fasta");
      }
    $self->runCmd($test, $cmd);
  }
}

1;


