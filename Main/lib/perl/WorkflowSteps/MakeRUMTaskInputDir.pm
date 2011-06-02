package ApiCommonWorkflow::Main::WorkflowSteps::MakeRUMTaskInputDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameter values
  my $readFilePath = $self->getParamValue("readFilePath");
  my $genomeFastaFile = $self->getParamValue("genomeFastaFile");
  my $genomeBowtieIndex = $self->getParamValue("genomeBowtieIndex");
  my $transcriptBowtieIndex = $self->getParamValue("transcriptBowtieIndex");
  my $geneAnnotationFile = $self->getParamValue("geneAnnotationFile");
  my $transcriptFastaFile = $self->getParamValue("transcriptFastaFile");
  my $pairedReadFilePath = $self->getParamValue("pairedReadFilePath");
  my $limitNU = $self->getParamValue("limitNU");
  my $numInsertions = $self->getParamValue("numInsertions");
  my $createSAMFile = $self->getParamValue("createSAMFile");
  my $countMismatches = $self->getParamValue("countMismatches");
  my $taskInputDir = $self->getParamValue("taskInputDir");
  my $strandSpecific = $self->getParamValue("strandSpecific");
  my $SNPS = $self->getParamValue("SNPs");
  my $keepNode = $self->getParamValue("keepNode");

  my $taskSize = $self->getConfig('taskSize');
  my $bowtieBinDir = $self->getConfig('bowtieBinDir');
  my $blatExec = $self->getConfig('blatExec');
  my $mdustExec = $self->getConfig('mdustExec');
  my $perlScriptsDir = $self->getConfig('perlScriptsDir');

  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
    $self->runCmd(0, "rm -rf $workflowDataDir/$taskInputDir/");
  }else {
      if ($test) {
	  $self->testInputFile('readFilePath', "$workflowDataDir/$readFilePath");
	  $self->testInputFile('genomeFastaFile', "$workflowDataDir/$genomeFastaFile");
	  $self->testInputFile('geneAnnotationFile', "$workflowDataDir/$geneAnnotationFile");
      }

      $self->runCmd(0,"mkdir -p $workflowDataDir/$taskInputDir");

      # make controller.prop file
      $self->makeClusterControllerPropFile($taskInputDir, 1, $taskSize,
				       "DJob::DistribJobTasks::RUMTask", $keepNode); 
      # make task.prop file
      my $taskPropFile = "$workflowDataDir/$taskInputDir/task.prop";
      open(F, ">$taskPropFile") || die "Can't open task prop file '$taskPropFile' for writing";

      my $taskPropFileContent="
readFilePath=$clusterWorkflowDataDir/$readFilePath
genomeFastaFile=$clusterWorkflowDataDir/$genomeFastaFile
geneAnnotationFile=$clusterWorkflowDataDir/$geneAnnotationFile 
bowtieBinDir=$bowtieBinDir
blatExec=$blatExec
mdustExec=$mdustExec
perlScriptsDir=$perlScriptsDir
limitNU=$limitNU
numInsertions=$numInsertions
minBlatIdentity=93
createSAMFile=$createSAMFile
countMismatches=$countMismatches
";

      $taskPropFileContent .= "pairedReadFilePath=$clusterWorkflowDataDir/$pairedReadFilePath\n" if $pairedReadFilePath;
      $taskPropFileContent .= "transcriptFastaFile=$clusterWorkflowDataDir/$transcriptFastaFile\n" if $transcriptFastaFile;
      $taskPropFileContent .= "transcriptBowtieIndex=$clusterWorkflowDataDir/$transcriptBowtieIndex\n" if $transcriptBowtieIndex;
      $taskPropFileContent .= "genomeBowtieIndex=$clusterWorkflowDataDir/$genomeBowtieIndex\n" if $genomeBowtieIndex;
      $taskPropFileContent .= "strandSpecific=$strandSpecific\n" if $strandSpecific;
      $taskPropFileContent .= "SNPs=$SNPS\n" if $SNPs;
      print F "$taskPropFileContent\n";
       close(F);
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
	 );
}

