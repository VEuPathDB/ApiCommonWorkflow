package ApiCommonWorkflow::Main::WorkflowSteps::InsertBlastSimilarities;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $queryTable = $self->getParamValue('queryTable');
  my $queryTableSrcIdCol = $self->getParamValue('queryTableIdCol');
  my $queryExtDbName = $self->getParamValue('queryExtDbName');
  my $subjectTable = $self->getParamValue('subjectTable');
  my $subjectTableSrcIdCol = $self->getParamValue('subjectTableIdCol');
  my $subjectExtDbName = $self->getParamValue('subjectExtDbName');
  my $options = $self->getParamValue('options');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $queryColArg = "--queryTableSrcIdCol $queryTableSrcIdCol" if $queryTableSrcIdCol;

  my $subjectColArg = "--subjectTableSrcIdCol $subjectTableSrcIdCol" if $subjectTableSrcIdCol;

  my $queryExtDbArg = "";
  if ($queryExtDbName) {
    my $queryExtDbVer = $self->getExtDbVersion($test,$queryExtDbName);
    $queryExtDbArg = " --queryExtDbName '$queryExtDbName' --queryExtDbRlsVer '$queryExtDbVer'";
  }

  my $subjectExtDbArg = "";
  if ($subjectExtDbName) {
    my $subjectExtDbVer = $self->getExtDbVersion($test,$subjectExtDbName);
    $subjectExtDbArg = " --subjectExtDbName '$subjectExtDbName' --subjectExtDbRlsVer '$subjectExtDbVer'";
  }

  $self->runCmd(0, "gunzip $workflowDataDir/$inputFile.gz") if (-e "$workflowDataDir/$inputFile.gz");


  $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");


  my $args = "--file $workflowDataDir/$inputFile --queryTable $queryTable $queryColArg $queryExtDbArg --subjectTable $subjectTable $subjectColArg $subjectExtDbArg $options";

  $self->runPlugin($test,$undo, "GUS::Supported::Plugin::InsertBlastSimilarities", $args);
}


1;
