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

  my $cellularLocationSoTerms =  $self->getSoIds($test, $self->getParamValue('cellularLocationSoTerms'));

  my $sql = " SELECT '$organismSource'
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
                SRes.sequenceontology so
          WHERE ns.na_sequence_id = sa.na_sequence_id
            AND sa.database_name in ($extDbNameList) AND sa.database_version in ($extDbRlsVerList)
            AND sa.is_top_level = 1 
            AND so.term_name in ($cellularLocationSoTerms)
            AND ns.sequence_ontology_id = so_sequence_ontology_id";
  my $cmd = "gusExtractSequences --outputFile $downloadFileName  --idSQL \"$sql\"  --posStrand '\\+' --negStrand '-' ";
  return $cmd;
}


