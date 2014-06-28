package ApiCommonWorkflow::Main::WorkflowSteps::FixPsipredFileNames;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $inputDir = $self->getParamValue('inputDir');
    my $outputDir = $self->getParamValue('outputDir');
    my $workflowDataDir = $self->getWorkflowDataDir();

    if ($undo) {
      $self->runCmd(0, "rm -rf $workflowDataDir/$outputDir");
    } else {    
	if ($test) {
	    $self->runCmd(0,"mkdir -p  $workflowDataDir/$outputDir");
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputDir/testFile");
        }
        $self->runCmd(0,"cp -r $workflowDataDir/$inputDir  $workflowDataDir/$outputDir");
        opendir(DIR, "$workflowDataDir/$outputDir") || die "Can't open directory '$workflowDataDir/$outputDir'";
        my @files = readdir(DIR);
        foreach my $file (@files) {
          next if $file=~ /^\.\.?$/;  # skip . and ..
          my $original = $file;
          $file =~ s/_DASH_/-/g;
          $self->runCmd($test, "mv $workflowDataDir/$outputDir/$original $workflowDataDir/$outputDir/$file");
	}
    }
}

1;


