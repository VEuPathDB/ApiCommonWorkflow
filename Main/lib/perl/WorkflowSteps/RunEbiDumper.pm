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
  my $genomeVersion = $self->getParamValue('genomeVersion');
  my $ebiOrganismName = $self->getParamValue('ebiOrganismName');
  my $genomeDir = $self->getParamValue('genomeDir');
  my $outputDir = $self->getParamValue('outputDir');
  my $datasetName = $self->getParamValue('datasetName');
  my $chromosomeMapFile = $self->getParamValue('chromosomeMapFile');

  my $project_name = $self->getWorkflowConfig('name');
  my $project_release = $self->getWorkflowConfig('version');

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $gusConfigFile = $self->getGusConfigFile();

  my $fullGenomeDir = "$workflowDataDir/$genomeDir";
  my $chromosomeMapFullPath = "$workflowDataDir/$chromosomeMapFile";

  my $unpackDir = "$fullGenomeDir/unpack";
  my $initSqlDir = "$fullGenomeDir/sql";
  my $mysqlDir = "$fullGenomeDir/mysql_data";
  my $socketDir = "$fullGenomeDir/mysqld";
  $outputDir = "$workflowDataDir/${outputDir}";


  my $containerName = $organismAbbrev;
  $containerName =~ s/MPRONA19//;   # shorten the organism abbrev for lsp.NamibiaMPRONA1975252LV425
  $containerName =~ s/[aeiou-]//ig; # shorten the organism abbrev;

  my $cmd = "ebiDumper.pl --gusConfigFile $gusConfigFile --socket_directory $socketDir --init_directory $initSqlDir --mysql_directory $mysqlDir --output_directory $outputDir --chromosome_map_file $chromosomeMapFullPath --ncbi_tax_id $ncbiTaxonId --container_name $containerName --dataset_name $datasetName --dataset_version $genomeVersion --project_name $project_name --project_release $project_release --ebi2gus_tag $ebi2gusTag --organism_abbrev $organismAbbrev";

  if ($undo) {
    $self->runCmd(0, "rm -rf $mysqlDir");
    $self->runCmd(0, "rm -rf $outputDir");
    $self->runCmd(0, "rm -rf $initSqlDir");
    $self->runCmd(0, "rm -rf $unpackDir");
    $self->runCmd(0, "rm -rf $socketDir");
  } else {
    $self->runCmd($test, "mkdir -p $mysqlDir");
    $self->runCmd($test, "mkdir -p $outputDir");
    $self->runCmd($test, "mkdir -p $unpackDir");
    $self->runCmd($test, "mkdir -p $initSqlDir");
    $self->runCmd($test, "mkdir -p $socketDir");
    $self->runCmd($test, "wget --ftp-user ${ebiFtpUser} --ftp-password ${ebiFtpPassword} -O ${unpackDir}/init.sql.gz ftp://ftp-private.ebi.ac.uk:/EBIout/${ebiVersion}/coredb/${project_name}/${ebiOrganismName}.sql.gz");
    $self->runCmd($test, "gunzip -c ${unpackDir}/init.sql.gz >${initSqlDir}/init.sql");

    # $self->testInputFile('initSqlFile', "$initSqlDir/*.sql");

    $self->runCmd($test,$cmd);
  }
}

1;

