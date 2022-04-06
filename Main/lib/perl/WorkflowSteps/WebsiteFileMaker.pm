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


sub getNameForFilesSuffix {
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
  my $serviceName;

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);
  
  my ($websiteFile, $descripFile, $descripFileCmd);

  my $organismNameForFiles = $self->getOrganismInfo($test, $organismAbbrev)->getNameForFiles();
  my $speciesNameForFiles = $self->getOrganismInfo($test, $organismAbbrev)->getSpeciesNameForFiles();
  my $isSpeciesLevel = $self->getIsSpeciesLevel();
  my $familyNameForFiles = $self->getOrganismInfo($test, $organismAbbrev)->getFamilyNameForFiles();
  my $isFamilyLevel = $self->getIsFamilyLevel();

  my $nameForFilesSuffix = $self->getNameForFilesSuffix();
  
  if ($isWebServiceFile) {
      $serviceName  = $self->getParamValue('serviceName');
      $websiteFile = getWebServiceFileName($websiteFilesDir, $relativeDir, $organismNameForFiles, $speciesNameForFiles, $isSpeciesLevel, $familyNameForFiles, $isFamilyLevel, $fileType, $dataName,$serviceName, $nameForFilesSuffix);
  } else {
      $websiteFile = getDownloadFileName($websiteFilesDir, $relativeDir, $organismNameForFiles, $speciesNameForFiles, $isSpeciesLevel, $familyNameForFiles, $isFamilyLevel, $projectName, $projectVersion, $fileType, $dataName, $nameForFilesSuffix);

      $descripFile = getDescripFileName($websiteFilesDir, $relativeDir, $organismNameForFiles, $speciesNameForFiles, $isSpeciesLevel, $familyNameForFiles, $isFamilyLevel, $projectName, $projectVersion, $fileType, $dataName, $nameForFilesSuffix);
      #The descriptions are set with static apache configuration based on name matches of the files. .desc aren't used for display in downloads. Stop generating them to reduce confusions.
      #$descripFileCmd =  "writeDownloadFileDecripWithDescripString --descripString '$descripString' --outputFile $descripFile";
  }

  my $wfDataDir = $self->getWorkflowDataDir();

  my $websiteFileCmd =  $self->getWebsiteFileCmd($websiteFile, $test);

  my $skipIfFile = $self->getSkipIfFile();

  if($undo){
    $self->runCmd(0, "rm -f $websiteFile") unless $websiteFileCmd eq 'NONE';
    $self->runCmd(0, "rm -f $descripFile") if !$isWebServiceFile && -e $descripFile;;
    unlink("$wfDataDir/$skipIfFile") if -e "$wfDataDir/$skipIfFile";
  }else {
      $self->error("Output file '$websiteFile' already exists") if -e $websiteFile;
      #$self->error("Output file '$descripFile' already exists") if !$isWebServiceFile && -e $descripFile;
      if ($test) {
	  $self->runCmd(0, "echo test > $websiteFile ") unless $websiteFileCmd eq 'NONE';
	  #$self->runCmd(0, "echo test > $descripFile")  unless $isWebServiceFile;
      }

      $self->runCmd($test, $websiteFileCmd) unless $websiteFileCmd eq 'NONE';
      $self->runCmd($test, $descripFileCmd)  unless $isWebServiceFile;
      if ($skipIfFile && (-s $websiteFile == 0)) {
        $self->runCmd(0, "touch $wfDataDir/$skipIfFile");
      }
  }
}

# static method
sub getWebServiceDir {
    my ($websiteFilesDir, $relativeDir, $organismNameForFiles, $speciesNameForFiles, $isSpeciesLevel, $familyNameForFiles, $isFamilyLevel, $serviceName, $nameForFilesSuffix) = @_;

    my $nameForFiles = $organismNameForFiles;
    $nameForFiles = $speciesNameForFiles if $isSpeciesLevel;
    $nameForFiles = $familyNameForFiles if $isFamilyLevel;
    $nameForFiles .= $nameForFilesSuffix if($nameForFilesSuffix);

    return "$websiteFilesDir/$relativeDir/$nameForFiles/$serviceName";
}

# static method
sub getWebServiceFileName {
    my ($websiteFilesDir, $relativeDir, $organismNameForFiles, $speciesNameForFiles, $isSpeciesLevel, $familyNameForFiles, $isFamilyLevel, $fileType, $dataName, $serviceName, $nameForFilesSuffix) = @_;

    my $dir = getWebServiceDir($websiteFilesDir, $relativeDir, $organismNameForFiles, $speciesNameForFiles, $isSpeciesLevel, $familyNameForFiles, $isFamilyLevel, $serviceName, $nameForFilesSuffix);
    return "$dir/$dataName.$fileType";
}

# static method
sub getDownloadFileName {
    my ($websiteFilesDir, $relativeDir, $organismNameForFiles, $speciesNameForFiles, $isSpeciesLevel, $familyNameForFiles, $isFamilyLevel, $projectName, $projectVersion, $fileType, $dataName, $nameForFilesSuffix) = @_;

    my $nameForFiles = $organismNameForFiles;
    $nameForFiles = $speciesNameForFiles if $isSpeciesLevel;
    $nameForFiles = $familyNameForFiles if $isFamilyLevel;
    $nameForFiles .= $nameForFilesSuffix if($nameForFilesSuffix);

    my $outputDir = "$websiteFilesDir/$relativeDir/$nameForFiles/$fileType";

    # if this dir has a data/ dir to enable a data usage policy page, use it.
    $outputDir = "$outputDir/data" if -d "$outputDir/data";   

    $dataName = "_$dataName" if $dataName; # gff does not use $dataName, so allow it to be empty
    return "$outputDir/$projectName-${projectVersion}_${nameForFiles}$dataName.$fileType";
}

# static method
sub getDescripFileName {
    my ($websiteFilesDir, $relativeDir, $organismNameForFiles, $speciesNameForFiles, $isSpeciesLevel, $familyNameForFiles, $isFamilyLevel, $projectName, $projectVersion, $fileType, $dataName, $nameForFilesSuffix) = @_;

    my $nameForFiles = $organismNameForFiles;
    $nameForFiles = $speciesNameForFiles if $isSpeciesLevel;
    $nameForFiles = $familyNameForFiles if $isFamilyLevel;
    $nameForFiles .= $nameForFilesSuffix if($nameForFilesSuffix);

    my $outputDir = "$websiteFilesDir/$relativeDir/$nameForFiles/$fileType";

    # if this dir has a data/ dir to enable a data usage policy page 
    $outputDir = "$outputDir/data" if -d "$outputDir/data";   

    $dataName = "_$dataName" if $dataName; # gff does not use $dataName, so allow it to be empty
    return "$outputDir/.$projectName-${projectVersion}_${nameForFiles}$dataName.$fileType.desc";
}


1;

