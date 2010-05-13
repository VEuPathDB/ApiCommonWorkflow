package ApiCommonWorkflow::Main::WorkflowSteps::SsaMakeNormalizedCoverageFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $inputFile = $self->getParamValue('inputUniqueMappingFile');
    my $outputFile = $self->getParamValue('outputFile');
    my $sampleName = $self->getParamValue('sampleName');

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $stepDir = $self->getStepDir();

    my $make_bed_cmd = "make_bed.pl $workflowDataDir/$inputFile $stepDir/mapping.bed";
    my $m2c_cmd = "java -Xmx2000m -classpath $ENV{GUS_HOME}/lib/java/GGTools-SSA.jar org.apidb.ggtools.ssa.M2C $stepDir/mapping.bed $stepDir/output.cov -ucsc -name '$sampleName' -chunks 2 ";
    my $normalize_cmd = "normalizeCov.pl $stepDir/output.cov $workflowDataDir/$outputFile";

    if ($undo) {
	$self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
	$self->runCmd(0, "rm -f $stepDir/mapping.bed");
	$self->runCmd(0, "rm -f $stepDir/output.cov");
    } else {
	if ($test) {
	    $self->testInputFile('inputUniqueMappingFile', "$workflowDataDir/$inputFile");
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
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


