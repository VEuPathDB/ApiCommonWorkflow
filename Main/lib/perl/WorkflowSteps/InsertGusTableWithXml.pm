package ApiCommonWorkflow::Main::WorkflowSteps::InsertGusTableWithXml;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $xmlFile = $self->getParamValue('xmlFileRelativeToGusHomeDir');
  my $gusTable = $self->getParamValue('gusTable');

  my $gusHome = $self->getSharedConfig('gusHome');

  my $undoArgs = "--undoTables $gusTable";

  my $args = "--filename $gusHome/$xmlFile";

  if ($undo){
      $self->runPlugin($test, $undo, "GUS::Supported::Plugin::LoadGusXml", $undoArgs);
  }else{
      if ($test) {
	  $self->testInputFile('xmlFile', "$gusHome/$xmlFile");
      }else{
	  $self->runPlugin($test, $undo, "GUS::Supported::Plugin::LoadGusXml", $args);
      }
  }

}

sub getParamsDeclaration {
  return (
	  'xmlFile',
	  'gusTable',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


