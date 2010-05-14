package ApiCommonWorkflow::Main::WorkflowSteps::MergeIntensityFiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;


    my $inputFilesDir = $self->getParamValue('inputFilesDir');

    my $outputFile = $self->getParamValue('outputFile');

    my $workflowDataDir = $self->getWorkflowDataDir();

    my @inputFileNames = $self->getInputFiles($test,"$workflowDataDir/$inputFilesDir","","int");

    my $size=scalar @inputFileNames;

    my %intensityVals;

    if (scalar @inputFileNames==0){
	die "No input files. Please check inputDir: $workflowDataDir/$inputFilesDir\n";
    }else {
	foreach my $file (@inputFileNames){
	    open(IN,"$file") || die "File $file not found\n";
	    while (<IN>){
		chomp;
		my ($id, $value) = split(/\t/, $_);
		if ($intensityVals{$id}){
		    my $temp = $intensityVals{$id};
		    $temp = "$temp\t$value";
		    $intensityVals{$id}=$temp;
		}else{
		    $intensityVals{$id}=$value;
		}
	    }
	} 
    }

    open(OUT,">$workflowDataDir/$outputFile");

    foreach my $source_id (keys %intensityVals) {
	print OUT "$source_id\t$intensityVals{$source_id}\n";
    }


    if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
    } else {
    if ($test) {
      $self->testInputFile('inputFilesDir', "$workflowDataDir/$inputFilesDir");
      $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
    }
}
}

sub getParamsDeclaration {
    return ('inputDirRelativeToDownloadsDir',
            'organismName',
            'outputDir'
           );
}


sub getConfigDeclaration {
    return (
            # [name, default, description]
           );
}

