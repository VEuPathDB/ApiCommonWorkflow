package ApiCommonWorkflow::Main::WorkflowSteps::MakeHighSpeedSearchFiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $variantsFile = $self->getParamValue('variantsFile');
  my $varscanConsDir = $self->getParamValue('varscanConsDir');
  my $readFreq = $self->getParamValue("readFrequency");

  my $webServicesRelativeDir = $self->getParamValue('relativeWebServicesDir');
  my $websiteFilesDir = $self->getWebsiteFilesDir($test);

  my $organismAbbrev = $self->getParamValue('organismAbbrev');

  my $organismNameForFiles = $self->getOrganismInfo($test, $organismAbbrev)->getNameForFiles();
  my $organismStrain = $self->getOrganismInfo($test, $organismAbbrev)->getStrainAbbrev();
  my $workflowDataDir = $self->getWorkflowDataDir();

  my $hssDir = "$websiteFilesDir/$webServicesRelativeDir/$organismNameForFiles/highSpeedSnpSearch";

  my $cmd = "hsssCreateStrainFiles $workflowDataDir/$variantsFile $workflowDataDir/$varscanConsDir  $hssDir $readFreq $organismStrain";
  
  if ($undo) {
    $self->runCmd(0, "rm -fr $hssDir/readFreq$readFreq");
  } else {
    if ($test) {
	  $self->runCmd(0, "mkdir -p $hssDir/readFreq$readFreq");
    }else{
      $self->runCmd(0, "mkdir -p $hssDir");
      $self->runCmd($test,$cmd);
    }
  }
}

sub getParamDeclaration {
  return ('organismAbbrev',
          'variantsFile',
          'varscanConsDir',
          'readFrequency',
          'relativeWebServicesDir',
      );
}

sub getConfigDeclaration {
  return (
      # [name, default, description]
     );
}

1;
