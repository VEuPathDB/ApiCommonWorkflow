package ApiCommonWorkflow::Main::WorkflowSteps::MakeGenomicDoubleStrandFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::DownloadFileMaker);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::DownloadFileMaker;


sub getDownloadFileCmd {
    my ($self, $downloadFileName, $test) = @_;

  # get parameters

  my $organismSource = $self->getParamValue('organismSource');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $ncbiTaxonId = $self->getOrganismInfo($organismAbbrev)->getNcbiTaxonId();

  my $soTerms =  $self->getSoIds($test, $self->getParamValue('cellularLocationSoTerms'));

  my $soIds =  $self->getSoIds($test, $soTerms);

  my $sql = <<"EOF";
      SELECT '$organismSource'
                ||'|'||
               sa.source_id
                ||' | strand=(+)'
                ||' | organism='||
               replace(sa.organism, ' ', '_')
                ||' | version='||
               sa.database_version
                ||' | length=' ||
               sa.length
               as defline,
               ns.sequence
           FROM dots.nasequence ns,
                ApidbTuning.SequenceAttributes sa,
          WHERE ns.na_sequence_id = sa.na_sequence_id
            AND sa.ncbi_tax_id = $ncbiTaxonId
            AND sa.is_top_level = 1 
            AND ns.sequence_ontology_id in ($soIds)
EOF

  my $cmd = "gusExtractSequences --outputFile $downloadFileName  --idSQL \"$sql\"  --posStrand '\\+' --negStrand '-' ";
  return $cmd;
}


