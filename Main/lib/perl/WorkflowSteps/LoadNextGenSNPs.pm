package ApiCommonWorkflow::Main::WorkflowSteps::LoadNextGenSNPs;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $sequenceVariationCtl = $self->getParamValue("sequenceVariationCtl");
  my $snpCtl = $self->getParamValue("snpCtl");
  my $sequenceVariationDat = $self->getParamValue("sequenceVariationDat");
  my $snpDat = $self->getParamValue("snpDat");
  my $loaderDir =  $self->getParamValue("loaderDir");

  my $snpExtDbRlsSpec = $self->getParamValue("snpExtDbRlsSpec");

  my $workflowDataDir = $self->getWorkflowDataDir();


  my $gusInstance = $self->getGusInstanceName();
  my $gusLogin = $self->getGusDatabaseLogin();
  my $gusPassword = $self->getGusDatabasePassword();

  my $snpSqlldrLog = "$workflowDataDir/$loaderDir/snp_sqlldr.log";
  my $varSqlldrLog = "$workflowDataDir/$loaderDir/var_sqlldr.log";

  my $snpCmd = "sqlldr $gusLogin/$gusPassword\@$gusInstance data=$workflowDataDir/$snpDat control=$workflowDataDir/$snpCtl log=$snpSqlldrLog rows=25000 direct=TRUE";
  my $varCmd = "sqlldr $gusLogin/$gusPassword\@$gusInstance data=$workflowDataDir/$sequenceVariationDat control=$workflowDataDir/$sequenceVariationCtl log=$varSqlldrLog rows=25000 direct=TRUE";

  # This command can also be used to clean up if this step fails part way through
  my $undoCommand = "undoNGSSNPLoader.pl --extdb_spec '$snpExtDbRlsSpec' --dbi_instance $gusInstance --dbi_user $gusLogin --dbi_pswd $gusPassword";

  if($undo) {
    $self->runCmd(0, $undoCommand);
    $self->runCmd(0, "rm -fr $workflowDataDir/$loaderDir/*.log");
    $self->runCmd(0, "rm -fr $workflowDataDir/$loaderDir/*.bad");
  } elsif($test) {
    $self->testInputFile('inputFile', "$workflowDataDir/$sequenceVariationCtl");
    $self->testInputFile('inputFile', "$workflowDataDir/$snpCtl");
    $self->testInputFile('inputFile', "$workflowDataDir/$sequenceVariationDat");
    $self->testInputFile('inputFile', "$workflowDataDir/$snpDat");
  } else{
      $self->runCmd($test, $snpCmd);
      $self->runCmd($test, $varCmd);
  }
}

sub getConfigDeclaration {
  return (
         # [name, default, description]
         # ['', '', ''],
         );
}
