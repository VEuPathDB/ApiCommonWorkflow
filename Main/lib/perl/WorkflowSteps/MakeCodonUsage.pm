package ApiCommonWorkflow::Main::WorkflowSteps::MakeCodonUsage;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;


sub getWebsiteFileCmd {
    my ($self, $downloadFileName, $test) = @_;

    my $organismAbbrev = $self->getParamValue('organismAbbrev');
    my $projectName = $self->getParamValue('projectName');
    #my $projectVersion = $self->getParamValue('projectVersionForWebsiteFiles');
    my $projectVersion = 'CURRENT';
    my $relativeDir = $self->getParamValue('relativeDir');
    $relativeDir  =~ s/release-\S+/release-CURRENT/g;
    my $inputDataName = $self->getParamValue("inputDataName");

    my $websiteFilesDir = $self->getWebsiteFilesDir($test);
    my $organismNameForFiles = $self->getOrganismInfo($test, $organismAbbrev)->getNameForFiles();
    my $inputDir = "$websiteFilesDir/$relativeDir/$organismNameForFiles/fasta/data";

    my $inputDownloadFile = "$inputDir/$projectName-${projectVersion}_${organismNameForFiles}_$inputDataName.fasta";


    my $cmd = "makeCodonUsage  --outFile $downloadFileName  --inFile $inputDownloadFile  --verbose";

    return $cmd;

}



