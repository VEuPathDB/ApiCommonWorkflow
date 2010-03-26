package ApiCommonWorkflow::Main::WorkflowSteps::InsertBlastSimilarities;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $queryTable = $self->getParamValue('queryTable');
  my $queryTableSrcIdCol = $self->getParamValue('queryTableIdCol');
  my $queryExtDbRlsSpec = $self->getParamValue('queryExtDbRlsSpec');
  my $subjectTable = $self->getParamValue('subjectTable');
  my $subjectTableSrcIdCol = $self->getParamValue('subjectTableIdCol');
  my $subjectExtDbRlsSpec = $self->getParamValue('subjectExtDbRlsSpec');
  my $options = $self->getParamValue('options');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $queryColArg = "--queryTableSrcIdCol $queryTableSrcIdCol" if $queryTableSrcIdCol;

  my $subjectColArg = "--subjectTableSrcIdCol $subjectTableSrcIdCol" if $subjectTableSrcIdCol;

  my $queryExtDbArg = "";
  if ($queryExtDbRlsSpec) {
    my ($queryDbName, $queryDbRlsVer) = $self->getExtDbInfo($test,$queryExtDbRlsSpec);
    $queryExtDbArg = " --queryExtDbName '$queryDbName' --queryExtDbRlsVer '$queryDbRlsVer'";
  }

  my $subjectExtDbArg = "";
  if ($subjectExtDbRlsSpec) {
    my ($subjectDbName, $subjectDbRlsVer) = $self->getExtDbInfo($test,$subjectExtDbRlsSpec);
    $subjectExtDbArg = " --subjectExtDbName '$subjectDbName' --subjectExtDbRlsVer '$subjectDbRlsVer'";
  }

  $self->runCmd(0, "gunzip $workflowDataDir/$inputFile.gz") if (-e "$workflowDataDir/$inputFile.gz");

  if ($test) {
    $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
  }

  my $args = "--file $workflowDataDir/$inputFile --queryTable $queryTable $queryColArg $queryExtDbArg --subjectTable $subjectTable $subjectColArg $subjectExtDbArg $options";

  $self->runPlugin($test,$undo, "GUS::Supported::Plugin::InsertBlastSimilarities", $args);
}

sub getParamsDeclaration {
  return (
	  'inputFile',
	  'queryTable',
	  'queryTableSrcIdCol',
	  'queryExtDbRlsSpec',
	  'subjectTable',
	  'subjectTableSrcIdCol',
	  'subjectExtDbRlsSpec',
	  'options',
	);
}

sub getConfigurationDeclaration {
  return ();
}

