#Log in to Power BI Service. Make sure Azure endpoint is correct for Azure tenant (i.e. GCC High, DOD, Azure Commercial...)
#Login-PowerBI

#First, Collect all (or one) of the workspaces in a parameter called PBIWorkspace
$PBIWorkspace = Get-PowerBIWorkspace # Add to pull personal -Scope Organization				# Collect all workspaces you have access to
#$PBIWorkspace = Get-PowerBIWorkspace -Name 'Test Power Bi' 	# Use the -Name parameter to limit to one workspace

#Now collect todays date
$TodaysDate = Get-Date -Format "yyyy-MM-dd" 

#Almost finished: Build the outputpath. This Outputpath creates a news map, based on todays date
$OutPutPath = "PowerBIReportsBackup " + $TodaysDate +"/"

#Now loop through the workspaces, hence the ForEach
ForEach($Workspace in $PBIWorkspace)
{
	#For all workspaces there is a new Folder destination: Outputpath + Workspacename
	$Folder = $OutPutPath + "\" + $Workspace.name 
	#If the folder doens't exists, it will be created.
	If(!(Test-Path $Folder) -and -not($Workspace.name -eq "Admin Monitoring"))
	{
		New-Item -ItemType Directory -Force -Path $Folder
	}
	#At this point, there is a folder structure with a folder for all your workspaces 
	
	
	#Collect all (or one) of the reports from one or all workspaces 
	$PBIReports = Get-PowerBIReport -WorkspaceId $Workspace.Id 						 # Collect all reports from the workspace we selected.
	#$PBIReports = Get-PowerBIReport -WorkspaceId $Workspace.Id -Name "My Report Name" # Use the -Name parameter to limit to one report
		
		#Now loop through these reports: 
		ForEach($Report in $PBIReports) 
		{
            If($Workspace.name -eq "Admin Monitoring")
            {
                Write-Host "Found "$Workspace.name":" $Report.name
            }else {
                <# Action when all if and elseif conditions are false #>
            
			#Your PowerShell comandline will say Downloading Workspacename Reportname
			Write-Host "Downloading "$Workspace.name":" $Report.name 
			
			#The final collection including folder structure + file name is created.
			$OutputFile = $OutPutPath + "\" + $Workspace.name + "\" + $Report.name + ".pbix"
			
			# If the file exists, delete it first; otherwise, the Export-PowerBIReport will fail.
			 if (Test-Path $OutputFile)
				{
					Remove-Item $OutputFile
				}
			
			#The pbix is now really getting downloaded
			Export-PowerBIReport -WorkspaceId $Workspace.ID -Id $Report.ID -OutFile $OutputFile
		}
    }
}
