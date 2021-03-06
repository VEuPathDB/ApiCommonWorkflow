package ApiCommonWorkflow::Main::WorkflowSteps::RunMummer;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self,$test, $undo) = @_;


    my $genomicSeqsFile = $self->getParamValue('genomicSeqsFile');
    my $inputDir = $self->getParamValue('inputFastaDir');
    my $outputFile = $self->getParamValue('outputFile');

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $mummerPath = $self->getConfig('mummerPath');

    my @inputFileNames = $self->getInputFiles($test,"$workflowDataDir/$inputDir",'','fasta');

    if (scalar @inputFileNames==0){
	die "No input files. Please check inputDir: $inputDir\n";
    }

    if ($undo) {
	$self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
    }else{
      $self->testInputFile('inputDir', "$workflowDataDir/$inputDir");
      $self->testInputFile('genomicSeqsFile', "$workflowDataDir/$genomicSeqsFile");

	if ($test) {
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
        }            
	    foreach my $inputFile (@inputFileNames){
              my $cmd = "callMUMmerForSnps --mummerDir $mummerPath --query_file $workflowDataDir/$genomicSeqsFile --output_file $workflowDataDir/$outputFile --snp_file $inputFile"; 
              $self->runCmd($test,$cmd);
	}
    }
}


1;
