package ApiCommonWorkflow::Main::WorkflowSteps::FindChipChipPeaks;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $inputFile = $self->getParamValue('inputFile');
    my $outputPeaksFile = $self->getParamValue('outputPeaksFile');
    my $outputSmoothedFile = $self->getParamValue('outputSmoothedFile');
    #peakFinderArgs: sdMultCutoff numConsecProbes featureMaxGap smootherMaxGap
    my $peakFinderArgs = $self->getParamValue('peakFinderArgs');

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $stepDir = $self->getStepDir();

    my $cmd = "java -Xmx2000m -classpath $ENV{GUS_HOME}/lib/java/GGTools-Array.jar org.apidb.ggtools.array.ChIP_Chip_Peak_Finder $workflowDataDir/$inputFile  $workflowDataDir/$outputPeaksFile $workflowDataDir/$outputSmoothedFile $peakFinderArgs";


    if ($undo) {
	$self->runCmd(0, "rm -f $workflowDataDir/$outputPeaksFile");
	$self->runCmd(0, "rm -f $workflowDataDir/$outputSmoothedFile");
    } else {
	if ($test) {
	    $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputPeaksFile");
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputSmoothedFile");
	}
	$self->runCmd($test, $cmd);
    }
}

sub getParamsDeclaration {
  return (
      'inputFile',
      'outputPeaksFile',
      'outputSmoothedFile',
      'sdMultCutoff',
      'numConsecProbes',
      'featureMaxGap',
      'smootherMaxGap',
      );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


