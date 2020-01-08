package ApiCommonWorkflow::Main::WorkflowSteps::RunEbiDumper;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $ebiFtpUser = $self->getConfig('ebiFtpUser');
  my $ebiFtpPassword = $self->getConfig('ebiFtpPassword');

  my $ncbiTaxonId = $self->getParamValue('ncbiTaxonId');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $ebi2gusTag = $self->getParamValue('ebi2gusTag');
  my $ebiVersion = $self->getParamValue('ebiVersion');
  my $ebiOrganismName = $self->getParamValue('ebiOrganismName');
  my $genomeDir = $self->getParamValue('genomeDir');
  my $outputDir = $self->getParamValue('outputDir');
  my $datasetName = $self->getParamValue('datasetName');
  my $chromosomeMapFile = $self->getParamValue('chromosomeMapFile');

  my $project_name = $self->getWorkflowConfig('name');
  my $project_release = $self->getWorkflowConfig('version');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $fullGenomeDir = "$workflowDataDir/$genomeDir";
  my $chromosomeMapFullPath = "$workflowDataDir/$chromosomeMapFile";

  my $unpackDir = "$fullGenomeDir/unpack";
  my $initSqlDir = "$fullGenomeDir/sql";
  my $mysqlDir = "$fullGenomeDir/mysql_data";

  my $gusSchemaDefFullPath = "${unpackDir}/gusSchemaDefinitions.xml";

  $self->runCmd(0, "mkdir -p $mysqlDir");
  $self->runCmd(0, "mkdir -p $outputDir");   
  $self->runCmd(0, "mkdir -p $unpackDir");   
  $self->runCmd(0, "mkdir -p $initSqlDir");   

  my $cmd = "ebiDumper.pl -init_directory $initSqlDir --mysql_directory $mysqlDir --output_directory $outputDir --schema_definition_file $gusSchemaDefFullPath --chromosome_map_file $chromosomeMapFullPath --ncbi_tax_id $ncbiTaxonId --container_name $organismAbbrev --dataset_name $datasetName --dataset_version $ebiVersion --project_name $project_name --project_release $project_release --ebi2gus_tag $ebi2gusTag --organism_abbrev $organismAbbrev";

  if ($undo) {
    $self->runCmd(0, "rm -rf $mysqlDir");
    $self->runCmd(0, "rm -rf $outputDir");
    $self->runCmd(0, "rm -rf $initSqlDir");
    $self->runCmd(0, "rm -rf $unpackDir");
  } else {
    $self->runCmd("wget --ftp-user ${ebiFtpUser} --ftp-password ${ebiFtpPassword} -O ${unpackDir}/init.sql.gz ftp://ftp-private.ebi.ac.uk:/EBIout/${ebiVersion}/coredb/${ebiOrganismName}/${ebiOrganismName}_core_*.gz");
    $self->runCmd("gunzip -c ${unpackDir}/init.sql.gz >${initSqlDir}/init.sql");
    $self->runCmd("generateDatabaseSchemaXml >$gusSchemaDefFullPath");

    $self->testInputFile('initSqlFile', "$initSqlDir/*.sql");

    $self->runCmd($test,$cmd);
  }
}

1;

