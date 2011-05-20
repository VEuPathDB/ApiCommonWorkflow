package ApiCommonWorkflow::Main::WorkflowSteps::InitOrganismDownloadSiteDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::Util::OrganismInfo;

# initialize the download site dirs for an organism.
# there are two, one in apiSiteFiles/downloadSite and one in apiSiteFiles/downloadSiteRestrictedAccess
# the latter is where the data will go.  the former links to, and shows the users whatever restrictions apply
# 
# to find the restrictions, read the organismDataRestrictions.xml file.
# it must contain an <organism> for this organism, otherwise it is an error
# if there is text provided, create an index.shtml file, and put it in downloadSite
# else, there are no restrictions, so create a symlink from there to downloadSiteRestrictedAccess

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $organelleName = $self->getParamValue('organelleName');
  # this is relative to the website files dir.
  # it will look something like downloadSite/ToxoDB/release-6.3
  my $relativeDir = $self->getParamValue('relativeDir');

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);

  my $organismNameForFiles =
      $self->getOrganismInfo($organismAbbrev)->getNameForFiles();

  if ($organelleName) {
      $organismNameForFiles .= "-$organelleName";
  }

  # not using restricted access.  set up dir the old way
  if ($relativeDir !~ /Restricted/) {
      my $fullPath = "$websiteFilesDir/$relativeDir/$organismNameForFiles";
      if ($undo) {
	  $self->runCmd(0, "rm -rf $fullPath");
      } else {
	  $self->runCmd(0, "mkdir -p $fullPath");
      }
  }

  else { 

      # find organism in restrictions xml file
      my $xmlFile = "$ENV{GUS_HOME}/lib/xml/organismDataRestrictions.xml";
      $self->_parseXmlFile($xmlFile);
      if (!exists($self->{organisms}->{name})) {
	  $self->error("Can't find organism 'name' in xml file '$xmlFile'");
      }
      
      my $fullPathRestricted = "$downloadSiteDataDir/$relativeDir/$organismName";
      my $fullPathPublic = "downloadSite/$relativeDir/$organismName";
      if ($undo) {
	  $self->runCmd(0, "rm -rf $fullPathPublic");
	  $self->runCmd(0, "rm -rf $fullPathRestricted");
      } else {
	  $self->runCmd(0, "mkdir -p $fullPathRestricted");
	  my $restrictionText = $self->{organisms}->{name};
	  if ($restrictionText) {
	      $self->runCmd(0, "mkdir -p $fullPathPublic");
	      writeIndexFile($fullPathPublic, $restrictionText);
	  } else {
	      $self->runCmd(0, "ln -s $fullPathRestricted $fullPathPublic");  
	  }
      }
  }
}

sub _parseXmlFile {
  my ($self, $methodsXmlFile) = @_;

  my $xml = new XML::Simple();
  $self->{methods} = eval{ $xml->XMLin($methodsXmlFile, SuppressEmpty => undef, KeyAttr => 'organism', ForceArray=>['organism']) };
#  print STDERR Dumper $self->{data};
  $self->error("Error parsing '$methodsXmlFile': \n$@\n") if($@);
}


sub getParamsDeclaration {
    return (
	'organismAbbrev',
	'relativeDir',
	'organelleName',
	);
}

sub getConfigDeclaration {
  return (
	 );
}


