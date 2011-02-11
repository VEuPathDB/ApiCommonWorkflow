package ApiCommonWorkflow::Main::WorkflowSteps::MakeGenesFileFromMercator;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;
    my $mercatorDataDir = $self->getParamValue('mercatorDataDir');
    my $cndSrcBin = $self->getParamValue('cndSrcBin');
    my $outputFile = $self->getParamValue('outputFile');
    my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');

    my $workflowDataDir = $self->getWorkflowDataDir();

    my @extDbRlsSpecList = split(/,/, $extDbRlsSpec);

    my $dbRlsIds;

    foreach my $db (@extDbRlsSpecList){
        
      $dbRlsIds .= $self->getExtDbRlsId($test, $db).",";

   }

  $dbRlsIds =~ s/(,)$//g;
    my $cmd = '';
    if ($undo) {
	$self->runCmd(0, "rm -fr $workflowDataDir/$outputFile");

    }else{
	if ($test) {
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
	}else{
	    $cmd = "makeGenesFromMercator --mercatorOutputDir $mercatorDataDir --t 'protein_coding' --cndSrcBin $cndSrcBin --uga --verbose --$dbRlsIds > $workflowDataDir/$outputFile.Clusters";
	    $self->runCmd($test, $cmd);
	    $cmd = "makeGenesFromMercator --mercatorOutputDir $mercatorDataDir --t 'rna_coding'  --cndSrcBin $cndSrcBin --uga --verbose --$dbRlsIds >> $workflowDataDir/$outputFile.Clusters";
	    $self->runCmd($test, $cmd);
	    $cmd = "grep ^cluster_ $workflowDataDir/$outputFile.Clusters >$workflowDataDir/$outputFile";
	    $self->runCmd($test,$cmd);
	}
    }
}

sub getParamsDeclaration {
    return ('mercatorDataDir',
            'outputDir',
            'outputFile',
            'extDbRlsSpec',
           );
}


sub getConfigDeclaration {
    return (
            # [name, default, description]
           );
}

