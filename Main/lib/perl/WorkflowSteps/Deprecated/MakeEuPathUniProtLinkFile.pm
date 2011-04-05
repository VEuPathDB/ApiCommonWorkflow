package ApiCommonWorkflow::Main::WorkflowSteps::MakeEuPathUniProtLinkFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $outputFile = $self->getParamValue('outputFile');
  my $dbrefExtDbRlsSpec = $self->getParamValue('dbrefExtDbRlsSpec');
  my $projectName = $self->getParamValue('projectName');
  my $apiSiteFilesDir = $self->getSharedConfig('apiSiteFilesDir');

  my $cmd; 
 if ($dbrefExtDbRlsSpec =~ /\|/)
{

  my $cmd = "dumpEuPath-UniProtLinks --dbrefExtDbSpec '$dbrefExtDbRlsSpec' --outfile $outputFile --projectName $projectName";

}else{
  my $cmd = "dumpEuPath-UniProtLinks --dbrefExtDbName '$dbrefExtDbRlsSpec' --outfile $outputFile --projectName $projectName";
}

  if ($undo) {
    $self->runCmd(0, "rm -f $apiSiteFilesDir/$outputFile");
  } else {
      if ($test) {
	  $self->runCmd(0,"echo test > $apiSiteFilesDir/$outputFile");
      }else{
	  $self->runCmd($test,$cmd);
      }
  }
}

sub getParamsDeclaration {
  return (
          'outputFile',
          'genomeDbRls',
         );
}

sub getConfigDeclaration {
  return (
         # [name, default, description]
         # ['', '', ''],
         );
}


