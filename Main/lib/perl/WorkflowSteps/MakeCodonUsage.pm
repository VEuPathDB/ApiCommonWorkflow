package ApiCommonWorkflow::Main::WorkflowSteps::MakeCodonUsage;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::DownloadFileMaker);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::DownloadFileMaker;


sub getDownloadFileCmd {
    my ($self, $downloadFileName, $test) = @_;
    
    my $inputDataName = $self->getParamValue("inputDataName");

    my $websiteFilesDir = $self->getWebsiteFilesDir($test);
    my $organismNameForFiles = $self->getOrganismInfo($organismAbbrev)->getNameForFiles();
    my $inputDir = "$websiteFilesDir/$relativeDir/$organismNameForFiles/fasta";

    my $inputDownloadFile = "$inputDir/$projectName-${projectVersion}_${organismNameForFiles}_$inputDataName.fasta";

    my $cmd = "makeCodonUsage  --outFile $downloadFileName  --inFile $inputDownloadFile  --verbose";

    return $cmd;

}

sub getExtraParams {
    return ('inputDataName',
           );

}


