package ApiCommonWorkflow::Main::WorkflowSteps::FindOrthomclPairs;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use OrthoMCLEngine::Main::Base;


sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $suffix = $self->getParamValue('suffix');


  my $configFile = "$workflowDataDir/orthomclPairs.config";
  my $logfile = "$workflowDataDir/orthomclPairs.log";

  my $cmd = "orthomclPairs $configFile $logfile cleanup=no suffix=$suffix";

  if ($undo) {
    my $base = OrthoMCLEngine::Main::Base->new($configFile);

    my $inParalogTable = $base->getConfig("inParalogTable") . $suffix;
    my $orthologTable = $base->getConfig("orthologTable") . $suffix;
    my $coOrthologTable = $base->getConfig("coOrthologTable") . $suffix;

    $self->runCmd($test, "executeIdSQL.pl --idSQL \"truncate table $inParalogTable\" ");
    $self->runCmd($test, "executeIdSQL.pl --idSQL \"truncate table $orthologTable\" ");
    $self->runCmd($test, "executeIdSQL.pl --idSQL \"truncate table $coOrthologTable\" ");

    $self->runCmd($test, "executeIdSQL.pl --idSQL \"drop table BestHit$suffix\" ");
    $self->runCmd($test, "executeIdSQL.pl --idSQL \"drop table BestInterTaxonScore$suffix\" ");
    $self->runCmd($test, "executeIdSQL.pl --idSQL \"drop table BestQueryTaxonScore$suffix\" ");
    $self->runCmd($test, "executeIdSQL.pl --idSQL \"drop table BetterHit$suffix\" ");
    $self->runCmd($test, "executeIdSQL.pl --idSQL \"drop table CoOrthologAvgScore$suffix\" ");
    $self->runCmd($test, "executeIdSQL.pl --idSQL \"drop table CoOrthologCandidate$suffix\" ");
    $self->runCmd($test, "executeIdSQL.pl --idSQL \"drop table CoOrthologNotOrtholog$suffix\" ");
    $self->runCmd($test, "executeIdSQL.pl --idSQL \"drop table CoOrthologTaxon$suffix\" ");
    $self->runCmd($test, "executeIdSQL.pl --idSQL \"drop table CoOrthologTemp$suffix\" ");
    $self->runCmd($test, "executeIdSQL.pl --idSQL \"drop table InParalog2Way$suffix\" ");
    $self->runCmd($test, "executeIdSQL.pl --idSQL \"drop table InParalogAvgScore$suffix\" ");
    $self->runCmd($test, "executeIdSQL.pl --idSQL \"drop table InplgOrthoInplg$suffix\" ");
    $self->runCmd($test, "executeIdSQL.pl --idSQL \"drop table InParalogOrtholog$suffix\" ");
    $self->runCmd($test, "executeIdSQL.pl --idSQL \"drop table InplgOrthTaxonAvg$suffix\" ");
    $self->runCmd($test, "executeIdSQL.pl --idSQL \"drop table InParalogTaxonAvg$suffix\" ");
    $self->runCmd($test, "executeIdSQL.pl --idSQL \"drop table InParalogTemp$suffix\" ");
    $self->runCmd($test, "executeIdSQL.pl --idSQL \"drop table Ortholog2Way$suffix\" ");
    $self->runCmd($test, "executeIdSQL.pl --idSQL \"drop table OrthologAvgScore$suffix\" ");
    $self->runCmd($test, "executeIdSQL.pl --idSQL \"drop table OrthologTaxon$suffix\" ");
    $self->runCmd($test, "executeIdSQL.pl --idSQL \"drop table OrthologTemp$suffix\" ");
    $self->runCmd($test, "executeIdSQL.pl --idSQL \"drop table OrthologUniqueId$suffix\" ");
    $self->runCmd($test, "executeIdSQL.pl --idSQL \"drop table UniqueSimSeqsQueryId$suffix\" ");

    $self->runCmd(0, "rm -f $logfile");
  } else {
      if ($test) {
	  $self->runCmd(0,"echo test > $logfile");
      }

      $self->runCmd($test,$cmd);
  }
}
