package ApiCommonWorkflow::Main::WorkflowSteps::MakeDotsAssemblyDownloadFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;

sub getWebsiteFileCmd {
    my ($self, $downloadFileName, $test) = @_;

    my $organismAbbrev = $self->getParamValue('organismAbbrev');
    my $gusConfigFile = $self->getParamValue('gusConfigFile');
    $gusConfigFile = $self->getWorkflowDataDir() . "/$gusConfigFile";

    my $ncbiTaxonId = $self->getOrganismInfo($test, $organismAbbrev, $gusConfigFile)->getNcbiTaxonId();

    my $sql = "
      SELECT  a.source_id
                ||' | organism='||
          replace(tn.name, ' ', '_')
                ||' | number of sequences='||
          a.number_of_contained_sequences
                ||' | length='||
          a.length as defline,
          a.sequence
       FROM dots.assembly a,
            sres.taxonname tn,
            sres.taxon t
      WHERE t.ncbi_tax_id = $ncbiTaxonId
        AND t.taxon_id = tn.taxon_id
        AND tn.name_class = 'scientific name'
        AND t.taxon_id = a.taxon_id";

    my $cmd = " gusExtractSequences --outputFile $downloadFileName  --idSQL \"$sql\"";
    return $cmd;
}

1;

