package ApiCommonWorkflow::Main::WorkflowSteps::MakeEpitopeMappingNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use warnings;
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
    my ($self, $test, $undo) = @_;
   
    my $workflowDataDir = $self->getWorkflowDataDir();
    my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
    my $results = join("/", $workflowDataDir, $self->getParamValue("clusterResultDir"));
    my $refFasta = join("/",$workflowDataDir, $self->getParamValue("refFasta"));
    my $peptidesTab = join("/",$workflowDataDir, $self->getParamValue("peptidesTab"));
    #my $peptideGeneFasta = $self->getParamValue("peptideGeneFasta");
    my $ncbiTaxon = $self->getParamValue("ncbiTaxon");
    my $peptideMatchResults = $self->getParamValue("peptideMatchResults");
    my $peptidesFilteredBySpeciesFasta = $self->getParamValue("peptidesFilteredBySpeciesFasta");
    my $peptideMatchBlastCombinedResults = $self->getParamValue("peptideMatchBlastCombinedResults");
    #my $chunkSize = $self->getParamValue("chunkSize");
    my $configPath = join("/", $self->getWorkflowDataDir(), $self->getParamValue("configFileName"));


   if ($undo) {
    $self->runCmd(0,"rm -rf $configPath");
  } else {  

    open(F, ">", $configPath) or die "$! :Can't open config file '$configPath' for writing";
 print F
  " 
 params {
   refFasta = \"$refFasta\" 
   peptidesTab = \"$peptidesTab\"
   taxon = $ncbiTaxon
   peptideMatchResults = \"$peptideMatchResults\"
   peptidesFilteredBySpeciesFasta = \"$peptidesFilteredBySpeciesFasta\"
   peptideMatchBlastCombinedResults = \"$peptideMatchBlastCombinedResults\"
   chunkSize = 500
   results = \"$results\"

   }

    singularity {
    enabled = true
    autoMounts = true
   }
  "

  }

}
1;
