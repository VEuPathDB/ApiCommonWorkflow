package ApiCommonWorkflow::Main::WorkflowSteps::CreatePairwiseMercatorDirs;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;


    my $mercatorDir = $self->getParamValue('mercatorDir');
    my $mercatorFastaDir = $self->getParamValue('mercatorFastaDir');
    my $mercatorGffDir = $self->getParamValue('mercatorGffDir');
    my $mercatorDraftGenomes = $self->getParamValue('mercatorDraftGenomes');
    my $mercatorNonDraftGenomes = $self->getParamValue('mercatorNonDraftGenomes');
    my $mercatorDraftExternalDbSpec = $self->getParamValue('mercatorDraftExternalDbSpec');
    my $mercatorNonDraftExternalDbSpec = $self->getParamValue('mercatorNonDraftExternalDbSpec');
    my $mercatorDraftSeqTables = $self->getParamValue('mercatorDraftSeqTables');
    my $mercatorNonDraftSeqTables = $self->getParamValue('mercatorNonDraftSeqTables');
    my $mercatorSyntenyVersion = $self->getParamValue('mercatorSyntenyVersion');


    my $localDataDir = $self->getLocalDataDir();

    my ($seqTableA, $seqTableB, $specA, $specB, $syntenySpec, $agpFile);
    my @drafts = ();
    my @nonDrafts = ();
    my @draftExternalDbs = ();
    my @nonDraftExternalDbs = ();
    my @draftSeqTables = ();
    my @nonDraftSeqTables = ();

    my @allGenomes = ();
    my @allExternalDbs = ();
    my @allSeqTables = ();

    my $draftIdx = -1;
    my  $nonDraftIdx = -1;

    if($mercatorDraftGenomes){
	@drafts =  map { "$_" } split(',', $mercatorDraftGenomes);      
	@draftExternalDbs =  map { "$_" } split(',', $mercatorDraftExternalDbSpec);
	@draftSeqTables =  map { "$_" } split(',', $mercatorDraftSeqTables);


	$draftIdx = $#drafts;
    }
  
    if($mercatorNonDraftGenomes){
	@nonDrafts = map { "$_" } split(',', $mercatorNonDraftGenomes);
	@nonDraftExternalDbs =  map { "$_" } split(',', $mercatorNonDraftExternalDbSpec);
	@nonDraftSeqTables =  map { "$_" } split(',', $mercatorNonDraftSeqTables); 

	$nonDraftIdx = $#nonDrafts;
    }

    push(@allGenomes,@drafts,@nonDrafts);

    for(my $i =0; $i <= ($#allGenomes-1); $i++){
	for(my $j =$i+1 ; $j <= $#allGenomes; $j++){
	    my $dirName = "$mercatorDir/$allGenomes[$i]-$allGenomes[$j]";
	    $specA = $allExternalDbs[$j];
	    $specB = $allExternalDbs[$i];
	    $specA =~ s/\|\|/,/g;
	    $specB =~ s/\|\|/,/g;
	    $seqTableA = $allSeqTables[$j];
	    $seqTableB = $allSeqTables[$i];
	    $syntenySpec = "$allGenomes[$i]-$allGenomes[$j] synteny from Mercator|$mercatorSyntenyVersion";
	    if($j <= $draftIdx){
		$agpFile = "$dirName/mercator-output/$allGenomes[$j].agp";
	    }else{
		$agpFile = "";
	    }
	    if ($undo) {
		$self->runCmd(0, "rm -fr $dirName");
	    }else{
		if ($test) {
		$self->runCmd(0,"mkdir -p $dirName/fasta");
		$self->runCmd(0,"mkdir -p $dirName/gff");
		$self-runCmd(0,"cp -R $mercatorFastaDir/$allGenomes[$i].fasta $dirName/fasta");
		$self->runCmd(0,"cp -R $mercatorFastaDir/$allGenomes[$j].fasta $dirName/fasta");
		$self->runCmd(0,"cp -R $mercatorGffDir/$allGenomes[$i].gff $dirName/gff");
		$self->runCmd(0,"cp -R $mercatorGffDir/$allGenomes[$j].gff $dirName/gff");		    
		$self->runCmd(0,"echo hello > $dirName/config.txt");
		}else{		
		    $self->runCmd($test,"$dirName/fasta");
		    $self->runCmd($test,"$dirName/gff");
		    $self-runCmd($test,"cp -R $mercatorFastaDir/$allGenomes[$i].fasta $dirName/fasta");
		    $self->runCmd($test,"cp -R $mercatorFastaDir/$allGenomes[$j].fasta $dirName/fasta");
		    $self->runCmd($test,"cp -R $mercatorGffDir/$allGenomes[$i].gff $dirName/gff");
		    $self->runCmd($test,"cp -R $mercatorGffDir/$allGenomes[$j].gff $dirName/gff");
		    $self->createConfigFile("$dirName/$allGenomes[$i]-$allGenomes[$j]","$dirName/$allGenomes[$i]-$allGenomes[$j].align-synteny",$seqTableA,$seqTableB,$specA,$specB,$syntenySpec,$agpFile);
		}
	    }
	}
    }



 
}

sub getParamsDeclaration {
    return ('mercatorDir',
            'mercatorFastaDir',
            'mercatorGffDir',
            'mercatorDraftGenomes',
            'mercatorNonDraftGenomes',
            'mercatorDraftExternalDbSpec',
            'mercatorNonDraftExternalDbSpec',
            'mercatorDraftSeqTables',
            'mercatorNonDraftSeqTables',
	    'mercatorSyntenyVersion',
           );
}


sub getConfigDeclaration {
    return (
            # [name, default, description]

           );
}

sub createConfigFile {
    my($inputDir,$inFile, $seqTableA, $seqTableB, $specA, $specB, $syntenySpec, $agpFile) = @_;

    open(CONFIG_FILE,">$inputDir/config.txt");

    print CONFIG_FILE "inputFile=$inFile\n";
    print CONFIG_FILE "seqTableA=$seqTableA\n";
    print CONFIG_FILE "seqTableB=$seqTableB\n";
    print CONFIG_FILE "extDbSpecA=$specA\n";
    print CONFIG_FILE "extDbSpecB=$specB\n";
    print CONFIG_FILE "syntenySpec=$syntenySpec\n";
    print CONFIG_FILE "agpFile=$agpFile\n";

    close(CONFIG_FILE);
    return;

}
