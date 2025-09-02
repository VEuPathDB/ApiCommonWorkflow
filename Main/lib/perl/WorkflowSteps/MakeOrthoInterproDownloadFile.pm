package ApiCommonWorkflow::Main::WorkflowSteps::MakeOrthoInterproDownloadFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $gusConfigFile = $workflowDataDir . "/" . $self->getParamValue('gusConfigFile');

  my $interproExtDb = $self->getParamValue('interproExtDbName');
  my $downloadSiteDir = $self->getParamValue('downloadSiteDir');
  my $release = $self->getParamValue('release');
  my $project = $self->getParamValue('project');

  my $interproExtDbVer = $self->getExtDbVersion($test,$interproExtDb);

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);

  my $downloadFileName = "$websiteFilesDir/$downloadSiteDir/iprscan_$project-$release.txt";

  my $sql = <<"EOF";
SELECT ir.protein_source_id
           || chr(9) ||
         xd.name
           || chr(9) ||
         ir.INTERPRO_PRIMARY_ID
           || chr(9) ||
         ir.INTERPRO_SECONDARY_ID
           || chr(9) ||
         ir.INTERPRO_START_MIN
           || chr(9) ||
         ir.INTERPRO_END_MIN
           || chr(9) ||
         to_char(ir.INTERPRO_E_VALUE,'9.9EEEE')
  FROM
    apidb.interproresults ir,
    sres.externaldatabase xd
  WHERE
    xd.name = '$interproExtDb'
EOF

  if ($undo) {
      my $fileName = $downloadFileName."*";
    $self->runCmd($test, "rm $fileName");
  } else {
    $self->runCmd($test, "makeFileWithSql --outFile $downloadFileName --sql \"$sql\" --gusConfigFile $gusConfigFile");
    $self->runCmd($test, "gzip $downloadFileName");
  }
}


