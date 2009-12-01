package ApiCommonWorkflow::Main::DataSource;

use strict;

sub new {
  my ($class, $parsedXml) = @_;

  my $self = {parsedXml => $parsedXml};

  bless($self,$class);

  return $self;
}

sub getName {
    my ($self);

    return $self->{parsedXml}->{};
}

sub getVersion {
    my ($self);

    return $self->{parsedXml}->{version};
}

sub getUrl {
    my ($self);

    return $self->{parsedXml}->{url};
}

sub getDisplayName {
    my ($self);

    return $self->{parsedXml}->{};
}

sub getOrganisms {
    my ($self);

    return $self->{parsedXml}->{};
}

sub getCategory {
    my ($self);

    return $self->{parsedXml}->{};
}

sub getPlugin {
    my ($self);

    return $self->{parsedXml}->{};
}

sub getWgetArgs {
    my ($self);

    return $self->{parsedXml}->{};
}

sub getUnpacks {
    my ($self);

    return $self->{parsedXml}->{};
}

sub getUnpackOutput {
    my ($self);

    return $self->{parsedXml}->{};
}

sub getPluginArgs {
    my ($self);

    return $self->{parsedXml}->{};
}

sub getDescription {
    my ($self);

    return $self->{parsedXml}->{};
}

