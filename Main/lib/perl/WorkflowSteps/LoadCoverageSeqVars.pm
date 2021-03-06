package ApiCommonWorkflow::Main::WorkflowSteps::LoadCoverageSeqVars;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $controlFileDir = $self->getParamValue('controlFileDir');

  my $gusInstance = $self->getGusInstanceName();
  my $gusLogin = $self->getGusDatabaseLogin();
  my $gusPassword = $self->getGusDatabasePassword();

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $ctlFile = "$workflowDataDir/$controlFileDir/covSeqVar.ctl";
  my $sqlldrLog = "$workflowDataDir/$controlFileDir/sqlldr.log";
  my $cmd = "sqlldr $gusLogin/$gusPassword\@$gusInstance data=$workflowDataDir/$inputFile control=$ctlFile log=$sqlldrLog rows=25000 direct=TRUE";

  if ($undo) {
    $self->runCmd(0, "rm -f $ctlFile");
    $self->runCmd(0, "rm -f $sqlldrLog");
  } else {

    $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
    
    # run sqlldr (after writing its control file)
    writeControlFile($ctlFile);
    $self->runCmd($test, $cmd);
  }
}

sub writeControlFile {
  my ($ctlFile) = @_;

  open(CTL, ">$ctlFile") || die "Can't open '$ctlFile' for writing";
  print CTL <<"EOF";
     LOAD DATA
     INFILE *
     INTO TABLE DOTS.NaFeatureImp
     APPEND
     FIELDS TERMINATED BY " " OPTIONALLY ENCLOSED BY "'"
     TRAILING NULLCOLS
    (na_sequence_id,subclass_view,name,sequence_ontology_id,parent_id,external_database_release_id,source_id,string8,string9,string11,string12,string18,number2,number3,float2,user_read,user_write,group_read,group_write,other_read,other_write,row_user_id,row_group_id,row_project_id,row_alg_invocation_id, na_feature_id SEQUENCE(MAX,1), modification_date "SYSDATE")

EOF

  close(CTL);
}

1;
