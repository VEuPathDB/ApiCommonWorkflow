package ApiCommonWorkflow::Main::WorkflowSteps::MakeDnaSeqMergeExperimentsNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use GUS::ObjRelP::DbiDatabase;
use GUS::Supported::GusConfig;
use CBIL::Util::PropertySet;

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $inputDir = join("/", $workflowDataDir, $self->getParamValue("inputDir")); 
  my $outputDir = join("/", $workflowDataDir, $self->getParamValue("outputDir")); 
  my $configFileName = $self->getParamValue("configFileName");
  my $configPath = join("/", $workflowDataDir,  $self->getParamValue("analysisDir"), $self->getParamValue("configFileName"));
  my $gtfFile = join("/", $workflowDataDir, $self->getParamValue("gtfFile"));
  my $genomeFastaFile = join("/", $workflowDataDir, $self->getParamValue("genomeFastaFile"));
  my $organismAbbrev = $self->getParamValue("organismAbbrev");
  my $cacheFile = $self->getParamValue("cacheFile");
  my $cacheFileDir = $self->getParamValue("cacheFileDir");
  my $undoneStrainsFile = $self->getParamValue("undoneStrainsFile");
  my $varscanDirectory = join("/", $workflowDataDir, $self->getParamValue("varscanDirectory"));
  my $varscanFilePath = join("/", $workflowDataDir, $self->getParamValue("varscanFilePath"));
  my $webServicesDir = join("/", $workflowDataDir,  $self->getParamValue("analysisDir"), $self->getParamValue("webServicesDir"));
  my $extDbRlsSpec = $self->getParamValue("extDbRlsSpec");
  
  my $gusConfigFile = $ENV{GUS_HOME}."/config/gus.config";
  die "Config file $gusConfigFile does not exist" unless -e $gusConfigFile;

  my @properties = ();
  my $gusConfig = CBIL::Util::PropertySet -> new ($gusConfigFile, \@properties, 1);

  my $referenceSql = "select REF_STRAIN_ABBREV from apidb.organism where abbrev = '$organismAbbrev'";

  my $db = GUS::ObjRelP::DbiDatabase-> new($gusConfig->{props}->{dbiDsn},
                                           $gusConfig->{props}->{databaseLogin},
                                           $gusConfig->{props}->{databasePassword},
                                         0,0,1, # verbose, no insert, default                                                                                                                              
                                           $gusConfig->{props}->{coreSchemaName});

  my $dbh = $db->getQueryHandle();

  my $referenceStmt = $dbh->prepare($referenceSql);
  $referenceStmt->execute();

    my $referenceStrain;

  while (my @row = $referenceStmt->fetchrow_array()){
      $referenceStrain = $row[0];
  }

  if ($undo) {
    $self->runCmd(0,"rm -rf $configPath");
  } else {
    open(F, ">", $configPath) or die "$! :Can't open config file '$configPath' for writing";

    print F
"
params {

  inputDir = \"$inputDir\"
  outputDir = \"$outputDir\"
  gusConfig = \"\$GUS_HOME/config/gus.config\"
  cacheFile = \"$cacheFileDir/$cacheFile\"
  cacheFileDir = \"$cacheFileDir\"
  undoneStrains = \"$undoneStrainsFile\"
  organism_abbrev = \'$organismAbbrev\' 
  reference_strain = \'$referenceStrain\'
  varscan_directory = \"$varscanDirectory\"
  genomeFastaFile = \"$genomeFastaFile\"
  gtfFile = \"$gtfFile\"
  varscanFilePath = \"$varscanFilePath\"
  webServicesDir = \"$webServicesDir\"
  extDbRlsSpec = '$extDbRlsSpec'

}

singularity {
  enabled = true
  autoMounts = true
}
";
  close(F);
 }
}

1;

