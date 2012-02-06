package ApiCommonWorkflow::Main::WorkflowSteps::MakeDescripFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;


sub getDownloadFileCmd {
    my ($self, $downloadFileName, $test) = @_;
    return 'NONE';
}


