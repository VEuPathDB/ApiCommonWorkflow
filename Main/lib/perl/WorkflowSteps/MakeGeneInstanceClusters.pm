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

    if ($undo) {
	$self->runCmd(0, "rm -fr $workflowDataDir/$outputFile");
	return;
    }

    # see if there are multiple strains.  if not, exit
    my $inputsDir = "$workflowDataDir/$mercatorInputsDir";
    opendir(INPUT, $inputsDir) or $self->error("Could not open mercator inputs dir '$inputsDir' for reading.");
    my $c;
    foreach my $file (readdir INPUT) {
	$c++ if $file =~ /\.fasta$/; # count how many organisms we have
    }
    if ($c == 1) {
	$self->log("Only found 1 organism in input dir $inputsDir.  No comparision needed.  Exiting.");
	return;
    }    
 

    # get ext db rls ids for each strain's primary genome. discover strain abbrevs from input dir
    my @extDbRlsIds;
    opendir(DIR, "$workflowDataDir/$mercatorOutputDir") or $self->error("Could not open mercator output dir '$workflowDataDir/$mercatorOutputDir'.\n");
    foreach my $file (readdir DIR){
	next unless ($file =~ /^(.+)\.agp/);    # we get one .agp per strain.
	my $organismAbbrev = $1;
	my $extDbName = "${organismAbbrev}_primary_genome_RSRC";  # generate resource name
	my $extDbVersion = $self->getExtDbVersion($test, $extDbName);
	my $extDbRlsId = $self->getExtDbRlsId($test,"$extDbName|$extDbVersion");
	push(@extDbRlsIds, $extDbRlsId);
    }

    my $extDbRlsIdsStr = join(",",@extDbRlsIds);
    if ($test) {
	$self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
	$extDbRlsIdsStr = "WHO_KNOWS";
    }

    my $cmd = "makeGenesFromMercator --mercatorOutputDir $workflowDataDir/$mercatorOutputDir --t 'protein_coding' --cndSrcBin $cndSrcBin --uga --verbose --extDbRelIds $extDbRlsIdsStr > $workflowDataDir/$outputFile.Clusters";
    $self->runCmd($test, $cmd);
    $cmd = "makeGenesFromMercator --mercatorOutputDir $workflowDataDir/$mercatorOutputDir --t 'rna_coding'  --cndSrcBin $cndSrcBin --uga --verbose --extDbRelIds $extDbRlsIdsStr >> $workflowDataDir/$outputFile.Clusters";
    $self->runCmd($test, $cmd);
    $cmd = "grep ^cluster_ $workflowDataDir/$outputFile.Clusters >$workflowDataDir/$outputFile";
    $self->runCmd($test,$cmd);
}


sub getConfigDeclaration {
    return (
            # [name, default, description]
           );
}

