package ApiCommonWorkflow::Main::WorkflowSteps::MakeJbrowseConfigFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;

sub run {
  my ($self, $test, $undo) = @_;

  my $organismAbbrev = $self->getParamValue('organismAbbrev');

  my $webServicesRelativeDir = $self->getParamValue('relativeWebServicesDir');

  my $projectName = $self->getParamValue('projectName');

  my $gusConfigFile = "$ENV{GUS_HOME}/config/gus.config";

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);

  my $organismNameForFiles = $self->getOrganismInfo($test, $organismAbbrev)->getNameForFiles();

  my $copyToDir = "$websiteFilesDir/$webServicesRelativeDir/$organismNameForFiles/config/";

  my $jbrowseConf = "${copyToDir}/jbrowse.conf";
  my $cmd = "generateJbrowseMetadata $gusConfigFile $organismAbbrev $jbrowseConf";


  if($undo) {
      $self->runCmd(0, "rm -f ${$jbrowseConf}*");
  } else{
      if($test){
          $self->runCmd(0, "echo test > $jbrowseConf");
      }
      $self->runCmd($test, "mkdir -p $copyToDir");
      $self->runCmd($test, $cmd);
  }
}

1;
