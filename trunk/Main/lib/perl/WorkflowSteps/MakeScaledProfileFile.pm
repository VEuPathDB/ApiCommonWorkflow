package ApiCommonWorkflow::Main::WorkflowSteps::MakeScaledProfileFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;


    my $inputFilesDir = $self->getParamValue('inputFilesDir');

    my $outputFile = $self->getParamValue('outputFile');

    my $scalingFacorFile = $self->getParamValue('scalingFacorFile');

    my $workflowDataDir = $self->getWorkflowDataDir();
 

    if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
    } elsif ($test){
	 $self->testInputFile('inputFilesDir', "$workflowDataDir/$inputFilesDir");
	 $self->runCmd(0, "echo test > $workflowDataDir/$outputFile");
    }else{
	     my (@sc,@intensity);

	     open(FA,"$workflowDataDir/$scalingFacorFile") || die "File $workflowDataDir/$scalingFacorFile not found\n";

	     while(<FA>){
		 chomp;
		 @sc = split("\t",$_);
	     }

	     open(IN,"$workflowDataDir/$inputFilesDir") || die "File $workflowDataDir/$inputFilesDir found\n";
	     open(OUT,">$workflowDataDir/$outputFile");
	     while(<IN>){
		 chomp;
		 if(/^id/)
		 {
		     print OUT "$_\n";
		     next;
		 }
		 @intensity = split("\t",$_);
		 print OUT "$intensity[0]";
		 for(my $i=1;$i<scalar(@intensity);$i++)
		 {print OUT "\t".$intensity[$i] * $sc[$i];}
		 print OUT "\n";
	     }
	 }
}


sub getParamsDeclaration {
    return ('inputFilesDir',
            'outputFile',
            'scalingFacorFile'
           );
}


sub getConfigDeclaration {
    return (
            # [name, default, description]
           );
}

