package ApiCommonWorkflow::Main::WorkflowSteps::MakeCodonUsage;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;


sub getWebsiteFileCmd {
    my ($self, $downloadFileName, $test) = @_;

    my $organismAbbrev = $self->getParamValue('organismAbbrev');
    my $projectName = $self->getParamValue('projectName');
    my $projectVersion = $self->getParamValue('projectVersionForWebsiteFiles');
    my $relativeDir = $self->getParamValue('relativeDir');
    my $inputDataName = $self->getParamValue("inputDataName");

    my $websiteFilesDir = $self->getWebsiteFilesDir($test);
    my $organismNameForFiles = $self->getOrganismInfo($test, $organismAbbrev)->getNameForFiles();
    my $inputDir = "$websiteFilesDir/$relativeDir/$organismNameForFiles/fasta";

    my $inputDownloadFile = "$inputDir/$projectName-${projectVersion}_${organismNameForFiles}_$inputDataName.fasta";


    my $cmd = "makeCodonUsage  --outFile $downloadFileName  --inFile $inputDownloadFile  --verbose";

    return $cmd;

}



