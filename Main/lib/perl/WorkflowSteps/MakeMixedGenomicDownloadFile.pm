package ApiCommonWorkflow::Main::WorkflowSteps::MakeMixedGenomicDownloadFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::DownloadFileMaker);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::DownloadFileMaker;

sub getDownloadFileCmd {
    my ($self, $downloadFileName, $test) = @_;

  # get parameters

    my $organismSource = $self->getParamValue('organismSource');
    my $organismAbbrev = $self->getParamValue('organismAbbrev');
    my $ncbiTaxonId = $self->getOrganismInfo($organismAbbrev)->getNcbiTaxonId();

    my $soIds =  $self->getSoIds($test, $self->getParamValue('cellularLocationSoTerms'));

    my $sql = " SELECT '$organismSource'
                ||'|'||
               sa.source_id
                ||' | organism='||
               replace(sa.organism, ' ', '_')
                ||' | version='||
               sa.database_version
                ||' | length=' ||
               sa.length
               as defline,
               ns.sequence
           FROM dots.nasequence ns,
                ApidbTuning.SequenceAttributes sa
          WHERE ns.na_sequence_id = sa.na_sequence_id
            AND sa.ncbi_tax_id = $ncbiTaxonId
            AND sa.is_top_level = 1
            AND ns.sequence_ontology_id in ($soIds)";
    my $cmd = "gusExtractSequences --outputFile $downloadFileName  --idSQL \"$sql\" ";
    return $cmd;
}


