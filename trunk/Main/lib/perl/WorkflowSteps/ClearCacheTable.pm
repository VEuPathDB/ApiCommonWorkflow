package ApiCommonWorkflow::Main::WorkflowSteps::ClearCacheTable;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $cacheTable = $self->getParamValue('cacheTable');
  my $organismFullName = $self->getParamValue('organismFullName');
  my $deprecated = ($self->getParamValue('deprecated') eq 'true') ? 1 :0;
  my $attributesTable = $self->getParamValue('attributesTable');

  my $sql = "delete from $cacheTable where source_id in (select distinct source_id from $attributesTable";

  my ($organismSql, $deprecatedSql) ;
      
  $organismSql= "organism='$organismFullName'" unless ($organismFullName eq '');

  $deprecatedSql = "is_deprecated=$deprecated" if (lc($cacheTable) eq 'apidb.genedetail');

  if ($organismSql && $deprecatedSql){

      $sql .= " where $organismSql and $deprecatedSql";
  }elsif ($organismSql){

      $sql .= " where $organismSql";
  }elsif($deprecatedSql){
      $sql .= " where $deprecatedSql";
  }

  $sql .=")";

  my $cmd = "executeIdSQL.pl --idSQL \"$sql\"";


  if ($undo){
     $self->runCmd(0, "echo Doing nothing for \"undo\" Clear Cache Table.\n");  
  }else{
      if ($test) {
      }else {
	  $self->runCmd($test, $cmd);
      }
  }


}

sub getParamsDeclaration {
  return (
	  'cacheTable',
	  'organismFullName',
	  'deprecated',
	  'attributesTable',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


