package ApiCommonWorkflow::Main::WorkflowSteps::MakeDescripFile;

@ISA = (ApiCommonWorkflow::Main::Util::DownloadFileMaker);

use strict;
use ApiCommonWorkflow::Main::Util::DownloadFileMaker;


sub getDownloadFileCmd {
    my ($self, $downloadFileName, $test) = @_;
    return 'NONE';
}


