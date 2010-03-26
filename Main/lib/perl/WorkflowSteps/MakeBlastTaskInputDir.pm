package ApiCommonWorkflow::Main::WorkflowSteps::MakeBlastTaskInputDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameter values
  my $taskInputDir = $self->getParamValue("taskInputDir");
  my $queryFile = $self->getParamValue("queryFile");
  my $subjectFile = $self->getParamValue("subjectFile");
  my $blastArgs = $self->getParamValue("blastArgs");
  my $idRegex = $self->getParamValue("idRegex");
  my $blastType = $self->getParamValue("blastType");
  my $vendor = $self->getParamValue("vendor");

  my $taskSize = $self->getConfig('taskSize');
  my $wuBlastBinPathCluster = $self->getConfig('wuBlastBinPathCluster');
  my $ncbiBlastBinPathCluster = $self->getConfig('ncbiBlastBinPathCluster');

  my $blastBinPathCluster = ($vendor eq 'ncbi')?  $ncbiBlastBinPathCluster : $wuBlastBinPathCluster;

  my $dbType = ($blastType =~ m/blastn|tblastx/i) ? 'n' : 'p';

  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
    $self->runCmd(0, "rm -rf $workflowDataDir/$taskInputDir/");
  }else {
      if ($test) {
	  $self->testInputFile('queryFile', "$workflowDataDir/$queryFile");
	  $self->testInputFile('subjectFile', "$workflowDataDir/$subjectFile");
      }

      $self->runCmd(0,"mkdir -p $workflowDataDir/$taskInputDir");

      # make controller.prop file
      $self->makeClusterControllerPropFile($taskInputDir, 2, $taskSize,
				       "DJob::DistribJobTasks::BlastSimilarityTask"); 
      # make task.prop file
      my $ccBlastParamsFile = "blastParams";
      my $localBlastParamsFile = "$workflowDataDir/$taskInputDir/blastParams";
      my $vendorString = $vendor? "blastVendor=$vendor" : "";

      my $taskPropFile = "$workflowDataDir/$taskInputDir/task.prop";
      open(F, ">$taskPropFile") || die "Can't open task prop file '$taskPropFile' for writing";

      print F
"blastBinDir=$blastBinPathCluster
dbFilePath=$clusterWorkflowDataDir/$subjectFile
inputFilePath=$clusterWorkflowDataDir/$queryFile
dbType=$dbType
regex='$idRegex'
blastProgram=$blastType
blastParamsFile=$ccBlastParamsFile
$vendorString
";
       close(F);

       # make blastParams file
       open(F, ">$localBlastParamsFile") || die "Can't open blast params file '$localBlastParamsFile' for writing";;
       print F "$blastArgs\n";
       close(F);
       #&runCmd($test, "chmod -R g+w $workflowDataDir/similarity/$queryName-$subjectName");
      
  }
}

sub getParamsDeclaration {
  return ('taskInputDir',
	  'queryFile',
	  'subjectFile',
	  'blastArgs',
	  'idRegex',
	  'blastType',
	  'vendor',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	  ['taskSize', "", ""],
	  ['wuBlastBinPathCluster', "", ""],
	  ['ncbiBlastBinPathCluster', "", ""],
	 );
}

