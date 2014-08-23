package ApiCommonWorkflow::Main::WorkflowSteps::UpdateTaxonFieldFromFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $extDbName = $self->getParamValue('extDbName');
  my $taxIdFile = $self->getParamValue('taxIdFile');


  # this param is really just for PDB which has truncated source ids for
  # some reason.  this is the number of chars to shorten to,  or null to 
  # not shorten
  my $shortenSourceIdTo = $self->getParamValue('shortenSubjectSourceIdTo'); 

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $sourceIdSubstringLength = "";
  $sourceIdSubstringLength = "--sourceIdSubstringLength $shortenSourceIdTo" 
      if $shortenSourceIdTo;

  my $args = "--fileName $workflowDataDir/$taxIdFile  --sourceIdRegex  '^(\\d+)' --ncbiTaxIdRegex '^\\d+\\s(\\d+)' $sourceIdSubstringLength  --extDbRlsName '$extDbName'  --tableName 'DoTS::ExternalAASequence'";


  if($undo){
      # delete from WorkflowStepAlgInvocation because we don't call plugin undo (this step is an update)
      $self->deleteFromTrackingTable($test);
  }else{
      $self->runPlugin($test,$undo, "ApiCommonData::Load::Plugin::UpdateTaxonFieldFromFile",$args);
  }


}




1;
