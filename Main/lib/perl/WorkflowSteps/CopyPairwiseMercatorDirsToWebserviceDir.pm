package ApiCommonWorkflow::Main::WorkflowSteps::CopyPairwiseMercatorDirsToWebserviceDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $mercatorOutputsDir = $self->getParamValue('mercatorOutputsDir');

    my $mercatorWebsvcDir = $self->getParamValue('mercatorWebsvcDir');

    my $websiteFilesDir = $self->getWebsiteFilesDir($test);

    my $outputDir   = "$websiteFilesDir/$mercatorWebsvcDir";

    my $workflowDataDir = $self->getWorkflowDataDir();

    my $copiedPairDirsFile ="copiedPairDirsFile.txt";

    if ($undo) {
	$self->runCmd(0, "rm -fr $outputDir");
	return;
    }

    -e $outputDir && $self->error("Mercator web svc dir '$outputDir' already exists");
    mkdir($outputDir) || $self->error("Can't make mercator web svc dir '$outputDir'");

    opendir(MERCATORDIR,"$workflowDataDir/$mercatorOutputsDir") or $self->error("Could not open $workflowDataDir/$mercatorOutputsDir for reading.\n");

    open(COPIED, $workflowDataDir/$copiedPairDirsFile) or die "Cannot open file $workflowDataDir/$copiedPairDirsFile for reading: $!";
    my @copiedPairDirs =  map { chomp; $_ } <COPIED>;
    close COPIED;

    foreach my $pairDir (readdir MERCATORDIR){
      next if ($pairDir =~ m/^\./ || grep( /^$pairDir$/, @copiedPairDirs));
      $self->runCmd(0,"mkdir -p $outputDir/$pairDir");
      if (!$test) {
	$self->runCmd($test,"cp -R $workflowDataDir/$mercatorOutputsDir/$pairDir/alignments $outputDir/$pairDir");
	$self->runCmd($test,"cp -R $workflowDataDir/$mercatorOutputsDir/$pairDir/*.agp $outputDir/$pairDir");
    $self->runCmd($test, "echo $pairDir >>$workflowDataDir/$copiedPairDirsFile");
      }
    }
}
1;
