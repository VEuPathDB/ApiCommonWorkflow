package ApiCommonWorkflow::Main::WorkflowSteps::MakeWebServicesBlastFiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # standard parameters for making download files
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $projectName = $self->getParamValue('projectName');
  my $projectVersion = $self->getParamValue('projectVersionForWebsiteFiles');
  my $useSpeciesName = $self->getBooleanParamValue('useSpeciesName');
  my $downloadSiteRelativeDir = $self->getParamValue('relativeDownloadSiteDir');  my $dataName = $self->getParamValue('dataName');

  # extra params for this step
  my $webServicesRelativeDir = $self->getParamValue('relativeWebServicesDir');
  my $args = $self->getParamValue('args');

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);

  # get download site file
  my $organismNameForFiles = $self->getOrganismInfo($test, $organismAbbrev)->getNameForFiles();
  if ($useSpeciesName) {
    $organismNameForFiles = $self->getOrganismInfo($test, $organismAbbrev)->getSpeciesNameForFiles();
  }

  my $downloadFileDir = "$websiteFilesDir/$downloadSiteRelativeDir/$organismNameForFiles/fasta";

  my $inputDownloadFile = "$downloadFileDir/$projectName-${projectVersion}_${organismNameForFiles}_$dataName.fasta";

  # get web services dir
  my $outputWebservicesFileDir = "$websiteFilesDir/$webServicesRelativeDir/${organismNameForFiles}/blast";

  my $blastPath = $self->getConfig("wuBlastPath");
  my $cmd = "$blastPath/xdformat $args -o $outputWebservicesFileDir/$dataName $inputDownloadFile";

  if($undo) {
    $self->runCmd(0, "rm -f $outputWebservicesFileDir/$dataName.*");
  } else{
      if($test){
	  $self->testInputFile('inputDownloadFile', "$inputDownloadFile");
	  $self->testInputFile('outputWebservicesFileDir', "$outputWebservicesFileDir");
	  $self->runCmd(0, "echo test > $outputWebservicesFileDir/$dataName.xnd");
      }else {
	   if($args =~/\-p/){
	       my $tempFile = "$outputWebservicesFileDir/$dataName.tmp";
	       $self->runCmd($test,"cat $inputDownloadFile | perl -pe 'unless (/^>/){s/J/X/g;}' > $tempFile");
	       $self->runCmd($test,"$blastPath/xdformat $args -o $outputWebservicesFileDir/$dataName $tempFile");
	       $self->runCmd($test,"rm -fr $tempFile");
	   }else {
	       $self->runCmd($test, $cmd);
	   }
       }
  }
}

sub getParamsDeclaration {
     return (
	'organismAbbrev',
	'projectName',
	'projectVersion',
	'downloadSiteRelativeDir',
	'useServicesRelativeDir',
	'dataName',
	);
}

sub getConfigDeclaration {
    return ();
}

