package ApiCommonWorkflow::Main::WorkflowSteps::MakeExonJunctionCall;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $uniqueFile = $self->getParamValue('uniqueFile');
    my $nonUniqueFile = $self->getParamValue('nonUniqueFile');
    my $genomeFastaFile  = $self->getParamValue('genomeFastaFile');
    my $geneAnnotationFile = $self->getParamValue('geneAnnotationFile');
    my $outputFile = $self->getParamValue('outputFile');

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $stepDir = $self->getStepDir();

    my $cmd = "make_RUM_junctions_file.pl $workflowDataDir/$uniqueFile $workflowDataDir/$nonUniqueFile $workflowDataDir/$genomeFastaFile $workflowDataDir/$geneAnnotationFile $workflowDataDir/$outputFile.rum $workflowDataDir/outputFile.bed $workflowDataDir/outputFile.highQuality.bed";

    if ($undo) {
	$self->runCmd(0, "rm -f $workflowDataDir/$outputFile.rum");
	$self->runCmd(0, "rm -f $workflowDataDir/$outputFile.bed");
	$self->runCmd(0, "rm -f $workflowDataDir/$outputFile.highQuality.bed");
    } else {
	if ($test) {
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputFile.rum");
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputFile.bed");
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputFile.highQuality.bed");
	}
	$self->runCmd($test, $cmd);
    }
}

sub getParamsDeclaration {
  return (
      'uniqueFile',
      'nonUniqueFile',
      'genomeFastaFile',
      'geneAnnotationFile',
      'outputFile',
      );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


