package ApiCommonWorkflow::Main::WorkflowSteps::CreateFullRecordFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $record = $self->getParamValue('record');
  my $organismFullName = $self->getParamValue('organismFullName');
  my $attributesTable = $self->getParamValue('attributesTable');
  my $cacheTable = $self->getParamValue('cacheTable');
  my $model = $self->getParamValue('model');
  my $dumpFile = $self->getParamValue('dumpFile');
  my $deprecated = ($self->getParamValue('deprecated') eq 'true') ? 1 :0;

  my $apiSiteFilesDir = $self->getSharedConfig('apiSiteFilesDir');

  my $sqlFile="all_PKs.sql";

  my $sqlFileString="SELECT DISTINCT project_id, source_id FROM $attributesTable";

  my ($organismSql, $deprecatedSql) ;
      
  $organismSql= "organism='$organismFullName'" unless ($organismFullName eq '');

  $deprecatedSql = "is_deprecated=$deprecated" if (lc($cacheTable) eq 'apidb.genedetail');

  if ($organismSql && $deprecatedSql){

      $sqlFileString .= " where $organismSql and $deprecatedSql";
  }elsif ($organismSql){

      $sqlFileString .= " where $organismSql";
  }elsif($deprecatedSql){
      $sqlFileString .= " where $deprecatedSql";
  }

  open(F,">$sqlFile");
  print F $sqlFileString;
  close F;

  my $cmd = "createFullRecordFile -record $record -sqlFile $sqlFile -cacheTable $cacheTable -model $model  -dumpFile $apiSiteFilesDir/$dumpFile >> FullRecordFileDumpDetails.out 2>> FullRecordFileDumpDetails.err &";


  if ($undo){

    $self->runCmd(0, "rm -f $apiSiteFilesDir/$dumpFile");

  }else{
      if ($test) {
	  $self->runCmd(0,"echo test > $apiSiteFilesDir/$dumpFile");
      }else {
	  $self->runCmd($test, $cmd);
      }
  }

}

sub getParamsDeclaration {
  return (
	  'record',
	  'organismFullName',
	  'attributesTable',
	  'cacheTable',
	  'model',
	  'deprecated',
	  'dumpFile',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


