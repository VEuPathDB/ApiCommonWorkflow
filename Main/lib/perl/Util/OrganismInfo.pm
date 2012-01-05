package ApiCommonWorkflow::Main::Util::OrganismInfo;

use strict;

sub new {
    my ($class, $workflowStep, $test, $organismAbbrev) = @_;

    my $self = {test => $test,
		organismAbbrev => $organismAbbrev,
		workflowStep => $workflowStep
	       };
    bless($self,$class);

    return $self if $test;

    my $sql = "select organism_id, name_for_filenames, abbrev_strain, abbrev_public
             from apidb.organism
             where abbrev = '$organismAbbrev'";

    my $stmt = $workflowStep->runSql($sql);
    my ($organismId, $nameForFiles, $strainAbbrev, $publicAbbrev) = $stmt->fetchrow_array(); 

    $sql = "select tn.name, t.ncbi_tax_id, o.taxon_id
             from sres.taxonname tn, sres.taxon t, apidb.organism o
             where o.abbrev = '$organismAbbrev'
             and t.taxon_id = o.taxon_id
             and tn.taxon_id = t.taxon_id
             and tn.name_class = 'scientific name'";

    my $stmt = $workflowStep->runSql($sql);
    my ($fullName, $ncbiTaxonId, $taxonId) = $stmt->fetchrow_array(); 

    $sql = "select ncbi_tax_id, taxon_id
   from
  (select taxon_id, ncbi_tax_id, rank 
   from sres.taxon
   connect by taxon_id = prior parent_id
   start with taxon_id = $taxonId) t
   where t.rank = 'species'";

    $stmt = $workflowStep->runSql($sql);
    my ($speciesNcbiTaxonId, $speciesTaxonId) = $stmt->fetchrow_array(); 

    $sql = "select name
            from sres.taxonname
            where taxon_id = $speciesTaxonId
            and name_class = 'scientific name'";

    $stmt = $workflowStep->runSql($sql);
    my ($speciesName) = $stmt->fetchrow_array(); 

    $self->{fullName} = $fullName;
    $self->{nameForFiles} = $nameForFiles;
    $self->{strainAbbrev} = $strainAbbrev;
    $self->{publicAbbrev} = $publicAbbrev;
    $self->{ncbiTaxonId} = $ncbiTaxonId;
    $self->{taxonId} = $taxonId;
    $self->{speciesNcbiTaxonId} = $speciesNcbiTaxonId;
    $self->{speciesTaxonId} = $speciesTaxonId;
    $self->{speciesName} = $speciesName;

    return $self;
}

sub getFullName {
    my ($self) = @_;
    return "$self->{organismAbbrev}_FULL_NAME" if $self->{test};
    return $self->{fullName};
}

sub getNameForFiles {
    my ($self) = @_;
    return "$self->{organismAbbrev}_NAME_FOR_FILES" if $self->{test};
    return $self->{nameForFiles};
}

sub getNcbiTaxonId {
    my ($self) = @_;
    return "$self->{organismAbbrev}_NCBI_TAXON_ID" if $self->{test};
    return $self->{ncbiTaxonId};
}

sub getSpeciesNcbiTaxonId {
    my ($self) = @_;
    return "$self->{organismAbbrev}_SPECIES_NCBI_TAXON_ID" if $self->{test};
    return $self->{speciesNcbiTaxonId};
}

sub getTaxonId {
    my ($self) = @_;
    return "$self->{organismAbbrev}_TAXON_ID" if $self->{test};
    return $self->{taxonId};
}

sub getSpeciesTaxonId {
    my ($self) = @_;
    return "$self->{organismAbbrev}_SPECIES_TAXON_ID" if $self->{test};
    return $self->{speciesTaxonId};
}

sub getSpeciesName {
    my ($self) = @_;
    return "$self->{organismAbbrev}_SPECIES_NAME" if $self->{test};
    return $self->{speciesName};
}

sub getSpeciesNameForFiles {
    my ($self) = @_;
    return "$self->{organismAbbrev}_SPECIES_NAME_FOR_FILES" if $self->{test};
    my @a = split(/\s/, $self->{speciesName});
    $self->error("Species name '$self->{speciesName}' does not split into genus and species)") unless scalar(@a) == 2;
    return substr($a[0], 0, 1) . $a[1];
}

sub getOrganismId {
    my ($self) = @_;
    return "$self->{organismAbbrev}_ORGANISM_ID" if $self->{test};
    return $self->{organismId};
}

sub getStrainAbbrev {
    my ($self) = @_;
    return "$self->{organismAbbrev}_STRAIN_ABBREV" if $self->{test};
    return $self->{strainAbbrev};
}

sub getPublicAbbrev {
    my ($self) = @_;
    return "$self->{organismAbbrev}_PUBLIC_ABBREV" if $self->{test};
    return $self->{publicAbbrev};
}

sub getTaxonIdList {
  my ($self, $taxonId) = @_;

    my $idList = $self->{workflowStep}->runCmd($self->{test}, "getSubTaxaList --taxon_id $taxonId");

    if ($self->{test}) {
      return "$self->{organismAbbrev}_TAXON_ID_LIST";
    } else {
      chomp($idList);
      return  $idList;
    }
}

#sub getIsDraftGenome {
#    my ($self) = @_;
#    return "$self->{organismAbbrev}_IS_DRAFT_GENOME" if $self->{test};
#    return $self->{isDraftGenome};
#}


1;
