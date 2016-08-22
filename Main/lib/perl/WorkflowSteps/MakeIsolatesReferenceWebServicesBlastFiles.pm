package ApiCommonWorkflow::Main::WorkflowSteps::MakeIsolatesReferenceWebServicesBlastFiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::MakeWebServicesBlastFiles);

use ApiCommonWorkflow::Main::WorkflowSteps::MakeWebServicesBlastFiles;

sub getNameForFilesSuffix {
  return "Reference";
}


1;

