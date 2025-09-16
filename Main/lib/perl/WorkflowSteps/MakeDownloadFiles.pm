package ApiCommonWorkflow::Main::WorkflowSteps::MakeDownloadFiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $gusConfigFile = $workflowDataDir . "/" . $self->getParamValue('gusConfigFile');

  my $relativeDownloadSiteDir = $self->getParamValue('relativeDownloadSiteDir');
  my $release = $self->getParamValue('release');
  my $project = $self->getParamValue('project');
  my $coreGroupsFile = $self->getParamValue('coreGroupsFile');
  my $residualGroupsFile = $self->getParamValue('residualGroupsFile');
  my $orthomclVersion = $self->getParamValue('orthomclVersion');
  $orthomclVersion =~ s/_//g;
  my $groupFile = $workflowDataDir . "/" . $self->getParamValue('fullGroupFile');

  #original for core plus periph proteomes build $self->testInputFile('groupsFile', "$workflowDataDir/finalGroups.txt");
  $self->testInputFile('groupsFile', "$workflowDataDir/$coreGroupsFile");

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);

  my $seqsDownloadFileName = "$websiteFilesDir/$relativeDownloadSiteDir/aa_seqs_$project-$release.fasta";
  my $deflinesDownloadFileName = "$websiteFilesDir/$relativeDownloadSiteDir/deflines_$project-$release.txt";
  my $groupsDownloadFileName = "$websiteFilesDir/$relativeDownloadSiteDir/groups_$project-$release.txt";
  my $domainsDownloadFileName = "$websiteFilesDir/$relativeDownloadSiteDir/domainFreqs_$project-$release.txt";
  my $genomeSummaryFileName = "$websiteFilesDir/$relativeDownloadSiteDir/genomeSummary_$project-$release.txt";
  my $corePairsDownloadDir = "$websiteFilesDir/$relativeDownloadSiteDir/coreGroups_$project-$release";
  my $residualPairsDownloadDir = "$websiteFilesDir/$relativeDownloadSiteDir/residualGroups_$project-$release";

  if ($undo) {
    $self->runCmd($test, "rm $seqsDownloadFileName.gz");
    $self->runCmd($test, "rm $deflinesDownloadFileName.gz");
    $self->runCmd($test, "rm $groupsDownloadFileName.gz");
    $self->runCmd($test, "rm $domainsDownloadFileName.gz");
    $self->runCmd($test, "rm $genomeSummaryFileName.gz");
    $self->runCmd($test, "rm -r $corePairsDownloadDir");
    $self->runCmd($test, "rm -r $residualPairsDownloadDir");

  } else {

    # fasta
    my $sql = $self->getSql(1);
    $self->runCmd($test, "mkdir -p $websiteFilesDir/$relativeDownloadSiteDir");
    $self->runCmd($test, "gusExtractSequences --outputFile $seqsDownloadFileName --idSQL \"$sql\" --gusConfigFile $gusConfigFile");
    $self->runCmd($test, "gzip $seqsDownloadFileName");

    # deflines
    $sql = $self->getSql(0);
    $self->runCmd($test, "gusExtractSequences --outputFile $deflinesDownloadFileName --idSQL \"$sql\" --gusConfigFile $gusConfigFile --noSequence");
    $self->runCmd($test, "gzip $deflinesDownloadFileName");

    # domain frequencies
    $sql = $self->getDomainsSql();
    $self->runCmd($test, "makeFileWithSql --outFile $domainsDownloadFileName --sql \"$sql\" --gusConfigFile $gusConfigFile");
    $self->runCmd($test, "gzip $domainsDownloadFileName");

    # groups
    # original for core plu periph proteomes $self->runCmd($test, "cp $workflowDataDir/finalGroups.txt $groupsDownloadFileName");
    $self->runCmd($test, "cp $groupFile $groupsDownloadFileName");
    $self->runCmd($test, "gzip $groupsDownloadFileName");

    # genome summary
    $sql = $self->getGenomeSummarySql();
    $self->runCmd($test, "makeFileWithSql --outFile $genomeSummaryFileName --sql \"$sql\" --includeHeader --outDelimiter \"\\t\" --gusConfigFile $gusConfigFile");
    $self->runCmd($test, "gzip $genomeSummaryFileName");

    # pairs
    $self->runCmd($test, "mkdir -p $corePairsDownloadDir");
    $self->runCmd($test, "cp $workflowDataDir/$coreGroupsFile $corePairsDownloadDir");
    $self->runCmd($test, "gzip $corePairsDownloadDir/*");
    $self->runCmd($test, "mkdir -p $residualPairsDownloadDir");
    $self->runCmd($test, "cp $workflowDataDir/$residualGroupsFile $residualPairsDownloadDir");
    $self->runCmd($test, "gzip $residualPairsDownloadDir/*");
  }
}

sub getSql {
  my ($self, $seq) = @_;

  my $SS = $seq? ", x.sequence" : "";
return "
SELECT deas.secondary_identifier, ogas.group_id as group_id, deas.description, deas.sequence
FROM dots.externalaasequence deas, apidb.orthologgroupaasequence ogas
WHERE ogas.aa_sequence_id = deas.aa_sequence_id
UNION
SELECT das.source_id, ogas.group_id as group_id, das.description, das.sequence
FROM dots.aasequence das, apidb.orthologgroupaasequence ogas
WHERE ogas.aa_sequence_id = das.aa_sequence_id
";

}

sub getDomainsSql {
  my ($self, $extDbRlsId) = @_;

return "
SELECT 
    name AS Orthomcl_Group,
    primary_identifier AS Pfam_Name,
    ROUND(COUNT(aa_sequence_id) / number_of_members, 4) AS Frequency
FROM (
    SELECT DISTINCT 
        og.group_id AS name,
        ir.interpro_primary_id as primary_identifier,
        ogs.aa_sequence_id,
        q.number_of_members
    FROM 
        apidb.OrthologGroupAaSequence ogs
        JOIN apidb.OrthologGroup og ON ogs.group_id = og.group_id
        JOIN (
            SELECT 
                group_id, 
                COUNT(aa_sequence_id) AS number_of_members
            FROM apidb.OrthologGroupAaSequence
            GROUP BY group_id
        ) q ON ogs.group_id = q.group_id
        JOIN dots.aasequence das ON das.aa_sequence_id = ogs.aa_sequence_id
        JOIN apidb.interproresults ir ON ir.protein_source_id = das.source_id
    WHERE 
        og.ortholog_group_id != 0
        AND og.is_residual IN (0, 1)
        AND ir.interpro_db_name = 'Pfam'
) qry
GROUP BY 
    name, 
    number_of_members, 
    primary_identifier
ORDER BY 
    name, 
    frequency DESC
"
}

sub getGenomeSummarySql {
    my ($self) = @_;

    return "
SELECT og.name_for_filenames, og.orthomcl_abbrev, 
case og.core_peripheral when 'core' then 'Core' when 'peripheral' then 'Peripheral' else '' end as core_peripheral,
od.resource_name, od.resource_url
FROM apidb.organism og, apidb.orthomclresource od
Where od.orthomcl_taxon_id = og.taxon_id
ORDER By og.name_for_filenames
"
}
