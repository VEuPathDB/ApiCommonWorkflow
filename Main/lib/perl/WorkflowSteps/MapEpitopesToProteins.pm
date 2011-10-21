package ApiCommonWorkflow::Main::WorkflowSteps::MapEpitopesToProteins;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;


    my $inputTabFile = $self->getParamValue('inputTabFile');
    my $dataDir = $self->getParamValue('dataDir');
    my $proteinsFile = $self->getParamValue('proteinsFile');
    my $blastDbDir = $self->getParamValue('blastDbDir');
    my $outputMappingFile = $self->getParamValue('outputMappingFile');
    my $idRegex = $self->getParamValue('idRegex');

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $ncbiBlastPath = $self->getConfig('ncbiBlastPath');


    my $tabFile = "$workflowDataDir/$inputTabFile";
    my $mappingFile = "$workflowDataDir/$outputMappingFile";
    my $fastaFile = "$workflowDataDir/$dataDir/epitopesGenpept.fasta";

    # use the epitope accessions to find full length peptide seqs from genpept
    my $cmd1 = "retrieveSeqsFromGenPept --inFile $tabFile --outFile $fastaFile";

    # use those to blast against subject proteins
    my $cmd2 = "runAndParseEpitopeBlast --ncbiBlastPath $ncbiBlastPath --queryFile $fastaFile --database $blastDbDir --epitopeFile $tabFile --outputFile $mappingFile";
    $cmd2 .= " --regex '$idRegex'" if $idRegex;

    # also find exact mapping of short epitope sequences and subject proteins
    # add them to the mapping file
    my $cmd3 = "exactMapEpitopes --subjectFile $proteinsFile --epitopeFile $tabFile --outputFile $mappingFile --rejectDuplicates";

    #TODO: Make sure we don't get exact mapping for epitope:sequence pairs that we have mapping on BLAST hits for

    if ($undo) {
      $self->runCmd(0, "rm -fr $mappingFile");
      $self->runCmd(0, "rm -fr $fastaFile");
    } else {
	if ($test) {
	  $self->testInputFile('proteinsFile', "$workflowDataDir/$proteinsFile");
	  $self->testInputFile('inputTabFile', "$tabFile");
	  $self->runCmd(0, "echo hello > $mappingFile");

	}else{
	  $self->error("Output file '$mappingFile' already exists") if -e $mappingFile;
	  $self->error("Output file '$fastaFile' already exists") if -e $fastaFile;
	  $self->runCmd($test, $cmd1);
	  $self->runCmd($test, $cmd2);
	  $self->runCmd($test, $cmd3);
	}
    }
}


sub getConfigDeclaration {
    return (
            # [name, default, description]
              ['ncbiBlastPath', "", ""]
           );
}

