package ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

# An abstract superclass for making website files

##############################################################################################
#abstract methods available to subclasses.  the subclass must override each of these methods by
#providing a version of them which returns the correct thing for that subclass


# optional. return a list of config names to add to the config declaration.  these are in addition
# to the standard ones provided by this superclass
# only needed if the subclass has extra config
sub getExtraConfig {
    my ($self) = @_;
    return ();
}

# required. return a command that will create the website file, given the full website file name
# return "NONE" if there is no command to run.  this is the case for writing only a descrip file.
sub getWebsiteFileCmd {
    my ($self, $websiteFileName, $test) = @_;
}

# optional. return 1 to indicate that we should use speciesNameForFiles
# 0 by default
sub getIsSpeciesLevel {
    return 0;
}

# optional. return 1 to indicate that we should use familyNameForFiles
# 0 by default
sub getIsFamilyLevel {
    return 0;
}

# optional.  return a file name to touch if the produced download file is empty
sub getSkipIfFile {
    return undef;
}

##############################################################

sub run {
  my ($self, $test, $undo) = @_;

  # standard parameters for making website files
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $projectName = $self->getParamValue('projectName');
  my $projectVersion = $self->getParamValue('projectVersionForWebsiteFiles');
  my $relativeDir = $self->getParamValue('relativeDir');
  my $fileType = $self->getParamValue('fileType');
  my $dataName = $self->getParamValue('dataName');
  my $descripString = $self->getParamValue('descripString');
  my $isWebServiceFile = $self->getBooleanParamValue('isWebServiceFile');

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);
  
  my ($websiteFile, $descripFile, $descripFileCmd);

  my $organismNameForFiles = $self->getOrganismInfo($test, $organismAbbrev)->getNameForFiles();
  my $speciesNameForFiles = $self->getOrganismInfo($test, $organismAbbrev)->getSpeciesNameForFiles();
  my $isSpeciesLevel = $self->getIsSpeciesLevel();
  my $familyNameForFiles = $self->getOrganismInfo($test, $organismAbbrev)->getFamilyNameForFiles();
  my $isFamilyLevel = $self->getIsFamilyLevel();
  
  if ($isWebServiceFile) {
      $websiteFile = getWebServiceFileName($websiteFilesDir, $relativeDir, $organismNameForFiles, $speciesNameForFiles, $isSpeciesLevel, $familyNameForFiles, $isFamilyLevel, $fileType, $dataName);
  } else {
      $websiteFile = getDownloadFileName($websiteFilesDir, $relativeDir, $organismNameForFiles, $speciesNameForFiles, $isSpeciesLevel, $familyNameForFiles, $isFamilyLevel, $projectName, $projectVersion, $fileType, $dataName);

      $descripFile = getDescripFileName($websiteFilesDir, $relativeDir, $organismNameForFiles, $speciesNameForFiles, $isSpeciesLevel, $familyNameForFiles, $isFamilyLevel, $projectName, $projectVersion, $fileType, $dataName);
      $descripFileCmd =  "writeDownloadFileDecripWithDescripString --descripString '$descripString' --outputFile $descripFile";
  }

  my $websiteFileCmd =  $self->getWebsiteFileCmd($websiteFile, $test);

  if($undo){
    $self->runCmd(0, "rm -f $websiteFile") unless $websiteFileCmd eq 'NONE';
    $self->runCmd(0, "rm -f $descripFile") unless $isWebServiceFile;
  }else {
      $self->error("Output file '$websiteFile' already exists") if -e $websiteFile;
      $self->error("Output file '$descripFile' already exists") if !$isWebServiceFile && -e $descripFile;
      if ($test) {
	  $self->runCmd(0, "echo test > $websiteFile") unless $websiteFileCmd eq 'NONE';
	  $self->runCmd(0, "echo test > $descripFile")  unless $isWebServiceFile;
      }else {
	  $self->runCmd($test, $websiteFileCmd) unless $websiteFileCmd eq 'NONE';
	  $self->runCmd($test, $descripFileCmd)  unless $isWebServiceFile;
	  my $skipIfFile = $self->getSkipIfFile();
	  if ($skipIfFile && (-s $websiteFile == 0)) {
	    my $wfDataDir = $self->getWorkflowDataDir();
	    $self->runCmd(0, "touch $wfDataDir/$skipIfFile");
	  }
      }
  }
}

# static method
sub getWebServiceDir {
    my ($websiteFilesDir, $relativeDir, $organismNameForFiles, $speciesNameForFiles, $isSpeciesLevel, $familyNameForFiles, $isFamilyLevel, $serviceName) = @_;

    my $nameForFiles = $organismNameForFiles;
    $nameForFiles = $speciesNameForFiles if $isSpeciesLevel;
    $nameForFiles = $familyNameForFiles if $isFamilyLevel;
    return "$websiteFilesDir/$relativeDir/$nameForFiles/$serviceName";
}

# static method
sub getWebServiceFileName {
    my ($websiteFilesDir, $relativeDir, $organismNameForFiles, $speciesNameForFiles, $isSpeciesLevel, $familyNameForFiles, $isFamilyLevel, $fileType, $dataName, $serviceName) = @_;

    my $dir = getWebServiceDir($websiteFilesDir, $relativeDir, $organismNameForFiles, $speciesNameForFiles, $isSpeciesLevel, $familyNameForFiles, $isFamilyLevel, $serviceName);
    return "$dir/$dataName.$fileType";
}

# static method
sub getDownloadFileName {
    my ($websiteFilesDir, $relativeDir, $organismNameForFiles, $speciesNameForFiles, $isSpeciesLevel, $familyNameForFiles, $isFamilyLevel, $projectName, $projectVersion, $fileType, $dataName) = @_;

    my $nameForFiles = $organismNameForFiles;
    $nameForFiles = $speciesNameForFiles if $isSpeciesLevel;
    $nameForFiles = $familyNameForFiles if $isFamilyLevel;
    my $outputDir = "$websiteFilesDir/$relativeDir/$nameForFiles/$fileType";

    # if this dir has a data/ dir to enable a data usage policy page, use it.
    $outputDir = "$outputDir/data" if -d "$outputDir/data";   

    $dataName = "_$dataName" if $dataName; # gff does not use $dataName, so allow it to be empty
    return "$outputDir/$projectName-${projectVersion}_${nameForFiles}$dataName.$fileType";
}

# static method
sub getDescripFileName {
    my ($websiteFilesDir, $relativeDir, $organismNameForFiles, $speciesNameForFiles, $isSpeciesLevel, $familyNameForFiles, $isFamilyLevel, $projectName, $projectVersion, $fileType, $dataName) = @_;

    my $nameForFiles = $organismNameForFiles;
    $nameForFiles = $speciesNameForFiles if $isSpeciesLevel;
    $nameForFiles = $familyNameForFiles if $isFamilyLevel;
    my $outputDir = "$websiteFilesDir/$relativeDir/$nameForFiles/$fileType";

    # if this dir has a data/ dir to enable a data usage policy page 
    $outputDir = "$outputDir/data" if -d "$outputDir/data";   

    $dataName = "_$dataName" if $dataName; # gff does not use $dataName, so allow it to be empty
    return "$outputDir/.$projectName-${projectVersion}_${nameForFiles}$dataName.$fileType.desc";
}

sub getConfigDeclaration {
    my ($self) = @_;

    my @baseConfig = (
	);
    my @extraConfig = $self->getExtraConfig();
    return (@baseConfig, @extraConfig);

}

