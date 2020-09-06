package ApiCommonWorkflow::Main::WorkflowSteps::MakeHisat2TaskInputDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use File::Basename;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameter values
  my $readFilePath = $self->getParamValue("readFilePath");
  my $hasPairedEnds = $self->getBooleanParamValue("hasPairedEnds");
  my $taskInputDir = $self->getParamValue("taskInputDir");
  my $strandSpecific = $self->getParamValue("strandSpecific");
  my $keepNode = $self->getParamValue("keepNode");
  my $createJunctionsFile = $self->getParamValue("createJunctionsFile");
  my $maskFile = $self->getParamValue("maskFile");
  my $topLevelGeneFootprintFile = $self->getParamValue("topLevelGeneFootprintFile");
  my $topLevelFastaFile = $self->getParamValue("topLevelFastaFile");
  my $hisatIndex = $self->getParamValue("hisatIndex");
  my $hisatDirectory = $self->getParamValue("hisatDirectory");
  my $quantify = $self->getParamValue("quantify");
  my $writeCovFiles = $self->getParamValue("writeCovFiles");
  my $clusterServer = $self->getSharedConfig('clusterServer');
  my $taskSize = $self->getConfig("taskSize");
  my $sraQueryString = $self->getParamValue("sraQueryString");


  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $workflowDataDir = $self->getWorkflowDataDir();


  if ($undo) {
    $self->runCmd(0, "rm -rf $workflowDataDir/$taskInputDir/");
  }else {
      $self->error("Declared input file '$workflowDataDir/$readFilePath' for param 'readFilePath' does not exist") if (!length($sraQueryString)>0 && !-e "$workflowDataDir/$readFilePath" && !-e "$workflowDataDir/$readFilePath.gz");

      $self->runCmd(0,"mkdir -p $workflowDataDir/$taskInputDir");

      # make controller.prop file
      $self->makeDistribJobControllerPropFile($taskInputDir, 1, $taskSize,
				       "DJob::DistribJobTasks::Hisat2Task", $keepNode); 
      # make task.prop file

      my $dir = dirname($topLevelGeneFootprintFile);
      open(INTRON, "$workflowDataDir/$dir/maxIntronLen") or die "Cannot read max intron len from $workflowDataDir/$dir/maxIntronLen\n$!\n";
      my @lines;
      while (my $line = <INTRON>) {
        chomp $line;
        push (@lines,  $line);
      }
      if (scalar @lines != 1) {
        die "File $workflowDataDir/$dir/maxIntronLen should only contain one line\n";
      }
      my $maxIntronLen = @lines[0];
      
      my $taskPropFile = "$workflowDataDir/$taskInputDir/task.prop";
      open(F, ">$taskPropFile") || die "Can't open task prop file '$taskPropFile' for writing";

      my $taskPropFileContent="
genomeDatabase=$clusterWorkflowDataDir/$hisatDirectory/$hisatIndex
maskFile=$clusterWorkflowDataDir/$hisatDirectory/$maskFile
quantify=$quantify
writeCovFiles=$writeCovFiles
isStrandSpecific=$strandSpecific
quantifyJunctions=$createJunctionsFile
topLevelGeneFootprintFile=$clusterWorkflowDataDir/$topLevelGeneFootprintFile
hasPairedEnds=$hasPairedEnds
ppn=4
maxIntronLen=$maxIntronLen
";


    if(length($sraQueryString)>0){
      $taskPropFileContent .= "mateA=none\n";
      $taskPropFileContent .= "mateB=none\n";
      $taskPropFileContent .= "sraSampleIdQueryList=$sraQueryString\n";
      
    }else {
      $taskPropFileContent .= "mateA=$clusterWorkflowDataDir/$readFilePath\n";
      $taskPropFileContent .= "sraSampleIdQueryList=none\n";
      if($hasPairedEnds){
        $taskPropFileContent .= "mateB=$clusterWorkflowDataDir/$readFilePath.paired\n";
      }else {
        $taskPropFileContent .= "mateB=none\n";
      }
    }

      print F "$taskPropFileContent\n";
       close(F);
  }
}

1;


