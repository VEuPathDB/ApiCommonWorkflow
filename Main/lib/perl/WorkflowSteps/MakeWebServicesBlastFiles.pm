package ApiCommonWorkflow::Main::WorkflowSteps::MakeWebServicesBlastFiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;

sub run {
  my ($self, $test, $undo) = @_;

  # standard parameters for making download files
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $projectName = $self->getParamValue('projectName');
  my $projectVersion = $self->getParamValue('projectVersionForWebsiteFiles');
  my $useSpeciesName = $self->getBooleanParamValue('useSpeciesName');
  my $useFamilyName = $self->getBooleanParamValue('useFamilyName');

  $self->error("Parameters useFamilyName and useSpeciesName cannot both be 'true'") if $useFamilyName && $useSpeciesName;

  my $downloadSiteRelativeDir = $self->getParamValue('relativeDownloadSiteDir');  my $dataName = $self->getParamValue('dataName');

  # extra params for this step
  my $webServicesRelativeDir = $self->getParamValue('relativeWebServicesDir');
  my $args = $self->getParamValue('args');

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);
  my $organismNameForFiles = $self->getOrganismInfo($test, $organismAbbrev)->getNameForFiles();
  my $speciesNameForFiles = $self->getOrganismInfo($test, $organismAbbrev)->getSpeciesNameForFiles();
  my $familyNameForFiles = $self->getOrganismInfo($test, $organismAbbrev)->getFamilyNameForFiles();

  my $inputDownloadFile = ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker::getDownloadFileName($websiteFilesDir, $downloadSiteRelativeDir, $organismNameForFiles, $speciesNameForFiles, $useSpeciesName, $familyNameForFiles, $useFamilyName, $projectName, $projectVersion, 'fasta', $dataName);

  my $outputWebservicesFileDir = ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker::getWebServiceDir($websiteFilesDir, $webServicesRelativeDir, $organismNameForFiles, $speciesNameForFiles, $useSpeciesName, $familyNameForFiles, $useFamilyName, 'blast');

  my $blastPath = $self->getConfig("ncbiBlastPath");
  my $cmd = "$blastPath/makeblastdb -in $inputDownloadFile $args -out $outputWebservicesFileDir/$dataName ";
  if($undo) {
    $self->runCmd(0, "rm -f $outputWebservicesFileDir/$dataName.*");
  } else{
      if($test){
	  $self->testInputFile('inputDownloadFile', "$inputDownloadFile");
	  $self->testInputFile('outputWebservicesFileDir', "$outputWebservicesFileDir");
	  $self->runCmd(0, "echo test > $outputWebservicesFileDir/$dataName.xnd");
      }else {
	       $self->runCmd($test, $cmd);
      }
  }
}

sub getConfigDeclaration {
    return ();
}

