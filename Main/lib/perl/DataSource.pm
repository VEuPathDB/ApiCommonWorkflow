package ApiCommonWorkflow::Main::DataSource;

use strict;
use Data::Dumper;

sub new {
  my ($class, $dataSourceName, $parsedXml) = @_;

  my $self = {};
  $self->{parsedXml} = $parsedXml;
  $self->{dataSourceName} = $dataSourceName;

  bless($self,$class);

  return $self;
}

sub getName {
    my ($self) = @_;

    return $self->{dataSourceName};
}

sub getLegacyExtDbName {
    my ($self) = @_;

    return $self->{legacyExtDbName};
}

sub getVersion {
    my ($self) = @_;

    return $self->{parsedXml}->{version};
}

sub getUrl {
    my ($self) = @_;

    return $self->{parsedXml}->{url};
}

sub getDisplayName {
    my ($self) = @_;

    return $self->{parsedXml}->{displayName};
}

sub getOrganisms {
    my ($self) = @_;

    return $self->{parsedXml}->{organisms};
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

sub getManualArgs {
    my ($self) = @_;

    return $self->{parsedXml}->{manualGet};
}

sub getUnpacks {
    my ($self) = @_;

    return $self->{parsedXml}->{unpacks};
}

sub getUnpackOutput {
    my ($self) = @_;

    return $self->{parsedXml}->{unpackOutput};
}

sub getPluginArgs {
    my ($self) = @_;

    return $self->{parsedXml}->{pluginArgs};
}

sub getDescription {
    my ($self) = @_;

    return $self->{parsedXml}->{description};
}

1;
