package ApiCommonWorkflow::Main::WorkflowSteps::InitDownloadSiteDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

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

  my $projectName = $self->getParamValue('projectName');
  my $projectVersion = $self->getParamValue('projectVersion');
  my $organismName = $self->getParamValue('organismName');

  my $downloadSiteDataDir = $self->getSharedConfig('downloadSiteDir');  # where we actually write the data

  # not using restricted access.  set up dir the old way
  if ($downloadSiteDataDir !~ /Restricted/) {
      my $fullPath = "$downloadSiteDataDir/$projectName/release-$projectVersion/$organismName";
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
      
      my $fullPathRestricted = "$downloadSiteDataDir/$projectName/release-$projectVersion/$organismName";
      my $fullPathPublic = "downloadSite/$projectName/release-$projectVersion/$organismName";
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
	'organism',
	'outputFile',
	);
}

sub getConfigDeclaration {
  return (
	 );
}


