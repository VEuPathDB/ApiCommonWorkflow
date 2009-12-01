package ApiCommonWorkflow::Main::DataSources;

use strict;

use XML::Simple;
use Data::Dumper;

# this is a separate .pm file because it is of general utility

sub new {
  my ($class, $resourcesXmlFile, $properties) = @_;

  my $self = {};

  bless($self,$class);

  $self->_parseXmlFile($resourcesXmlFile, $properties);

  return $self;
}

sub getDataSource {
    my ($dataSourceName) = @_;

    
}

sub _parseXmlFile {
  my ($resourcesXmlFile, $properties) = @_;

  my $xmlString = $self->_substituteMacros($resourcesXmlFile, $properties);
  my $xml = new XML::Simple(SuppressEmpty => undef);
  $self->{data} = eval{ $xml->XMLin($xmlString) };
  die "$@\n$xmlString\n" if($@);
}

sub _substituteMacros {
  my ($xmlFile, $props) = @_;

  my $xmlString;
  open(FILE, $xmlFile) || die "Cannot open resources XML file '$xmlFile'\n";
  while (<FILE>) {
    my $line = $_;
    my @macroKeys = /\@([\w.]+)\@/g;   # allow keys of the form nrdb.release
    foreach my $macroKey (@macroKeys) {
      my $val = $props->getProp($macroKey);
      die "Invalid macro '\@$macroKey\@' in xml file $xmlFile" unless defined $val;
      $line =~ s/\@$macroKey\@/$val/g;
    }
    $xmlString .= $line;
  }
  return $xmlString;
}

