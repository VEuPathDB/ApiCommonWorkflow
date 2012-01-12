package ApiCommonWorkflow::Main::WorkflowSteps::InsertPlasmoMapp;
@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # this directory that has the data files, and is input to the first plugin.
  my $inputDir = $self->getParamValue('inputDir');

  # this directory will have the temporary output file (made with the first plugin), that will be loaded in database (by the second plugin).
  my $outputDir = $self->getParamValue('outputDir');


  my $workflowDataDir = $self->getWorkflowDataDir();


  # arguments to be passed to plugins:
  my $createFileArgs = "--inDir  $workflowDataDir/$inputDir --outFile $workflowDataDir/$outputDir/plasmoMapp.sql --table ApiDB.plasmoMapp --verbose";

  my $insertDataArgs = "--dataFile $workflowDataDir/$outputDir/plasmoMapp.sql";


  # in test mode, there are no input files to iterate over, so just leave
  if ($test) {
    $self->testInputFile('inputDir', "$workflowDataDir/$inputDir");
  }


  # only 2nd plugin (InsertPlasmoMappWithSqlLdr) adds data to database, so undo can be done in the same order as load
  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::CreatePlasmoMappFile", $createFileArgs);
  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertPlasmoMappWithSqlLdr", $insertDataArgs);
}



sub getConfigDeclaration {
  return (
    	  # [name, default, description]
     	 );
}

