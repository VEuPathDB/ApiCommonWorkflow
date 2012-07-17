package ApiCommonWorkflow::Main::WorkflowSteps::MakeGeneInstanceClusters;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;
    my $mercatorInputsDir = $self->getParamValue('mercatorInputsDir');
    my $mercatorOutputDir = $self->getParamValue('mercatorOutputDir');
    my $outputFile = $self->getParamValue('outputFile');

    my $cndSrcBin = $self->getConfig('cndSrcBin');

    my $workflowDataDir = $self->getWorkflowDataDir();

    my $GFF_VERSION = 3;

    if ($undo) {
	$self->runCmd(0, "rm -fr $workflowDataDir/$outputFile");
	$self->runCmd(0, "rm -fr $workflowDataDir/$outputFile.Clusters");
	return;
    }

    # see if there are multiple strains.  if not, exit
    my $inputsDir = "$workflowDataDir/$mercatorInputsDir";
    opendir(INPUT, $inputsDir) or $self->error("Could not open mercator inputs dir '$inputsDir' for reading.");

    my @gffFiles;
    foreach my $file (readdir INPUT) {
        push @gffFiles, "$inputsDir/$file" if $file =~ /\.gff$/;
    }

    closedir INPUT;

    if (scalar @gffFiles == 1) {
	$self->log("Only found 1 organism in input dir $inputsDir.  No comparision needed.  Exiting.");
	return;
    }    

    if ($test) {
	$self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
    }

    my @gffParams = map {"--gff_file $_"} @gffFiles;
    my $gffFileString = join(" ", @gffParams);

    my $cmd = "makeGenesFromMercator --mercatorOutputDir $workflowDataDir/$mercatorOutputDir --cndSrcBin $cndSrcBin  $gffFileString --verbose --gff_version $GFF_VERSION > $workflowDataDir/$outputFile.Clusters";
    $self->runCmd($test, $cmd);

    $cmd = "grep ^cluster_ $workflowDataDir/$outputFile.Clusters >$workflowDataDir/$outputFile";
    $self->runCmd($test,$cmd);
}


sub getConfigDeclaration {
    return (
            # [name, default, description]
           );
}

