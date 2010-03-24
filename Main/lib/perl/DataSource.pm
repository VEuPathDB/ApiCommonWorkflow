package ApiCommonWorkflow::Main::DataSource;

use strict;
use Data::Dumper;

sub new {
  my ($class, $dataSourceName, $parsedXml, $dataSources) = @_;

  my $self = {};
  $self->{parsedXml} = $parsedXml;
  $self->{dataSourceName} = $dataSourceName;
  $self->{dataSources} = $dataSources;

  bless($self,$class);

  return $self;
}

sub getName {
    my ($self) = @_;

    return $self->{dataSourceName};
}

sub getVersion {
    my ($self) = @_;

    return $self->{parsedXml}->{version};
}

sub getDisplayName {
    my ($self) = @_;

    return $self->{parsedXml}->{displayName};
}

sub getOrganisms {
    my ($self) = @_;

    return $self->{parsedXml}->{organisms};
}

sub getParentResource {
    my ($self) = @_;

    return $self->{parsedXml}->{parentResource};
}

sub getProject {
    my ($self) = @_;

    return $self->{parsedXml}->{project};
}

sub getCategory {
    my ($self) = @_;

    return $self->{parsedXml}->{category};
}

sub getPlugin {
    my ($self) = @_;

    return $self->{parsedXml}->{plugin};
}

sub getWgetArgs {
    my ($self) = @_;

    return $self->{parsedXml}->{wgetArgs};
}

sub getWgetArgsUrl {
    my ($self) = @_;

    return $self->{parsedXml}->{wgetArgs}->{url};
}

sub getManualGet {
    my ($self) = @_;

    return $self->{parsedXml}->{manualGet};
}

sub getManualFileOrDir {
    my ($self) = @_;

    my $fileOrDir = $self->{parsedXml}->{manualGet}->{fileOrDir};
    $fileOrDir =~ s/\%RESOURCE_NAME\%/$self->{dataSourceName}/g;
    $fileOrDir =~ s/\%RESOURCE_VERSION\%/$self->{version}/g;
    return $fileOrDir;
}

sub getManualContact {
    my ($self) = @_;

    return $self->{parsedXml}->{manualGet}->{contact};
}

sub getManualEmail {
    my ($self) = @_;

    return $self->{parsedXml}->{manualGet}->{email};
}

sub getManualInstitution {
    my ($self) = @_;

    return $self->{parsedXml}->{manualGet}->{institution};
}

sub getUnpacks {
    my ($self) = @_;

    return $self->{parsedXml}->{unpack};
}

sub getPluginArgs {
    my ($self) = @_;

    my $parent = "";
    my $name = $self->{dataSourceName};
    my $version = $self->{version};

    my $pluginArgs = $self->{parsedXml}->{pluginArgs};
    if ($self->{parentResource}) {
      if ($pluginArgs =~ /\%(RESOURCE_\w+)\%/) {
	my $macro = $1;
	my $xmlFile = $self->{dataSources}->getXmlFile();
	die "Resource $self->{dataSourceName} in file $xmlFile has a parentResource but is using the macro \%$macro\%.  It must use \%PARENT_$macro\% instead\n";
      }
      $parent = 'PARENT_';
      $name = $self->getParentResource()->getName();
      $version = $self->getParentResource()->getVersion();
    }
    $pluginArgs =~ s/\%${parent}RESOURCE_NAME\%/$name/g;
    $pluginArgs =~ s/\%${parent}RESOURCE_VERSION\%/$version/g;
    return $pluginArgs;
}

sub getDescription {
    my ($self) = @_;

    return $self->{parsedXml}->{description};
}

sub getPublications {
    my ($self) = @_;

    if (!$self->{publications}) {
	$self->{publications} = [];
	foreach my $pubmedId ($self->{parsedXml}->{publication}->{pmid}) {
	    my $publication = {pubmedId => $pubmedId};
	    $publication->{citation} = `pubmedIdToCitation $pubmedId`;
	    die "failed calling 'pubmedIdToCitation $pubmedId'" if $? >> 8;
	}
    }
    return $self->{publications};
}


1;
