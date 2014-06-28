package ApiCommonWorkflow::Main::WorkflowSteps::CreateGffCacheAndFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $organismFullName = $self->getParamValue('organismFullName');
  my $outputFile = $self->getParamValue('outputFile');
  my $model = $self->getParamValue('model');
  my $deprecated = $self->getBooleanParamValue('deprecated');

  my $cmd = "gffDump -model $model -organism '$organismFullName'  --gffFile $outputFile>> GffCacheAndFileDetails.out 2>> GffCacheAndFileDetails.err &";


  if ($undo){

      my $sql = "delete from ApiDB.GENETABLE where source_id in (select distinct source_id from ApidbTuning.GeneAttributes where organism='$organismFullName' and is_deprecated=$deprecated)";

      my $undoCmd = "executeIdSQL.pl  --idSQL \"$sql\"";
     
      $self->runCmd($test, $undoCmd); 
 
  }else{
    $self->runCmd($test, $cmd);
  }

}

1;

