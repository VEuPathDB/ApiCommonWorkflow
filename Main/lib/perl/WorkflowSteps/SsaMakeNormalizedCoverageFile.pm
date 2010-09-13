package ApiCommonWorkflow::Main::WorkflowSteps::SsaMakeNormalizedCoverageFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $inputFile = $self->getParamValue('inputFile');
    my $outputUnNormFile = $self->getParamValue('outputUnNormFile');
    my $outputNormFile = $self->getParamValue('outputNormFile');
    my $sampleName = $self->getParamValue('sampleName');

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $stepDir = $self->getStepDir();

    my $make_bed_cmd = "sort_RUM_by_location.pl $workflowDataDir/$inputFile $workflowDataDir/$inputFile.sorted";
    my $m2c_cmd = "rum2cov.pl $workflowDataDir/$inputFile.sorted $workflowDataDir/$outputUnNormFile";
    my $normalize_cmd = "normalizeCov.pl $workflowDataDir/$outputUnNormFile > $workflowDataDir/$outputNormFile";

    if ($undo) {
	$self->runCmd(0, "rm -f $stepDir/mapping.bed");
	$self->runCmd(0, "rm -f $workflowDataDir/$outputUnNormFile");
	$self->runCmd(0, "rm -f $workflowDataDir/$outputNormFile");
    } else {
	if ($test) {
	    $self->testInputFile('inputUniqueMappingFile', "$workflowDataDir/$inputFile");
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputNormFile");
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputUnNormFile");
	}
	$self->runCmd($test, $make_bed_cmd);
	$self->runCmd($test, $m2c_cmd);
	$self->runCmd($test, $normalize_cmd);
    }
}

sub getParamsDeclaration {
  return (
      'inputUniqueMappingFile',
      'outputNormalizedCovFile',
      'sampleName',
      );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


