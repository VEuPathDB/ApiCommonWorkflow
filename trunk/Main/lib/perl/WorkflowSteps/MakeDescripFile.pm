package ApiCommonWorkflow::Main::WorkflowSteps::MakeDescripFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::DownloadFileMaker);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::DownloadFileMaker;


sub getDownloadFileCmd {
    my ($self, $downloadFileName, $test) = @_;
    return 'NONE';
}


