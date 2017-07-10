######################################################################
# Created By @RicardoConzatti | July 2017
# www.Solutions4Crowds.com.br
######################################################################
$RavUser = 0 #"ricardoconzatti@hotmail.com" # Ravello Username (email)
######################################################################
cls
$S4Ctitle = "Ravello Script v1.0`n"
$Body = "@RicardoConzatti`nwww.Solutions4Crowds.com.br`n
===============================
"
write-host $S4Ctitle$Body
Function RavConnect { # Connect to Ravello
	cls
	write-host $S4Ctitle
	write-host $Body
	write-host "Connect to Ravello`n`n===============================`n"
	if ($RavUser -eq 0) {
		$RavUser = read-host "Ravello Account (email)"
	}
	else {
		write-host "Ravello Account:" $RavUser"`n"
	}
	Connect-Ravello -Credential $RavUser | Out-Null
	write-host "`nConnected to Ravello Systems`n" -foregroundcolor "green"
	$GetUser = Get-RavelloUser
	write-host "Hello"$GetUser.Nickname":)`n"
	pause;RavMenu
}
Function RavNewApp { # New Application
	cls
	write-host $S4Ctitle
	write-host $Body
	write-host "Create Application`n`n===============================`n"
	$RavAppName = read-Host "New Application Name"
	$RavAppDesc = read-Host "`nDescription"
	$QuestionBlu = read-host "`nWould you like to create from Blueprint? (Y or N)"
	if ($QuestionBlu -eq "Y") {
		$GetBlu = Get-RavelloBlueprint
		write-host "`nShowing all Blueprints`n"
		$ListBluTotal = 0
		while ($GetBlu.Name.count -ne $ListBluTotal) {
			write-host "$ListBluTotal -"$GetBlu.Name[$ListBluTotal]
			$ListBluTotal++;
		}
		$RavBlu = read-Host "`nExisting Blueprint number"
		$MyBlu = $GetBlu.Name[$RavBlu]
		New-RavelloApplication -ApplicationName $RavAppName -Description $RavAppDesc -BlueprintName $MyBlu -Confirm:$false | Out-Null
		write-host "`nApplication $RavAppName created from blueprint $MyBlu`n" -foregroundcolor "green"
		$QuestionPublish = read-host "Would you like to publish Application $RavAppName? (Y or N)"
		if ($QuestionPublish -eq "Y") {
			$QuestionOpt = read-host "`n1 - Cost`n2 - Performance`n`nOptimize"
			if ($QuestionOpt -eq 1) {
				$RavPubOpt = "COST_OPTIMIZED"
			}
			if ($QuestionOpt -eq 2) {
				$RavPubOpt = "PERFORMANCE_OPTIMIZED"
			}
			$QuestionStartAllVM = read-host "`nWould you like to start all VMs? (Y or N)"
			if ($QuestionStartAllVM -eq "Y") {	
				Publish-RavelloApplication -ApplicationName $RavAppName -OptimizationLevel $RavPubOpt -StartAllVM -Confirm:$false | Out-Null
			}
			if ($QuestionStartAllVM -eq "N") {
				Publish-RavelloApplication -ApplicationName $RavAppName -OptimizationLevel $RavPubOpt -Confirm:$false | Out-Null
			}
		write-host "`nApplication $RavAppName $RavPubOpt published`n" -foregroundcolor "green"
		}	
	}
	else {
		New-RavelloApplication -ApplicationName $RavAppName -Description $RavAppDesc -Confirm:$false | Out-Null
		write-host "`nApplication $RavAppName created`n" -foregroundcolor "green"
	}
	pause;ApplicationMenu
}
Function RavInfoApp { # Info Application
	cls
	write-host $S4Ctitle
	write-host $Body
	write-host "Application Info`n`n===============================`n"
	$GetApp = Get-RavelloApplication
	if ($GetApp.Name.Count -eq 1) {
		write-host "Application:"$GetAppNonPub.Name
		$MyApp = $GetApp.Name
	}
	else {
		$ListAppTotal = 0
		while ($GetApp.Name.count -ne $ListAppTotal) {
			write-host "$ListAppTotal -"$GetApp.Name[$ListAppTotal]
			$ListAppTotal++;
		}
		$RavApp = read-Host "`nExisting Application number"
		$MyApp = $GetApp.Name[$RavApp]
	}
	$GetAppInfo = Get-RavelloApplication -ApplicationName $MyApp
	$GetAppVM = Get-RavelloApplicationVm -ApplicationName $MyApp
	write-host "`nApplication Name:"$GetAppInfo.Name"`nDescription:"$GetAppInfo.description"`nPublished:"$GetAppInfo.published"`n"
	if ($GetAppVM.Name.Count -eq 1) {
		if ($GetAppInfo.published -eq "True") {
			$GetAppVMstatus = Get-RavelloApplicationVmState -ApplicationName $MyApp -VmName $GetAppVM.Name
			write-host $GetAppVM.Name"|"$GetAppVMstatus
		}
		else {
			write-host $GetAppVM.Name
		}
	}
	else {
		$ListAppVMTotal = 0
		while ($GetAppVM.Name.count -ne $ListAppVMTotal) {
			if ($GetAppInfo.published -eq "True") {
				$GetAppVMstatus = Get-RavelloApplicationVmState -ApplicationName $MyApp -VmName $GetAppVM.Name[$ListAppVMTotal]
				write-host $GetAppVM.Name[$ListAppVMTotal]"-"$GetAppVMstatus
			}
			else {
				write-host $GetAppVM.Name[$ListAppVMTotal]
			}
			$ListAppVMTotal++;
		}
	}
	if ($GetAppInfo.published -eq "True") {
		write-host "`nCreation Time:"$GetAppInfo.creationTime"`nRegion Name:"$GetAppInfo.deployment.regionName"`nTotal VM:"$GetAppVM.Name.Count"`nTotal Active VM:"$GetAppInfo.deployment.totalActiveVms"`nTotal Error VM:"$GetAppInfo.deployment.totalErrorVms"`nOptimization:"$GetAppInfo.deployment.publishOptimization"`nStop VM by Order:"$GetAppInfo.deployment.stopVmsByOrder"`n"
	}
	else {
		write-host "`nCreation Time:"$GetAppInfo.creationTime"`n"
	}
	pause;ApplicationMenu
}
Function RavPubApp { # Publish Application
	cls
	write-host $S4Ctitle
	write-host $Body
	write-host "Publish Application`n`n===============================`n"
	$GetAppNonPub = Get-RavelloApplication | where {$_.Published -ne "False"}
	if ($GetAppNonPub.Name.Count -eq 0) {
		write-host "All applications are published`n"
	}
	else {
		write-host "Showing only not published ["$GetAppNonPub.Name.Count"]`n"
		if ($GetAppNonPub.Name.Count -eq 1) {
			write-host "Application:"$GetAppNonPub.Name
			$MyApp = $GetAppNonPub.Name
		}
		else {
			$ListAppNonPubTotal = 0
			while ($GetAppNonPub.Name.count -ne $ListAppNonPubTotal) {
				write-host "$ListAppNonPubTotal -"$GetAppNonPub.Name[$ListAppNonPubTotal]
				$ListAppNonPubTotal++;
			}
			$RavApp = read-Host "`nExisting Application number"
			$MyApp = $GetAppNonPub.Name[$RavApp]
		}
		$GetAppVM = Get-RavelloApplicationVm -ApplicationName $MyApp
		if ($GetAppVM.Name.Count -eq 0) {
			write-host "`nApplication must have at least one VM`n"
			pause;ApplicationMenu
		}
		$QuestionOpt = read-host "`nOptimize for`n1 - Cost`n2 - Performance"
			if ($QuestionOpt -eq 1) {
				$RavPubOpt = "COST_OPTIMIZED"
			}
			if ($QuestionOpt -eq 2) {
				$RavPubOpt = "PERFORMANCE_OPTIMIZED"
			}
			$QuestionStartAllVM = read-host "`nWould you like to start all VMs? (Y or N)"
			if ($QuestionPublish -eq "Y") {	
				Publish-RavelloApplication -ApplicationName $MyApp -OptimizationLevel $RavPubOpt -StartAllVM -Confirm:$false
			}
			if ($QuestionPublish -eq "N") {
				Publish-RavelloApplication -ApplicationName $MyApp -OptimizationLevel $RavPubOpt -Confirm:$false
			}
		write-host "`nApplication $RavAppName published`n" -foregroundcolor "green"
	}
	pause;ApplicationMenu
}
function RavRemApp { # Remove Application
	cls
	write-host $S4Ctitle
	write-host $Body
	write-host "Remove Application`n`n===============================`n"
	$GetAppDel = Get-RavelloApplication
	if ($GetAppDel.Name.Count -eq 1) {
		write-host "Application:"$GetAppDel.Name
		$MyApp = $GetAppDel.Name
	}
	else {
		$ListAppNonPubTotal = 0
		while ($GetAppDel.Name.count -ne $ListAppNonPubTotal) {
			if ($GetAppDel.published[$ListAppNonPubTotal] -eq "True") {
				$AppColor = "green"
			}
			else {
				$AppColor = "red"
			}
			write-host "$ListAppNonPubTotal -"$GetAppDel.Name[$ListAppNonPubTotal] -foregroundcolor $AppColor
			$ListAppNonPubTotal++;
		}
		$RavApp = read-Host "`nExisting Application number"
		$MyApp = $GetAppDel.Name[$RavApp]
	}
	if ($GetAppDel.published[$RavApp] -eq "True") {
		write-host "`n$MyApp is published"
	}
	else {
		write-host "`n$MyApp is not published"
	}
	$QuestionAppDel = read-host "`nWould you like to REMOVE $MyApp ? (Y or N)"
		if ($QuestionAppDel -eq "Y") {
			Remove-RavelloApplication -ApplicationName $MyApp -Confirm:$false | Out-Null
			write-host "`nApplication $MyApp removed`n" -foregroundcolor "green"
		}
	pause;ApplicationMenu
}
Function RavNewBlu { # New Blueprint
	cls
	write-host $S4Ctitle
	write-host $Body
	write-host "Create Blueprint`n`n===============================`n"
	$GetApp = Get-RavelloApplication #| where {$_.Published -ne "False"}
	
	if ($GetApp.Name.Count -eq 1) {
		write-host "Application:"$GetApp.Name
		$MyApp = $GetApp.Name
	}
	else {
		$ListAppTotal = 0
		while ($GetApp.Name.count -ne $ListAppTotal) {
			write-host "$ListAppTotal -"$GetApp.Name[$ListAppTotal]
			$ListAppTotal++;
		}
		$RavApp = read-Host "`nExisting Application number"
		$MyApp = $GetApp.Name[$RavApp]
	}
	$RavBluName = read-Host "`nNew Blueprint Name"
	$RavBluDesc = read-Host "`nDescription"
	New-RavelloBlueprint -ApplicationName $MyApp -Description $RavBluDesc -BlueprintName $RavBluName -Confirm:$false | Out-Null
	write-host "`nBlueprint $RavBluName created`n" -foregroundcolor "green"
	pause;BlueprintMenu
}
Function RavInfoBlu { # Info Blueprint
	cls
	write-host $S4Ctitle
	write-host $Body
	write-host "Blueprint Info`n`n===============================`n"
	$GetBlu = Get-RavelloBlueprint -Private
	write-host "Showing only private Blueprint ["$GetBlu.Name.Count"]`n"
	if ($GetBlu.Name.Count -eq 1) {
		write-host "Blueprint:"$GetBlu.Name
		$MyBlu = $GetBlu.Name
	}
	else {
		$ListBluTotal = 0
		while ($GetBlu.Name.count -ne $ListBluTotal) {
			write-host "$ListBluTotal -"$GetBlu.Name[$ListBluTotal]
			$ListBluTotal++;
		}
		$RavBlu = read-Host "`nExisting Blueprint number"
		$MyBlu = $GetBlu.Name[$RavBlu]
	}
	$GetBluInfo = Get-RavelloBlueprint -BlueprintName $MyBlu
	write-host "`nBlueprint Name:"$GetBluInfo.Name"`nDescription:"$GetBluInfo.description"`nPublished:"$GetBluInfo.published"`nPublic:"$GetBluInfo.Ispublic"`nStop VM by Order:"$GetBluInfo.design.stopVmsByOrder"`nCreation Time:"$GetBluInfo.creationTime"`n"
	pause;BlueprintMenu
}
function RavRemBlu { # Remove Blueprint
	cls
	write-host $S4Ctitle
	write-host $Body
	write-host "Remove Blueprint`n`n===============================`n"
	$GetBluDel = Get-RavelloBlueprint -Private
	if ($GetBluDel.Name.Count -eq 1) {
		write-host "Blueprint:"$GetBluDel.Name
		$MyBlu = $GetBluDel.Name
	}
	else {
		$ListBluTotal = 0
		while ($GetBluDel.Name.count -ne $ListBluTotal) {
			write-host "$ListBluTotal -"$GetBluDel.Name[$ListBluTotal]
			$ListBluTotal++;
		}
		$RavBlu = read-Host "`nExisting Blueprint number"
		$MyBlu = $GetBluDel.Name[$RavBlu]
	}
	$QuestionBluDel = read-host "`nWould you like to REMOVE $MyBlu ? (Y or N)"
		if ($QuestionBluDel -eq "Y") {
			Remove-RavelloBlueprint -BlueprintName $MyBlu -Confirm:$false | Out-Null
			write-host "`nBlueprint $MyBlu removed`n" -foregroundcolor "green"
		}
	pause;BlueprintMenu
}
###########################
########## MENUS ##########
###########################
Function RavMenu { ######### PRINCIPAL MENU #########
	cls
	write-host $S4Ctitle
	write-host $Body
	write-host "PRINCIPAL MENU`n`n===============================`n"
	write-host "1 - Connect Ravello`n"
	write-host "2 - Application`n"
	write-host "3 - Blueprint`n"
	write-host "9 - EXIT`n`n" -foregroundcolor "red"
	$vQuestion = read-host "Choose an Option"
	switch ($vQuestion) {
		1 {RavConnect}
		2 {ApplicationMenu}
		3 {BlueprintMenu}
		9 {Disconnect-Ravello -confirm:$false;exit}
		default {
			cls
			write-host "Invalid option, try again!" -foregroundcolor "red"
			pause;RavMenu
		}
		}
}
Function ApplicationMenu { ######### Application MENU #########
	cls
	write-host $S4Ctitle
	write-host $Body
	write-host "Application MENU`n`n===============================`n"
	write-host "1 - Create`n"
	write-host "2 - Publish`n"
	write-host "3 - Info`n"
	write-host "4 - Remove`n"
	write-host "9 - BACK`n`n" -foregroundcolor "red"
	$vQuestion = read-host "Choose an Option"
	switch ($vQuestion) {
		1 {RavNewApp}
		2 {RavPubApp}
		3 {RavInfoApp}
		4 {RavRemApp}
		9 {RavMenu}
		default {
			cls
			write-host "Invalid option, try again!" -foregroundcolor "red"
			pause;RavMenu
		}
		}
}
Function BlueprintMenu { ######### BLUEPRINT MENU #########
	cls
	write-host $S4Ctitle
	write-host $Body
	write-host "BLUEPRINT MENU`n`n===============================`n"
	write-host "1 - Create`n"
	write-host "2 - Info`n"
	write-host "3 - Remove`n"
	write-host "9 - BACK`n`n" -foregroundcolor "red"
	$vQuestion = read-host "Choose an Option"
	switch ($vQuestion) {
		1 {RavNewBlu}
		2 {RavInfoBlu}
		3 {RavRemBlu}
		9 {RavMenu}
		default {
			cls
			write-host "Invalid option, try again!" -foregroundcolor "red"
			pause;RavMenu
		}
		}
}
RavMenu