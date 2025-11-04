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

  my $jbrowseDir = $self->getParamValue('jbrowseDir');

  my $gusConfigFile = $self->getParamValue('gusConfigFile');
  $gusConfigFile = $self->getWorkflowDataDir() . "/$gusConfigFile";

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $fullJbrowseDir = "$workflowDataDir/$jbrowseDir";

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);

  my $organismNameForFiles = $self->getOrganismInfo($test, $organismAbbrev, $gusConfigFile)->getNameForFiles();

  my $copyToDir = "$websiteFilesDir/$webServicesRelativeDir/$organismNameForFiles/genomeAndProteome/config/";

  my $jbrowseConf = "${copyToDir}/jbrowse.conf";
  my $cmd = "generateJbrowseMetadata $gusConfigFile $organismAbbrev $jbrowseConf $fullJbrowseDir";


  if($undo) {
      $self->runCmd(0, "rm -fr $copyToDir");
  } else{
      if($test){
          $self->runCmd(0, "mkdir -p $copyToDir");
          $self->runCmd(0, "echo test > $jbrowseConf");
      }
      $self->runCmd($test, "mkdir -p $copyToDir");
      $self->runCmd($test, $cmd);
  }
}

1;
