package ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

########################################
## Super class for ApiDB workflow steps
########################################

@ISA = (ReFlow::Controller::WorkflowStepInvoker);

use strict;
use Carp;

use ReFlow::Controller::WorkflowStepInvoker;
use CBIL::Util::SshCluster;
use ApiCommonWorkflow::Main::Util::OrganismInfo;


sub getComputeClusterHomeDir {
    my ($self) = @_;
    my $clusterBase = $self->getSharedConfig('clusterBaseDir');
    my $workflowName = $self->getWorkflowConfig('name');
    my $workflowVersion = $self->getWorkflowConfig('version');
    return "$clusterBase/$workflowName/$workflowVersion";
}

sub getClusterWorkflowDataDir {
    my ($self) = @_;
    my $home = $self->getComputeClusterHomeDir();
    return "$home/data";
}

sub getComputeClusterTaskLogsDir {
    my ($self) = @_;
    my $home = $self->getComputeClusterHomeDir();
    return "$home/taskLogs";
}

sub makeClusterControllerPropFile {
  my ($self, $taskInputDir, $slotsPerNode, $taskSize, $taskClass) = @_;

  my $nodePath = $self->getSharedConfig('nodePath');
  my $nodeClass = $self->getSharedConfig('nodeClass');

  # tweak inputs
  my $masterDir = $taskInputDir;
  $masterDir =~ s/input/master/;
  $nodeClass = 'DJob::DistribJob::BprocNode' unless $nodeClass;

  # get configuration values
  my $nodePath = $self->getSharedConfig('nodePath');
  my $nodeClass = $self->getSharedConfig('nodeClass');

  # construct dir paths
  my $workflowDataDir = $self->getWorkflowDataDir();
  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();

  # print out the file
  my $controllerPropFile = "$workflowDataDir/$taskInputDir/controller.prop";
  open(F, ">$controllerPropFile")
      || $self->error("Can't open controller prop file '$controllerPropFile' for writing");
  print F 
"masterdir=$clusterWorkflowDataDir/$masterDir
inputdir=$clusterWorkflowDataDir/$taskInputDir
nodedir=$nodePath
slotspernode=$slotsPerNode
subtasksize=$taskSize
taskclass=$taskClass
nodeclass=$nodeClass
restart=no
";
    close(F);
}

# avoid using this subroutine!
# it is provided for backward compatibility.  plugins and commands that
# are called from the workflow should take an extDbRlsSpec as an argument,
# not an internal id
sub getExtDbRlsId {
  my ($self, $test, $extDbRlsSpec) = @_;

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

sub getExtDbInfo {
    my ($self,$test, $extDbRlsSpec) = @_;

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
  my ($self, $tableName) = @_;
  my $sql = "select table_id from core.tableinfo where name = '$tableName'";

  my $cmd = "getValueFromTable --idSQL \"$sql\"";
  my $tableId = $self->runCmd(0, $cmd);
  return  $tableId;
}

# this method is replaced by getOrganismInfo, and should be retired
# when all api workflows use organismAbbrev as key for an organism
sub getTaxonIdFromNcbiTaxId {
  my ($self, $test, $taxId) = @_;

  my $sql = "select taxon_id from sres.taxon where ncbi_tax_id = $taxId";

  my $cmd = "getValueFromTable --idSQL \"$sql\"";

  my $taxonId = $self->runCmd($test, $cmd);

  if ($test) {
    return "UNKNOWN_TAXON_ID";
  } else {
    return  $taxonId;
  }
}

# this method is replaced by getOrganismInfo, and should be retired
# when all api workflows use organismAbbrev as key for an organism
sub getTaxonIdList {
  my ($self, $test, $taxonId, $hierarchy) = @_;

  if ($hierarchy) {
    my $idList = $self->runCmd($test, "getSubTaxaList --taxon_id $taxonId");
    if ($test) {
      return "UNKNOWN_TAXON_ID_LIST";
    } else {
      chomp($idList);
      return  $idList;
    }
  } else {
    return $taxonId;
  }
}


sub getSoIds {
  my ($self,  $test,$soTermIdsOrNames) = @_;

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
    if ($undo) {
      my $undoPlugin = $self->getUndoPlugin($plugin);
      my $algInvIds = $self->getAlgInvIds();
      if($commit =~ /undoTables/){
	  $cmd = "ga $undoPlugin --algInvocationId '$algInvIds' --workflowContext $commit";
      }else {
	  $cmd = "ga $undoPlugin --algInvocationId '$algInvIds' --workflowContext --commit";
      }

    } else {
      $cmd = "ga $plugin --workflowstepid $self->{id} $commit --comment \"$comment\"";
    }
    $self->runCmd($test, $cmd);
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

    my $websiteFilesDir = $self->getSharedConfig('websiteFilesDir');
    return $test? "$websiteFilesDir/test" : $websiteFilesDir;
}

1;

