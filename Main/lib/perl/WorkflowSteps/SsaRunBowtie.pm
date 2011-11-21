package ApiCommonWorkflow::Main::WorkflowSteps::SsaRunBowtie;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $inputIndexesDir = $self->getParamValue('inputIndexesDir');
    my $inputFwdSeqsFile = $self->getParamValue('inputFwdSeqsFile');
    my $inputFwdQualsFile = $self->getParamValue('inputFwdQualsFile');
    my $inputRevSeqsFile = $self->getParamValue('inputRevSeqsFile');
    my $inputRevQualsFile = $self->getParamValue('inputRevQualsFile');
    my $outputFile = $self->getParamValue('outputFile');
    my $bowtieParams = $self->getParamValue('bowtieParams');
    my $seqsFileType = $self->getParamValue('seqsFileType');
    my $isPairedEnds = $self->getBooleanParamValue('isPairedEnds');
    my $isColorSpace = $self->getBooleanParamValue('isColorSpace');
    my $haveQuals = $self->getBooleanParamValue('haveQuals');

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $stepDir = $self->getStepDir();

    my %fileTypes = ('FASTA' => '-f',
		     'FASTQ' => '-q',
		     'raw' => '-r',
		    );

    my $fileTypeArg = $fileTypes{$seqsFileType};
    my $allowed = join(", ", keys(%fileTypes));
    $self->error("Invalid seqsFileType '$seqsFileType'.  Allowed types are: $allowed") unless $fileTypeArg;

    my $colorSpaceArg = $isColorSpace? ' -C' : '';

    my $fwdSeqsArg = $isPairedEnds? '-1 ' : '';
    my $fwdQualsArg = $isPairedEnds? '--Q1 ' : '-Q';

    my $cmd = "bowtie $bowtieParams --best --strata $workflowDataDir/$inputIndexesDir/genomicIndexes $colorSpaceArg $fwdSeqsArg $workflowDataDir/$inputFwdSeqsFile";

    $cmd .= "$fwdQualsArg $workflowDataDir/$inputFwdQualsFile" if $haveQuals;

    $self->testInputFile('inputFwdSeqsFile', "$workflowDataDir/$inputFwdSeqsFile");
    $self->testInputFile('inputFwdQualsSeqsFile', "$workflowDataDir/$inputFwdQualsFile") if $haveQuals;
    $self->testInputFile('inputIndexesDir', "$workflowDataDir/$inputIndexesDir");

    if ($isPairedEnds) {
	$cmd .= " -2 $workflowDataDir/$inputRevSeqsFile";
	$self->testInputFile('inputRevSeqsFile', "$workflowDataDir/$inputRevSeqsFile");
	if ($haveQuals) {
	    $cmd .= " -Q2 $inputRevQualsFile";
	    $self->testInputFile('inputRevQualsFile', "$workflowDataDir/$inputRevQualsFile");
	}
    }

    if ($undo) {
	$self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
    } else {
	if ($test) {
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
	}
	$self->runCmd($test, $cmd);
    }
}


sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


