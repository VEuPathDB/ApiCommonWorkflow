package ApiCommonWorkflow::Main::WorkflowSteps::MakeOrthofinderPeripheralInputDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $proteomesDir = join("/", $workflowDataDir, $self->getParamValue("proteomesDir"));
    my $outputDir = join("/", $workflowDataDir, $self->getParamValue("outputDir"));

    if ($undo) {
	$self->runCmd(0, "rm -rf $outputDir/fastas.tar.gz");
	$self->runCmd(0, "rm -rf $outputDir/fastas/*");
    }
    elsif ($test) {
	$self->runCmd(0, "echo 'test' > $outputDir/fastas/test.fasta");
	$self->runCmd(0, "tar -zcvf fastas.tar.gz $outputDir/fastas");
    }
    else {

	$self->runCmd(0, "cp ${proteomesDir}/*.fasta $outputDir/fastas/");
      
        $self->runCmd(0, "cp ${workflowDataDir}/**/orthoPeripheralProteomes/*.fasta $outputDir/fastas/");

	opendir(DIR, "$outputDir/fastas") || die "Can't open input directory '$outputDir/fastas'\n";
	my @fastas = readdir('DIR');
	closedir(DIR);
	die "Input directory $outputDir/fastas does not contain any fastas" unless scalar(@fastas);

	$self->runCmd(0, "filterForLongestTranscript --fastaDir $outputDir/fastas");

	$self->runCmd(0, "tar -zcvf fastas.tar.gz -C $outputDir fastas");
	$self->runCmd(0, "mv fastas.tar.gz $outputDir/");
    }
}

1;
