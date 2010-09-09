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

    my $make_bed_cmd = "make_bed.pl $workflowDataDir/$inputFile $stepDir/mapping.bed";
    my $m2c_cmd = "java -Xmx2000m -classpath $ENV{GUS_HOME}/lib/java/GGTools-SSA.jar org.apidb.ggtools.ssa.M2C $stepDir/mapping.bed $workflowDataDir/$outputUnNormFile makeCoverage.log -name '$sampleName' -chunks 2 -ucsc";
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


