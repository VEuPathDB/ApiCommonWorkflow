package ApiCommonWorkflow::Main::WorkflowSteps::MakeGenomicDoubleStrandFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub getWebsiteFileCmd {
    my ($self, $downloadFileName, $test) = @_;

  # get parameters

  my $organismSource = $self->getParamValue('organismSource');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $ncbiTaxonId = $self->getOrganismInfo($test, $organismAbbrev)->getNcbiTaxonId();

  my $tuningTablePrefix = $self->getTuningTablePrefix($organismAbbrev, $test);

  my $sql = <<"EOF";
      SELECT sa.source_id
                ||' | strand=(+)'
                ||' | organism='||
               replace(sa.organism, ' ', '_')
                ||' | version='||
               sa.database_version
                ||' | length=' ||
               sa.length || ' | SO=' || so.name
               as defline,
               ns.sequence
           FROM dots.nasequence ns, sres.ontologyTerm so,
                ApidbTuning.${tuningTablePrefix}SequenceAttributes sa
          WHERE ns.na_sequence_id = sa.na_sequence_id
            AND sa.ncbi_tax_id = $ncbiTaxonId
            AND sa.is_top_level = 1 
            AND so.source_id = sa.so_id
EOF

  my $cmd = "gusExtractSequences --outputFile $downloadFileName  --idSQL \"$sql\"  --posStrand '\\+' --negStrand '-' ";
  return $cmd;
}


