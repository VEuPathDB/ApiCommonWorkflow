package ApiCommonWorkflow::Main::WorkflowSteps::CheckForApiDBOrganism;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use GUS::ObjRelP::DbiDatabase;
use GUS::Supported::GusConfig;

sub run {
  my ($self, $test, $undo) = @_;

  # standard parameters for making website files
  my $taxonId = $self->getParamValue('taxonId');
  my $skipIfFile = $self->getParamValue('skipIfFile');
  my $gusConfigFile = $self->getParamValue('gusConfigFile');
  $gusConfigFile = $self->getWorkflowDataDir() . "/$gusConfigFile";
  $skipIfFile = $self->getWorkflowDataDir() . "/$skipIfFile";

  die "Config file $gusConfigFile does not exist" unless -e $gusConfigFile;

  my @properties = ();
  my $gusConfig = CBIL::Util::PropertySet -> new ($gusConfigFile, \@properties, 1);

  my $sql = "select taxon_id from apidb.organism where taxon_id = $taxonId";

  my $db = GUS::ObjRelP::DbiDatabase-> new($gusConfig->{props}->{dbiDsn},
                                           $gusConfig->{props}->{databaseLogin},
                                           $gusConfig->{props}->{databasePassword},
                                           0,0,1, # verbose, no insert, default
                                           $gusConfig->{props}->{coreSchemaName});

  my $dbh = $db->getQueryHandle();

  my $stmt = $dbh->prepare($sql);
  $stmt->execute();

  my $taxonFound = 0;

  while (my @row = $stmt->fetchrow_array()){
      if($row[0]) {
          $taxonFound = 1;
      }
  }

  if($undo){
    $self->runCmd(0, "rm -f $skipIfFile") if -e $skipIfFile;
  }
  else {
      if ($test) {
          if ($taxonFound == 1) {
	      $self->runCmd(0, "echo test > $skipIfFile ");
          }
      }
      else {
          if ($taxonFound == 1) {
	      $self->runCmd(0, "echo test > $skipIfFile ");
          }
      }
  }
}

1;

