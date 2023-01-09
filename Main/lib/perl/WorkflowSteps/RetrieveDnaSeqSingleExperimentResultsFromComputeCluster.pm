package ApiCommonWorkflow::Main::RetrieveDnaSeqSingleExperimentResultsFromComputeCluster;

@ISA = (ReFlow::Controller::WorkflowStepHandle);

use strict;
use warnings;
use ReFlow::Controller::WorkflowStepHandle;
use File::Basename;

sub run {
  my ($self, $test, $undo) = @_;

  my $clusterDir = join("/", $self->getClusterWorkflowDataDir(), $self->getParamValue("clusterDir"));
  my $targetDir = join("/", $self->getWorkflowDataDir(), $self->getParamValue("targetDir"));

  my $bam = ".bam";
  my $concatvcfgz = ".concat.vcf.gz";
  my $indeltsv = ".indel.tsv";
  my $resultvcfgz = "result.vcf.gz";
  my $bambai = ".bam.bai";
  my $concatvcfgztbi = ".concat.vcf.gz.tbi";  
  my $pileup = ".result.pileup";
  my $resultvcfgztbi = "result.vcf.gz.tbi";
  my $bigwig = ".bw";
  my $consensus = "consensus.fa.gz";
  my $varscan = ".varscan.cons.gz";

  if($undo){
    for my $fileName ($bam, $concatvcfgz, $indeltsv, $resultvcfgz, $bambai, $concatvcfgztbi, $pileup, $resultvcfgztbi, $bigwig, $consensus, $varscan){
      $self->runCmd(0, "rm -f $targetDir/*$fileName");
    }
    $self->runCmd(0, "rm -rf $targetDir/CNVs");
  }else {
    if ($test) {
      for my $fileName ($bam, $concatvcfgz, $indeltsv, $resultvcfgz, $bambai, $concatvcfgztbi, $pileup, $resultvcfgztbi, $bigwig, $consensus, $varscan){
        $self->runCmd(0, "echo test > $targetDir/test$fileName");
      }
    } else {
      my $tmp = "$targetDir/tmp." . int(rand(10000));
      $self->runCmd(0, "mkdir $tmp");
      for my $fileName ($bam, $concatvcfgz, $indeltsv, $resultvcfgz, $bambai, $concatvcfgztbi, $pileup, $resultvcfgztbi, $bigwig, $consensus, $varscan){
        $self->copyFromCluster("$clusterDir", "*$fileName", $tmp, 0);
      }
      $self->copyFromCluster("$clusterDir", "CNVs/*", $tmp, 0);
      $self->runCmd(0, "mv $tmp/* $targetDir");   
      $self->runCmd(0, "rmdir $tmp");
    }
  }

}

sub getParamDeclaration {
  return (
	"clusterDir",
	"targetDir",
	"otuCountsFileName",
	"pathwayAbundancesFileName",
	"pathwayCoveragesFileName",
	"level4ECsFileName",
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}
1;
