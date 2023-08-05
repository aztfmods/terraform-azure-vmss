package main

import (
	"context"
	"testing"

	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/compute/armcompute"
	"github.com/aztfmods/terraform-azure-vmss/shared"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

func TestLinuxScaleSet(t *testing.T) {
	t.Parallel()

	tfOptions := shared.GetTerraformOptions("../examples/complete")
	defer shared.Cleanup(t, tfOptions)
	terraform.InitAndApply(t, tfOptions)

	vmss := terraform.OutputMap(t, tfOptions, "vmss")
	vmssName, ok := vmss["name"]
	require.True(t, ok, "VMSS name not found in terraform output")

	resourceGroupName, ok := vmss["resource_group_name"]
	require.True(t, ok, "Resource group name not found in terraform output")

	subscriptionID := terraform.Output(t, tfOptions, "subscriptionId")
	require.NotEmpty(t, subscriptionID, "Subscription ID not found in terraform output")

	cred, err := azidentity.NewDefaultAzureCredential(nil)
	if err != nil {
		t.Fatalf("Failed to create credentials: %v", err)
	}

	client, err := armcompute.NewVirtualMachineScaleSetsClient(subscriptionID, cred, nil)
	if err != nil {
		t.Fatalf("Failed to create VMSS client: %v", err)
	}

	resp, err := client.Get(context.Background(), resourceGroupName, vmssName, nil)
	if err != nil {
		t.Fatalf("Failed to get VMSS: %v", err)
	}

	t.Run("VerifyLinuxScaleSet", func(t *testing.T) {
		verifyLinuxScaleset(t, vmssName, &resp.VirtualMachineScaleSet)
	})
}

func verifyLinuxScaleset(t *testing.T, vmssName string, vmss *armcompute.VirtualMachineScaleSet) {
	t.Helper()

	require.Equal(
		t,
		vmssName,
		*vmss.Name,
		"VMSS name does not match expected value",
	)

	require.Equal(
		t,
		"Succeeded",
		string(*vmss.Properties.ProvisioningState),
		"VMSS provisioning state is not 'Succeeded'",
	)
}
