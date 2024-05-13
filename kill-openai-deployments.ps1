param (
    [Parameter(Mandatory=$false)] 
    [String]  $AzureCredentialAssetName = 'openai-budget-automation-app',
        
    [Parameter(Mandatory=$false)]
    [String] $AzureSubscriptionId = 'YOUR_SUBSCRIPTION_ID',

    [Parameter(Mandatory=$false)]
    [String] $AzureTenantID = 'YOUR_TENANT_ID',

    [Parameter(Mandatory=$false)] 
    [String] $ResourceGroupName = 'YOUR_OPENAI_RESOURCE_GROUP_NAME',

    [Parameter(Mandatory=$false)] 
    [String] $ResourceName = 'YOUR_OPENAI_RESOURCE_NAME'
)

# Returns strings with status messages
[OutputType([String])]

# Connect to Azure and select the subscription to work against

$Cred = Get-AutomationPSCredential -Name $AzureCredentialAssetName -ErrorAction Stop

Connect-AzAccount -Credential $Cred -Tenant $azureTenantId  -ServicePrincipal

if($err) {
    throw $err
}

$SubId = $AzureSubscriptionId

$DEPLOYMENTS = Get-AzCognitiveServicesAccountDeployment -ResourceGroupName $ResourceGroupName -AccountName $ResourceName

# Stop each of the OpenAI deployments
foreach ($DEPLOYMENT in $DEPLOYMENTS)
{


    $SUCCEEDED = Remove-AzCognitiveServicesAccountDeployment -name $DEPLOYMENT.name -ResourceGroupName $ResourceGroupName -AccountName $ResourceName -Force -PassThru
    echo "Deleted resource named: $($DEPLOYMENT.name) with status $SUCCEEDED"
# $($directory.CreationTime)
}

# Add Resource Lock to prevent further changes # This isn't working right now, but should probably be fine
# New-AzResourceLock -LockLevel ReadOnly -LockNotes "Lock after breaching budget - contact operations to remove" -LockName "OpenAIBudgetBreachLock"  -ResourceGroupName $ResourceGroupName -Force
# New-AzureRmResourceLock -LockLevel ReadOnly -LockNotes "Lock after breaching budget - contact operations to remove" -LockName "OpenAIBudgetBreachLock"   -Scope "/subscriptions/$AzureSubscriptionId"
#  az resource lock create --lock-type ReadOnly --notes "Lock after breaching budget - contact operations to remove" --name "OpenAIBudgetBreachLock" -ResourceGroupName $ResourceGroupName -force
