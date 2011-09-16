package ApiCommonWorkflow::Main::WorkflowSteps::MakeGeneInstanceClusters;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;
    my $mercatorOutputDir = $self->getParamValue('mercatorOutputDir');
    my $outputFile = $self->getParamValue('outputFile');
    my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');

    my $cndSrcBin = $self->getConfig('cndSrcBin');

    my $workflowDataDir = $self->getWorkflowDataDir();

    if ($undo) {
	$self->runCmd(0, "rm -fr $workflowDataDir/$outputFile");
	return;
    }

    # get ext db rls ids for each strain's primary genome. discover strain abbrevs from input dir
    my @extDbRlsIds;
    opendir(DIR, $mercatorOutputDir) or $self->error("Could not open mercator output dir '$mercatorOutputDir'.\n");
    foreach my $file (readdir DIR){
	next unless ($file =~ /^(.+)\.agp/);    # we get one .agp per strain.
	my $organismAbbrev = $1;
	my $extDbName = "$organismAbbrev_primary_genome_RSRC";  # generate resource name
	my $extDbVersion = $self->getExtDbVersion($test, $extDbName);
	my $extDbRlsId = $self->getExtDbRlsSpec($test,"$extDbName|$extDbVersion");
	push(@extDbRlsIds, $extDbRlsId);
    }

    $extDbRlsIdStr =~ join(",",@extDbRlsIds);
    if ($test) {
	$self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
	$extDbRlsIdStr = "WHO_KNOWS";
    } 

    $cmd = "makeGenesFromMercator --mercatorOutputDir $workflowDataDir/$mercatorDataDir --t 'protein_coding' --cndSrcBin $cndSrcBin --uga --verbose --extDbRelIds $extDbRlsIdStr > $workflowDataDir/$outputFile.Clusters";
    $self->runCmd($test, $cmd);
    $cmd = "makeGenesFromMercator --mercatorOutputDir $workflowDataDir/$mercatorDataDir --t 'rna_coding'  --cndSrcBin $cndSrcBin --uga --verbose --extDbRelIds $extDbRlsIdStr >> $workflowDataDir/$outputFile.Clusters";
    $self->runCmd($test, $cmd);
    $cmd = "grep ^cluster_ $workflowDataDir/$outputFile.Clusters >$workflowDataDir/$outputFile";
    $self->runCmd($test,$cmd);
}


sub getConfigDeclaration {
    return (
            # [name, default, description]
           );
}

