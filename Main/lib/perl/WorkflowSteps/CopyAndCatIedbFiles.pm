package ApiCommonWorkflow::Main::WorkflowSteps::CopyAndCatIedbFiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;


    my $inputDir = $self->getParamValue('inputDir');

    my $outputDir = $self->getParamValue('outputDir');


    my $workflowDataDir = $self->getWorkflowDataDir();

    my $inputDir="$workflowDataDir/$inputDir";
    my $cmd = "cat ";
    my @inputFileNames = $self->getInputFiles($test,$inputDir,'','txt');
    my $size=scalar @inputFileNames;

    if (scalar @inputFileNames==0){
	die "No input files. Please check inputDir: $inputDir\n";
    }else {
	$cmd .= join (" " ,@inputFileNames);
    }

   $cmd .= " >$workflowDataDir/$outputDir/IEDBExport.txt";

    if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputDir/IEDBExport.txt");
    } else {

      $self->testInputFile('inputDir', "$inputDir");
      $self->testInputFile('outputDir', "$workflowDataDir/$outputDir");

      $self->runCmd($test, $cmd);
    }
}

1;


