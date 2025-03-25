package ApiCommonWorkflow::Main::Util::OrganismInfo;

use strict;
use CBIL::Util::PropertySet;
use DBI;

sub new {
    my ($class, $workflowStep, $test, $organismAbbrev, $gusConfigFile) = @_;

    my $self = {
      test => $test,
		  organismAbbrev => $organismAbbrev,
		  gusConfigFile => $gusConfigFile,
		  workflowStep => $workflowStep
    };
    bless($self,$class);

    return $self if $test;

    my @properties;
    my $gusConfig = CBIL::Util::PropertySet -> new ($gusConfigFile, \@properties, 1);

    my $dbh = DBI->connect($gusConfig->{props}->{dbiDsn},
                           $gusConfig->{props}->{databaseLogin},
                           $gusConfig->{props}->{databasePassword}
        ) or $self->error(DBI->errstr);





    my $sql = "select organism_id, name_for_filenames, strain_abbrev, public_abbrev,
                      is_family_representative, family_ncbi_taxon_ids, family_name_for_files
               from apidb.organism
               where abbrev = '$organismAbbrev'";

    my ($organismId, $nameForFiles, $strainAbbrev, $publicAbbrev, $isFamilyRepresentative, $familyNcbiTaxonIds, $familyNameForFiles) = $workflowStep->runSqlFetchOneRowFromOrgDb($test,$sql,$dbh);

    $sql = "select tn.name, t.ncbi_tax_id, o.taxon_id
            from sres.taxonname tn, sres.taxon t, apidb.organism o
            where o.abbrev = '$organismAbbrev'
              and t.taxon_id = o.taxon_id
              and tn.taxon_id = t.taxon_id
              and tn.name_class = 'scientific name'";

    my ($fullName, $ncbiTaxonId, $taxonId) = $workflowStep->runSqlFetchOneRowFromOrgDb($test,$sql, $dbh);

    die "Could not find taxon_id for organismAbbrev '$organismAbbrev'" unless $taxonId;

    $self->{fullName} = $fullName;
    $self->{nameForFiles} = $nameForFiles;
    $self->{organismId} = $organismId;
    $self->{strainAbbrev} = $strainAbbrev;
    $self->{publicAbbrev} = $publicAbbrev;
    $self->{ncbiTaxonId} = $ncbiTaxonId;
    $self->{taxonId} = $taxonId;
    $self->{isFamilyRepresentative} = $isFamilyRepresentative;
    $self->{familyNcbiTaxonIds} = $familyNcbiTaxonIds;
    $self->{familyNameForFiles} = $familyNameForFiles;

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

sub getTaxonId {
    my ($self) = @_;
    return "$self->{organismAbbrev}_TAXON_ID" if $self->{test};
    return $self->{taxonId};
}

sub getSpeciesNameForFiles {
    my ($self) = @_;
    return "$self->{organismAbbrev}_SPECIES_NAME" if $self->{test};
    my $speciesNameForFiles = $self->{nameForFiles};
    $speciesNameForFiles =~ s/$self->{strainAbbrev}$//;
    return $speciesNameForFiles;
}
sub getOrganismId {
    my ($self) = @_;
    return "$self->{organismAbbrev}_ORGANISM_ID" if $self->{test};
    return $self->{organismId};
}


sub getSpeciesNameFromNcbiTaxId {
    my ($self, $ncbiTaxId) = @_;

    my $edirectCommand = "singularity run docker://ncbi/edirect:20.6 esummary -db taxonomy -id $ncbiTaxId 2>/dev/null \| singularity run docker://ncbi/edirect:20.6 xtract -pattern DocumentSummary -element ScientificName 2>/dev/null";


    my $speciesName = `$edirectCommand`;
    $speciesName =~ s/\n$//;

    if($speciesName) {
        return $speciesName;
    }
    die "Could not retrieve a species name for ncbi tax id [$ncbiTaxId]";

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

sub getSubTaxaListFromNcbiTaxonId {
  my ($self, $ncbiTaxonId, $gusConfigFile) = @_;

    my $idList = $self->{workflowStep}->runCmd($self->{test}, "getSubTaxaListFromNcbiTaxonId --NCBITaxId $ncbiTaxonId --gusConfigFile $gusConfigFile");

    if ($self->{test}) {
      return "$self->{organismAbbrev}_TAXON_ID_LIST";
    } else {
      chomp($idList);
      return  $idList;
    }
}

sub getIsFamilyRepresentative{
    my ($self) = @_;
    return "$self->{organismAbbrev}_IS_FAMILY_REP" if $self->{test};
    return $self->{isFamilyRepresentative};
}

sub getFamilyNcbiTaxonIds {
    my ($self) = @_;
    return "$self->{organismAbbrev}_FAMILY_NCBI_TAXON_ID" if $self->{test};
    return $self->{famiyNcbiTaxonIds};
}

sub getFamilyNameForFiles {
    my ($self) = @_;
    return "$self->{organismAbbrev}_FAMILY_NAME_FOR_FILES" if $self->{test};
    return $self->{familyNameForFiles};
}

1;
