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

    my $cmd = "gmap_build -d $databaseName -D $workflowDataDir/$gsnapDir $workflowDataDir/$fastaFile -B $binDir";
    
    if ($undo) {
        $self->runCmd(0, "rm -r $workflowDataDir/$gsnapDir/$databaseName");
    }else{
        $self->runCmd($test, $cmd);
    }
}

1;
