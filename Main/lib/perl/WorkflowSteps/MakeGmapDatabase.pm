package ApiCommonWorkflow::Main::WorkflowSteps::MakeGmapDatabase;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

use File::Basename;

sub run{
    my ($self, $test, $undo) = @_;

    my $workflowDataDir = $self->getWorkflowDataDir();

    my $organismAbbrev = $self->getParamValue("organismAbbrev");
    my $gsnapDir = $self->getParamValue("gsnapDir");
    my $databaseName = $self->getParamValue("databaseName");
    my $fastaFile = $self->getParamValue("fastaFile");

    my $gmapFullPath = `which gmap_build`;
    my $binDir = dirname $gmapFullPath;

    my $cmd_replace1 = "cat $workflowDataDir/$fastaFile | perl -pe 'unless (/^>/){s/[^ACGTNX]/N/g;}' > $workflowDataDir/$fastaFile.StandardUpperCase";
    my $cmd_replace2 = "cat $workflowDataDir/$fastaFile.StandardUpperCase | perl -pe 'unless (/^>/){s/[^ACGTNXacgtnx]/n/g;}' > $workflowDataDir/$fastaFile.StandardLowerCase";

    my $cmd = "gmap_build -d $databaseName -D $workflowDataDir/$gsnapDir $workflowDataDir/$fastaFile.StandardLowerCase -B $binDir";
    
    if ($undo) {
        $self->runCmd(0, "rm -r $workflowDataDir/$gsnapDir/$databaseName");
        $self->runCmd(0, "rm -f $workflowDataDir/$fastaFile.StandardUpperCase");
        $self->runCmd(0, "rm -f $workflowDataDir/$fastaFile.StandardLowerCase");
    }else{
          $self->runCmd($test,$cmd_replace1);
          $self->runCmd($test,$cmd_replace2);
          $self->runCmd($test, $cmd);
    }
}

1;
