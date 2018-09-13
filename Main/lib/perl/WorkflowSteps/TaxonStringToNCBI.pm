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
    if (! -e "$workflowDataDir/$taxonStringFile") {
      #then look for file copied from manual delivery
      $taxonStringFile = $extDBName . "/final/taxonString.tab";
    }

    my $taxonMappingFile = "OverrideTaxonMapping_RSRC/taxonMapping.xml";

    my $args = "--sequenceToTaxonHierarchyFile $workflowDataDir/$taxonStringFile --taxonMappingFile $workflowDataDir/$taxonMappingFile --dbRlsSpec \"$extDBName|$extDBVer\"";

    #run only if we found a file for input
    #otherwise assume we're sequences rather than taxon strings
    if (-e "$workflowDataDir/$taxonStringFile") {
      $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertSequenceTaxon", $args);
    }
}


1;
