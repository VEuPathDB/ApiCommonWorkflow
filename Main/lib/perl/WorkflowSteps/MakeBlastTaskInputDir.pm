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
  my $makeSimSeqsFile = $self->getParamValue("makeSimSeqsFile");

  $self->error("Vendor must be either 'ncbi' or 'wu'") unless ($vendor eq 'ncbi' || $vendor eq 'wu');

  my $clusterServer = $self->getSharedConfig('clusterServer');
  my $taskSize = $self->getConfig("taskSize");
  my $dbType = ($blastType =~ m/blastn|tblastx/i) ? 'n' : 'p';

  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cpus = 1;  # this should not be hard coded
  my $cpusArg = $vendor eq 'ncbi'? '-a ' : '-cpus=';
  $self->error("Please do not include the '$cpusArg' option in the blastArgs parameter.  It is taken care of automatically") if $blastArgs =~ /$cpusArg/;

  if ($undo) {
    $self->runCmd(0, "rm -rf $workflowDataDir/$taskInputDir/");
  }else {

	  $self->testInputFile('queryFile', "$workflowDataDir/$queryFile");
	  $self->testInputFile('subjectFile', "$workflowDataDir/$subjectFile");


      $self->runCmd(0,"mkdir -p $workflowDataDir/$taskInputDir");

      # make controller.prop file
      $self->makeDistribJobControllerPropFile($taskInputDir, $cpus, $taskSize,
				       "DJob::DistribJobTasks::BlastSimilarityTask"); 
      # make task.prop file
      my $ccBlastParamsFile = "blastParams";
      my $localBlastParamsFile = "$workflowDataDir/$taskInputDir/blastParams";
      my $vendorString = $vendor? "blastVendor=$vendor" : "";
      my $simSeqs = $makeSimSeqsFile ? "printSimSeqsFile=yes" : "";

      my $taskPropFile = "$workflowDataDir/$taskInputDir/task.prop";
      open(F, ">$taskPropFile") || die "Can't open task prop file '$taskPropFile' for writing";

      print F
"dbFilePath=$clusterWorkflowDataDir/$subjectFile
inputFilePath=$clusterWorkflowDataDir/$queryFile
dbType=$dbType
regex='$idRegex'
blastProgram=$blastType
blastParamsFile=$ccBlastParamsFile
$vendorString
$simSeqs
";
       close(F);

       # make blastParams file
       open(F, ">$localBlastParamsFile") || die "Can't open blast params file '$localBlastParamsFile' for writing";;
       print F "$cpusArg$cpus $blastArgs\n";
       close(F);
       #&runCmd($test, "chmod -R g+w $workflowDataDir/similarity/$queryName-$subjectName");
      
  }
}

1;
