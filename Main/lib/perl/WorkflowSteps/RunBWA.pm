package ApiCommonWorkflow::Main::WorkflowSteps::RunBWA;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $genomicSeqsFile = $self->getParamValue('genomicSeqsFile');
    my $inputShortSeqsFile = $self->getParamValue('inputShortSeqsFile');
    my $pairedReadFile = $self->getParamValue('pairedReadFile');
    my $hasPairedReads = $self->getBooleanParamValue('hasPairedReads');
    my $outputFile = $self->getParamValue('outputFile');
    my $inputIndexesDir = $self->getParamValue('inputIndexesDir');
    my $strain = $self->getParamValue('strain');
    my $isHaploid = $self->getBooleanParamValue('isHaploid');
    my $varScanJarFile = $self->getConfig('varScanJarFile');
    my $workflowDataDir = $self->getWorkflowDataDir();
    my $stepDir = $self->getStepDir();

    my $minPercentCutoff = $isHaploid? 51 : 34;
    my $percentCutoff = $isHaploid? 80 : 40;

    my $cmd = "runBWA_HTS.pl --mateA $workflowDataDir/$inputShortSeqsFile --fastaFile $workflowDataDir/$genomicSeqsFile --bwaIndex $workflowDataDir/$inputIndexesDir/genomicIndexes --strain '$strain' --outputPrefix $workflowDataDir/$outputFile --percentCutoff $percentCutoff --minPercentCutoff $minPercentCutoff --varscan $varScanJarFile";
    $cmd .= " --mateB $workflowDataDir/$pairedReadFile" if ($hasPairedReads);
    if ($undo) {
	$self->runCmd(0, "rm -f $workflowDataDir/$outputFile.*");
    } else {
      $self->testInputFile('inputCoverageFile', "$workflowDataDir/$inputIndexesDir");
      $self->testInputFile('inputShortSeqsFile', "$workflowDataDir/$inputShortSeqsFile");
      $self->testInputFile('pairedReadsFile', "$workflowDataDir/$pairedReadFile") if ($hasPairedReads);

	if ($test) {
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputFile.gff");
	}
	$self->runCmd($test, $cmd);
    }
}

1;

