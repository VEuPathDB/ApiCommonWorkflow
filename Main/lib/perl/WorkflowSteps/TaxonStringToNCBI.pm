package ApiCommonWorkflow::Main::WorkflowSteps::TaxonStringToNCBI;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use File::Basename;

sub run {
    my ($self, $test, $undo) = @_;

    my $workflowDataDir = $self->getWorkflowDataDir();

    my $extDBName = $self->getParamValue('extDBName');
    my $extDBVer = $self->getExtDbVersion($test, $extDBName);
    my $taxonStringFile = $extDBName . "/cluster/master/mainresult/final_taxonString.tab";
    my $taxonMappingFile = "DADA2TaxonMapping_RSRC/taxonMapping.xml";

    my $args = "--sequenceToTaxonHierarchyFile $workflowDataDir/$taxonStringFile --taxonMappingFile $workflowDataDir/$taxonMappingFile --dbRlsSpec \"$extDBName|$extDBVer\"";

    #not sure about the next
    #$self->testInputFile('aliasesFile', "$fileFullPath");
    $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertSequenceTaxon", $args);

}


1;
