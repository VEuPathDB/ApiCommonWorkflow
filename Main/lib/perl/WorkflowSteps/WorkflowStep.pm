package ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

########################################
## Super class for ApiDB workflow steps
########################################

@ISA = (ReFlow::Controller::WorkflowStepInvoker);

use strict;
use Carp;

use ReFlow::Controller::WorkflowStepInvoker;
use ApiCommonWorkflow::Main::Util::OrganismInfo;


# avoid using this subroutine!
# it is provided for backward compatibility.  plugins and commands that
# are called from the workflow should take an extDbRlsSpec as an argument,
# not an internal id
sub getExtDbRlsId {
  my ($self, $test, $extDbRlsSpec) = @_;

  die "'test' arg '$test' must be a 0 or 1" unless  ($test == 1 || $test == 0);

  my ($extDbName, $extDbRlsVer) = $self->getExtDbInfo($test,$extDbRlsSpec);

  my $sql = "select external_database_release_id from sres.externaldatabaserelease d, sres.externaldatabase x where x.name = '${extDbName}' and x.external_database_id = d.external_database_id and d.version = '${extDbRlsVer}'";

  my $cmd = "getValueFromTable --idSQL \"$sql\"";
  my $extDbRlsId = $self->runCmd($test, $cmd);

  if ($test) {
    return "UNKNOWN_EXT_DB_RLS_ID";
  } else {
    return  $extDbRlsId;
  }
}

sub getExtDbRlsId {
  my ($self, $test, $extDbRlsSpec) = @_;

  die "'test' arg '$test' must be a 0 or 1" unless  ($test == 1 || $test == 0);

  my ($extDbName, $extDbRlsVer) = $self->getExtDbInfo($test,$extDbRlsSpec);

  my $sql = "select external_database_release_id from sres.externaldatabaserelease d, sres.externaldatabase x where x.name = '${extDbName}' and x.external_database_id = d.external_database_id and d.version = '${extDbRlsVer}'";

  my $cmd = "getValueFromTable --idSQL \"$sql\"";
  my $extDbRlsId = $self->runCmd($test, $cmd);

  if ($test) {
    return "UNKNOWN_EXT_DB_RLS_ID";
  } else {
    return  $extDbRlsId;
  }
}

sub getExtDbVersion {
  my ($self, $test, $extDbName) = @_;

  die "'test' arg '$test' must be a 0 or 1" unless  ($test == 1 || $test == 0);

  my $sql = "select version from sres.externaldatabaserelease edr, sres.externaldatabase ed
             where ed.name = '$extDbName'
             and edr.external_database_id = ed.external_database_id";

  my $cmd = "getValueFromTable --idSQL \"$sql\"";
  my $extDbVer = $self->runCmd($test, $cmd);

  if ($test) {
    return "UNKNOWN_EXT_DB_VERSION";
  } else {
    $self->error("Error: trying to find unique ext db version for '$extDbName', but more than one found") if $extDbVer =~ /,/;   # found multiple rows
    return  $extDbVer;
  }
}

sub getExtDbInfo {
    my ($self,$test, $extDbRlsSpec) = @_;

  die "'test' arg '$test' must be a 0 or 1" unless  ($test == 1 || $test == 0);

    if ($test) {
      return ("UNKNOWN_DbName","UNKNOWN_DbVer");
    } elsif ($extDbRlsSpec =~ /(.+)\|(.+)/) {
      my $extDbName = $1;
      my $extDbRlsVer = $2;
      return ($extDbName, $extDbRlsVer);
    } else {
      $self->error("Database specifier '$extDbRlsSpec' is not in 'name|version' format");
    }
}

sub getTableId {
  my ($self, $test, $tableName) = @_;

  die "'test' arg '$test' must be a 0 or 1" unless  ($test == 1 || $test == 0);

  return "UNKNOWN_table_name" if $test;

  my $sql = "select table_id from core.tableinfo where name = '$tableName'";

  my $cmd = "getValueFromTable --idSQL \"$sql\"";
  my $tableId = $self->runCmd(0, $cmd);
  return  $tableId;
}

# this method is replaced by getOrganismInfo, and should be retired
# when all api workflows use organismAbbrev as key for an organism
sub getTaxonIdFromNcbiTaxId {
  my ($self, $test, $taxId) = @_;

  die "'test' arg '$test' must be a 0 or 1" unless  ($test == 1 || $test == 0);

  my $sql = "select taxon_id from sres.taxon where ncbi_tax_id = $taxId";

  my $cmd = "getValueFromTable --idSQL \"$sql\"";

  my $taxonId = $self->runCmd($test, $cmd);

  if ($test) {
    return "UNKNOWN_TAXON_ID";
  } else {
    return  $taxonId;
  }
}


sub getSoIds {
  my ($self,  $test,$soTermIdsOrNames) = @_;

  die "'test' arg '$test' must be a 0 or 1" unless  ($test == 1 || $test == 0);

  my ($soTermIds,$soTerms);

  if($soTermIdsOrNames =~ /SO:/){

      $soTermIds =  join(",", map { "'$_'" } split(',', $soTermIdsOrNames));
  }else{

      $soTerms =  join(",", map { "'$_'" } split(',', $soTermIdsOrNames));
  }

  my $sql = $soTermIds ? "select sequence_ontology_id from sres.sequenceontology where so_id IN (${soTermIds})" : "select sequence_ontology_id from sres.sequenceontology where term_name IN (${soTerms})";

  my $cmd = "getValueFromTable --idSQL \"$sql\"";

  my $soIds = $self->runCmd( $test,$cmd);

  return $soIds;
}


sub runPlugin {
    my ($self, $test, $undo, $plugin, $args) = @_;

    my $className = ref($self);

    if ($test != 1 && $test != 0) {
	$self->error("illegal 'test' arg passed to runPlugin() in step class '$className'");
    }

    if ($plugin !~ /\w+\:\:\w+/) {
	$self->error("illegal 'plugin' arg passed to runPlugin() in step class '$className'");
    }

    my $comment = $args;
    $comment =~ s/"/\\"/g;

    if ($self->{gusConfigFile}) {
      $args .= " --gusconfigfile $self->{gusConfigFile}";
    }

    my $commit = $args." --commit";

    my $cmd;
    my $undoPlugin = $self->getUndoPlugin($plugin);
    if ($undo) {
      my $algInvIds = $self->getAlgInvIds();
      if ($algInvIds) {    # may have been undone manually, so might not be any alg inv ids
	  if($commit =~ /undoTables/){
	      $cmd = "ga $undoPlugin --algInvocationId '$algInvIds' --workflowContext $commit";
	  }else {
	      $cmd = "ga $undoPlugin --algInvocationId '$algInvIds' --workflowContext --commit";
	  }
      } else {
	$self->log("No algorithm invocation IDs found for this plugin step.  The plugin must have been manually undone.  Exiting");
      }

    } else {
      $cmd = "ga $plugin --workflowstepid $self->{id} $commit --comment \"$comment\"";
    }
    my $msgForError=
"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Since this plugin step FAILED, please CLEAN UP THE DATABASE by calling:

  ga $undoPlugin --algInvocationId PLUGIN_ALG_INV_ID_HERE --workflowContext --commit

or (for the ISF plugin):
 
  ga GUS::Supported::Plugin::InsertSequenceFeaturesUndo --mapfile YOUR_ISF_MAP_FILE --algInvocationId PLUGIN_ALG_INV_ID_HERE --workflowContext --commit


Find the plugin's row_algorithm_invocation_id by looking above in this step log

(You need to do this cleanup EVEN IF the plugin did not write any data to *its*
tables.  ga most likely wrote to WorkflowStepAlgInvocation, and those rows
must be cleaned out.)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
";
    $self->runCmd($test, $cmd, $msgForError);
}

# individual steps can override this method if needed
# must return name of undo plugin and all args besides algInvocationId
sub getUndoPlugin{
  my ($self, $pluginClassName) = @_;

  return "GUS::Community::Plugin::Undo --plugin $pluginClassName";
}

sub getAlgInvIds {
  my ($self) = @_;
  my $sql = "
  select algorithm_invocation_id
  from apidb.WorkflowStepAlgInvocation
  where workflow_step_id = $self->{id}
";

  my $stmt = $self->runSql($sql);
  my @algInvIds;
  while (my @row = $stmt->fetchrow_array()) {
    push(@algInvIds, $row[0]);
  }
  return join(",", @algInvIds);
}

sub getOrganismInfo {
    my ($self, $test, $organismAbbrev) = @_;

    $self->error("The first argument to getOrganismInfo() must be \$test") unless $test == 0 || $test == 1;

    if (!$self->{organismInfo}->{$organismAbbrev}) {
	$self->{organismInfo}->{$organismAbbrev} =
	    ApiCommonWorkflow::Main::Util::OrganismInfo->new($self, $test, $organismAbbrev);
    }    
    return $self->{organismInfo}->{$organismAbbrev};
}


# the root directory that holds all website files.
# at EuPathDB this is apiSiteFiles/
# if in test mode, files go into test/ dir to keep separate from real files
sub getWebsiteFilesDir {
    my ($self, $test) = @_;

  die "'test' arg '$test' must be a 0 or 1" unless  ($test == 1 || $test == 0);

    my $websiteFilesDir = $self->getSharedConfig('websiteFilesDir');
    return $test? "$websiteFilesDir/test" : $websiteFilesDir;
}

# Oracle table names can be no longer than 30 characters
# instead of using the organismAbbrev for the prefix, we use the primary key of that organism in the organism table, ie, organism_id. 
# that should be no more than three characters. 4_char_prefix + 4_char_suffix --> table name <= 22 
# a table name must start w/ a letter, for example "p21_".
sub getTuningTablePrefix {
    my ($self, $organismAbbrev, $test) = @_;
    my $organismId = $self->getOrganismInfo($test, $organismAbbrev)->getOrganismId();
    return "P${organismId}_";
}

1;

