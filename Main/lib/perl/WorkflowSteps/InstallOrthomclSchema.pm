package ApiCommonWorkflow::Main::WorkflowSteps::InstallOrthomclSchema;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $confFile = $self->getParamValue('configFile');
  my $suffix = $self->getParamValue('suffix');

  my $gusInstance = $self->getGusInstanceName();
  my $gusLogin = $self->getGusDatabaseLogin();
  my $gusPassword = $self->getGusDatabasePassword();

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $configFile = "$workflowDataDir/$confFile";

  if ($undo) {
    $self->runCmd($test, "orthomclDropSchema $configFile orthomclDropSchema.log $suffix");
    $self->runCmd(0, "rm -f $configFile");

  } else {

      # make OrthoMCL config file
      writeConfigFile($configFile, $gusInstance, $gusLogin, $gusPassword);

      # create tables
      $self->runCmd($test, "orthomclInstallSchema $configFile orthomclInstallSchema.log $suffix");
  }
}

sub writeConfigFile {
  my ($configFile, $instance, $login, $password) = @_;

  my $dsn = "dbi:Oracle:$instance";
  open(CONFIG, ">$configFile") || die "Can't open '$configFile' for writing";
  print CONFIG <<"EOF";
dbConnectString=$dsn
dbLogin=$login
dbPassword=$password
dbVendor=oracle
similarSequencesTable=apidb.SimilarSequences
orthologTable=apidb.Ortholog
inParalogTable=apidb.InParalog
coOrthologTable=apidb.CoOrtholog
interTaxonMatchView=apidb.InterTaxonMatch
oracleIndexTablespace=indx
percentMatchCutoff=50
evalueExponentCutoff=-5
EOF

  close(CONFIG);
}

1;
