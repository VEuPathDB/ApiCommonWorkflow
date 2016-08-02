package ApiCommonWorkflow::Main::WorkflowSteps::MakeIsolatesReferenceDownloadFile;

## NOTE: this stepclass is specifically extracting the isolates from GenBank
##       If we want another data source, we'll need to extend this step class and add an externaldb param.

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;

use File::Basename;

sub getIsFamilyLevel {
    return 1;
}

sub getSkipIfFile {
  my ($self) = @_;
  return $self->getParamValue('skipIfFile');
}

sub getNameForFilesSuffix {
  return "Reference";
}


sub getWebsiteFileCmd {
  my ($self, $downloadFileName, $test) = @_;

  # we load isolates using the family representative's taxon id, so use that to extract
  # only the family rep calls this step class, so we can just use our org abbrev.
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $organismInfo = $self->getOrganismInfo($test, $organismAbbrev);
  my $taxonId = $organismInfo->getTaxonId();

  my $soExtDbName = $self->getSharedConfig("sequenceOntologyExtDbName");

  my $sql = <<"EOF";
     select enas.source_id
        ||' | organism='||
        replace(tn.name, ' ', '_')
        ||' | length='||
        enas.length as defline,
        enas.sequence
        from apidb.datasource ds
           , sres.externaldatabase d
           , sres.externaldatabaserelease r
           , dots.externalnasequence enas 
           , apidb.organism o
           , sres.taxonname tn
           , results.segmentresult sr
           , study.characteristic c
           , sres.ontologyterm ot
        where ds.type = 'isolates'
        and ds.subtype = 'sequencing_typed'
        and ds.name = d.name
        and ds.version = r.version
        and d.external_database_id = r.external_database_id
        and r.external_database_release_id = enas.external_database_release_id
        and ds.taxon_id = o.taxon_id
        and o.abbrev = '$organismAbbrev'
        and enas.taxon_id = tn.taxon_id
        and tn.name_class = 'scientific name'            
        and enas.na_sequence_id = sr.na_sequence_id
        and sr.protocol_app_node_id = c.protocol_app_node_id
        and c.qualifier_id = ot.ontology_term_id
        and c.value = '1'
        and ot.name = 'isReferenceIsolate'
EOF

   # this will make the isolate reference directory 
   my $dirname = dirname $downloadFileName;
   unless(-d $dirname) {
    system("mkdir -p $dirname");
   }

  my $cmd = "gusExtractSequences --outputFile $downloadFileName  --allowEmptyOutput --idSQL \"$sql\" --verbose ";
  return $cmd;
}

1;
