package ApiCommonWorkflow::Main::WorkflowSteps::MakeWebServicesBlastFiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;

sub getNameForFilesSuffix {
  return undef;
}

sub run {
  my ($self, $test, $undo) = @_;

  # standard parameters for making download files
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $projectName = $self->getParamValue('projectName');
  my $projectVersion = $self->getParamValue('projectVersionForWebsiteFiles');
  my $useSpeciesName = $self->getBooleanParamValue('useSpeciesName');
  my $useFamilyName = $self->getBooleanParamValue('useFamilyName');
  my $gusConfigFile = $self->getParamValue('gusConfigFile');
  $gusConfigFile = $self->getWorkflowDataDir() . "/$gusConfigFile";

  $self->error("Parameters useFamilyName and useSpeciesName cannot both be 'true'") if $useFamilyName && $useSpeciesName;

  my $downloadSiteRelativeDir = $self->getParamValue('relativeDownloadSiteDir');  
  my $dataName = $self->getParamValue('dataName');

  # extra params for this step
  my $webServicesRelativeDir = $self->getParamValue('relativeWebServicesDir');
  my $args = $self->getParamValue('args');

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);
  my $organismNameForFiles = $self->getOrganismInfo($test, $organismAbbrev, $gusConfigFile)->getNameForFiles();
  my $speciesNameForFiles = $self->getOrganismInfo($test, $organismAbbrev, $gusConfigFile)->getSpeciesNameForFiles();
  my $familyNameForFiles = $self->getOrganismInfo($test, $organismAbbrev, $gusConfigFile)->getFamilyNameForFiles();

  my $nameForFileSuffix = $self->getNameForFilesSuffix();

  my $inputDownloadFile = ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker::getDownloadFileName($websiteFilesDir, $downloadSiteRelativeDir, $organismNameForFiles, $speciesNameForFiles, $useSpeciesName, $familyNameForFiles, $useFamilyName, $projectName, $projectVersion, 'fasta', $dataName, $nameForFileSuffix);
	

  my $outputWebservicesFileDir = ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker::getWebServiceDir($websiteFilesDir, $webServicesRelativeDir, $organismNameForFiles, $speciesNameForFiles, $useSpeciesName, $familyNameForFiles, $useFamilyName, 'blast', undef, undef, $nameForFileSuffix);

  ## prefix organismNameForFile, speciesNameForFile or familyNameForFile to blast file, refs #19220
  my $outputDataName;
  if ($dataName =~ /Isolates/i) {
    $outputDataName = $familyNameForFiles.$dataName;
  } elsif ($dataName =~ /EST/) {
    $outputDataName = $speciesNameForFiles.$dataName;
  } else {
    $outputDataName = $organismNameForFiles.$dataName;
  }
  
  $outputDataName .= $nameForFileSuffix if($nameForFileSuffix);


  my $blastPath = $self->getConfig("ncbiBlastPath");
  my $cmd = "$blastPath/makeblastdb -in $outputWebservicesFileDir/$outputDataName $args -out $outputWebservicesFileDir/$outputDataName ";

  if($undo) {
    $self->runCmd(0, "rm -f $outputWebservicesFileDir/$outputDataName.*");
  } else{
    $self->testInputFile('inputDownloadFile', "$inputDownloadFile");
    $self->testInputFile('outputWebservicesFileDir', "$outputWebservicesFileDir");

    if($test){
      $self->runCmd(0, "echo test > $outputWebservicesFileDir/$outputDataName.xnd");
    }
    $self->runCmd($test, "cp $inputDownloadFile $outputWebservicesFileDir/$outputDataName");
    
    $self->runCmd($test, $cmd);
    $self->runCmd($test, "rm -f $outputWebservicesFileDir/$outputDataName");
  
  }
}


1;
