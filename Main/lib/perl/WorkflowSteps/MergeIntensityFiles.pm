package ApiCommonWorkflow::Main::WorkflowSteps::MergeIntensityFiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;


    my $inputFilesDir = $self->getParamValue('inputFilesDir');

    my $outputFile = $self->getParamValue('outputFile');

    my $profileElementOrder = $self->getParamValue('profileElementOrder');

    my $workflowDataDir = $self->getWorkflowDataDir();

    #my @inputFileNames = $self->getInputFiles($test,"$workflowDataDir/$inputFilesDir","","int");

    my @inputFileNames = split (/,/,$profileElementOrder);

    my $size=scalar @inputFileNames;

    my %intensityVals;
    my %headerVals;

    if (scalar @inputFileNames==0){
	die "No input files. Please check inputDir: $workflowDataDir/$inputFilesDir\n";
    }else {
	foreach my $file (@inputFileNames){
	    open(IN,"$workflowDataDir/$inputFilesDir/$file") || die "File $file not found\n";
	    my $base = (split(/\//, $file))[-1];
	    $base=~ s/\.int//;
	    $base=~ s/\.max//;
	    $base=~ s/\.min//;
	    $headerVals{header}.="$base\t";
	    while (<IN>){
		chomp;
		my ($id, $value) = split(/\t/, $_);
		    $intensityVals{$id}.="$value\t";
	    }
	} 
    }

    open(OUT,">$workflowDataDir/$outputFile");

    $headerVals{header} =~ s/\t*$//g;

    print OUT "id\t$headerVals{header}\n";

    foreach my $source_id (keys %intensityVals) {
	$intensityVals{$source_id} =~ s/\t*$//g;;
	print OUT "$source_id\t$intensityVals{$source_id}\n";
    }


    if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
    } else {
      $self->testInputFile('inputFilesDir', "$workflowDataDir/$inputFilesDir");

      if ($test) {
        $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
      }

    }
}


1;
