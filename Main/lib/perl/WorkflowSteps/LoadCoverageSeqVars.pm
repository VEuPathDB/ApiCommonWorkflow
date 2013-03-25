package ApiCommonWorkflow::Main::WorkflowSteps::LoadCoverageSeqVars;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $suffix = $self->getParamValue('suffix');

  my $gusInstance = $self->getGusInstanceName();
  my $gusLogin = $self->getGusDatabaseLogin();
  my $gusPassword = $self->getGusDatabasePassword();

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $ctlFile = "$workflowDataDir/covSeqVar.ctl";
  my $sqlldrLog = "$workflowDataDir/sqlldr.log";
  my $cmd = "sqlldr $gusLogin/$gusPassword\@$gusInstance data=$workflowDataDir/$inputFile control=$ctlFile log=$sqlldrLog rows=25000 direct=TRUE";

  if ($undo) {
    $self->runCmd(0, "rm -f $ctlFile");
  } else {
    if ($test) {
      $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
    }
    
    # run sqlldr (after writing its control file)
    writeControlFile($ctlFile, $suffix);
    $self->runCmd($test, $cmd);
  }
}

sub writeControlFile {
  my ($ctlFile, $suffix) = @_;

  open(CTL, ">$ctlFile") || die "Can't open '$ctlFile' for writing";
  print CTL <<"EOF";
     LOAD DATA
     INFILE *
     INTO TABLE DOTS.SeqVariation
     FIELDS TERMINATED BY " " OPTIONALLY ENCLOSED BY '"'
     TRAILING NULLCOLS
    (na_feature_id,na_sequence_id,subclass_view,name,sequence_ontology_id,parent_id,external_database_release_id,source_id,organism,strain,phenotype,product,allele,matches_reference,coverage,allele_percent,user_read,user_write,group_read,group_write,other_read,other_write,row_user_id,row_group_id,row_project_id,row_alg_invocation_id)
EOF

  close(CTL);
}
