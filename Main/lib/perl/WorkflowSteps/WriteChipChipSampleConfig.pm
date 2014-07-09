package ApiCommonWorkflow::Main::WorkflowSteps::WriteChipChipSampleConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $file = $self->getParamValue('file');
  my $configOutputFile = $self->getParamValue('configOutputFile');

  my $analysisName = $self->getParamValue('analysisName');
  my $protocolName = $self->getParamValue('protocolName');
  my $lifeCycleStage = $self->getParamValue('LifeCycleStage');
  my $antibody = $self->getParamValue('Antibody');
  my $genotype = $self->getParamValue('Genotype');
  my $replicate = $self->getParamValue('Replicate');
  my $strain = $self->getParamValue('Strain');
  my $treatment = $self->getParamValue('Treatment');
  my $cellType = $self->getParamValue('CellType');

  my $paramValues = "--file $file --outputFile $workflowDataDir/$configOutputFile --name '$analysisName' --protocol '$protocolName' --protocolParam 'Life Cycle Stage|$lifeCycleStage' --protocolParam 'Antibody|$antibody' --protocolParam 'Genotype|$genotype' --protocolParam 'Replicate|$replicate' --protocolParam 'Strain|$strain' --protocolParam 'Treatment|$treatment' --protocolParam 'Cell Type|$cellType'";

  my $cmd = "writeRadAnalysisConfig $paramValues";

  if ($undo) {
    $self->runCmd(0, "rm $workflowDataDir/$configOutputFile");
  } else {
      if ($test) {
	  $self->runCmd(0,"echo test > $workflowDataDir/$configOutputFile");
      }
      $self->runCmd($test, $cmd);
  }
}

1;
