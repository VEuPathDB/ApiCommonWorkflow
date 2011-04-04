package ApiCommonWorkflow::Main::WorkflowSteps::AnalyzeTranscriptExpression;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
    my ($self, $test, $undo) = @_;

    my $configXmlFile = $self->getParamValue('configXmlFile');
    my $resourceDataDir = $self->getParamValue('resourceDataDir');
    my $outputDir = $self->getParamValue('outputDir');

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $stepDir = $self->getStepDir();

    my $cmd = "doTranscriptExpression $workflowDataDir/$configXmlFile $workflowDataDir/$resourceDataDir $workflowDataDir/$outputDir";

    if ($undo) {
	$self->runCmd(0, "rm -f $workflowDataDir/$outputDir");
    } else {
	if ($test) {
	    $self->testInputFile('', "$workflowDataDir/$configXmlFile");
	    $self->testInputFile('', "$workflowDataDir/$resourceDataDir");
	    $self->runCmd(0,"mkdir $workflowDataDir/$outputDir");
	}
	$self->runCmd($test, $cmd);
    }
}

sub getParamsDeclaration {
  return (
      'configXmlFile',
      'resourceDataDir',
      'outputDir',
      );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


