package ApiCommonWorkflow::Main::WorkflowSteps::RunEbiDumper;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $ncbiTaxonId = $self->getParamValue('ncbiTaxonId');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $ebiVersion = $self->getParamValue('ebiVersion');
  my $parentDataDir = $self->getParamValue('parentDataDir');
  
  my $project_name = $self->getWorkflowConfig('name');
  my $project_release = $self->getWorkflowConfig('version');
  my $workflowDataDir = $self->getWorkflowDataDir();
  my $datasetName = "${organismAbbrev}_primary_genome_RSRC";
  my $initDir = "$workflowDataDir/$parentDataDir/$datasetName";
  my $mysqlDir = "$workflowDataDir/$parentDataDir/$datasetName/data";
  my $outputDir = "$workflowDataDir/$parentDataDir/$datasetName/out";

  $self->runCmd(0, "mkdir -p $mysqlDir");
  $self->runCmd(0, "mkdir -p $outputDir");   
  
  my $cmd = "ebiDumper.pl -init_directory $initDir --mysql_directory $mysqlDir --output_directory $outputDir  --schema_definition_file $ENV{GUS_HOME}/lib/xml/gusSchemaDefinitions.xml --chromosome_map_file $ENV{GUS_HOME}/conf/chromosomeMap.conf.sample --ncbi_tax_id $ncbiTaxonId --container_name $organismAbbrev --dataset_name $datasetName --dataset_version $ebiVersion --project_name $project_name --project_release $project_release";

  if ($undo) {
    $self->runCmd(0, "rm -rf $mysqlDir");
    $self->runCmd(0, "rm -rf $outputDir");
  } else {
    $self->testInputFile('initSqlFile', "$initDir/*.sql");
    $self->runCmd($test,$cmd);
  }
}

1;

