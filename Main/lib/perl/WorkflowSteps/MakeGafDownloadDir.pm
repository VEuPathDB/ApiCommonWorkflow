package ApiCommonWorkflow::Main::WorkflowSteps::MakeGafDownloadDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::Util::OrganismInfo;

sub run {
	my ($self, $test, $undo) = @_;

    my $organismAbbrev = $self->getParamValue('organismAbbrev');

    my $relativeDir = $self->getParamValue('relativeDir');

    my $websiteFilesDir = $self->getWebsiteFilesDir($test);

    my $nameForFiles =
      $self->getOrganismInfo($test, $organismAbbrev)->getNameForFiles();

    my $gafDir = "$websiteFilesDir/$relativeDir/$nameForFiles/gaf";

#    print STDERR "\$websiteFilesDir = $websiteFilesDir\n\$relativeDir = $relativeDir\n\$nameForFiles = $nameForFiles\n";
                 ## actually the relativeDir here is downloadSite/TrichDB/release-CURRENT/

    if($undo) {
      $self->runCmd(0, "rm -d $gafDir");   ## only rm the empty directory
    } else{
      $self->runCmd(0, "mkdir $gafDir") unless -e $gafDir;
    }

}

1;
