package ApiCommonWorkflow::Main::WorkflowSteps::MakeMercatorGffFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;


    my $outputDir = $self->getParamValue('outputDir');
    my $organism = $self->getParamValue('organism');
    my $fileNamePrefix;

    if($self->getParamValue('fileNamePrefix')){

	$fileNamePrefix = $self->getParamValue('fileNamePrefix');
    }else{

	$fileNamePrefix = $organism;

	$fileNamePrefix =~ s/\s+/_/g;
    }
 

    my $localDataDir = $self->getLocalDataDir();
 
  
    my $cmd = "mercatorGffDump.pl  --outputDir $localDataDir/$outputDir --organism '$organism' --file_name_prefix '$fileNamePrefix' ";



    if ($undo) {
      $self->runCmd(0, "rm -fr $localDataDir/$outputDir/$fileNamePrefix.gff");
    } else {
	if ($test) {
	    $self->runCmd(0,"mkdir -p $localDataDir/$outputDir");
	    $self->runCmd(0,"echo hello > $localDataDir/$outputDir/$fileNamePrefix.gff");
	}else{
	    $self->runCmd($test, $cmd);
	}
    }
}

sub getParamsDeclaration {
    return (
            'outputDir',
            'organism',
            'fileNamePrefix'
           );
}


sub getConfigDeclaration {
    return (
            # [name, default, description]
              ['ncbiBlastPath', "", ""]
           );
}

