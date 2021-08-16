param (
    [parameter(Mandatory=$false,
    HelpMessage="Enter your Rancher API token username obtained through the RKE UI")]
    [ValidateNotNullOrEmpty()]
    [string]$RancherTokenUsername = "",
    [parameter(Mandatory=$false,
    HelpMessage="Enter your Rancher API token password obtained through the RKE UI")]
    [ValidateNotNullOrEmpty()]
    [string]$RancherTokenPassword = "",
    [parameter(Mandatory=$false,
    HelpMessage="Enter an RKE URL")]
    [string]$RancherURL = "",
    [parameter(Mandatory=$true,
    HelpMessage="Enter cloud credentials to use with RKE")]
    [ValidateNotNullOrEmpty()]
    [string]$CloudCredential)

    try {
        Write-Host -ForegroundColor Magenta "Starting"

        $StopWatch = New-Object -TypeName System.Diagnostics.Stopwatch
        $StopWatch.Start()

        $AuthenticationUser = $RancherTokenUsername
        $AuthenticationPassword = ConvertTo-SecureString -String $RancherTokenPassword -AsPlainText -Force
        $AuthenticationCredential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $AuthenticationUser, $AuthenticationPassword

        $FullPath = Get-Location

        Write-Host -ForegroundColor DarkBlue "Checking for 'autoexport' folder"

        $AutoExportFolder = Test-Path -Path "$FullPath\autoexport"

        if (!$AutoExportFolder) {
            Write-Host -ForegroundColor Yellow "Creating 'autoexport' folder"
            New-Item -Path "$FullPath" -Name "autoexport" -ItemType "directory"
        }

        Write-Host -ForegroundColor DarkBlue "Gathering information for all clusters on '$RancherURL'"

        $ClusterRequestURL = "$RancherURL/v3/clusters"

        $ClusterRequest = Invoke-RestMethod -Method 'GET' -Authentication Basic -Credential $AuthenticationCredential -Uri $ClusterRequestURL -SkipCertificateCheck -Headers @{ "Accept" = "application/json" }

        if ($ClusterRequest.data) {
            Write-Host -ForegroundColor DarkBlue "Found $($ClusterRequest.data.count) clusters on '$RancherURL'"
            foreach ($Cluster in $ClusterRequest.data) {
                $ClusterRootFolder = Test-Path "$FullPath\autoexport\$($Cluster.name)"
                if (!$ClusterRootFolder) {
                    Write-Host -ForegroundColor Yellow "Creating folder for the '$($Cluster.name)' cluster"
                    New-Item -Path "$FullPath\autoexport" -Name $Cluster.name -ItemType "directory"
                }

                $CertsFolder = Test-Path "$FullPath\autoexport\$($Cluster.name)\certs"
                if (!$CertsFolder) {
                    Write-Host -ForegroundColor Yellow "Creating 'certs' folder for the '$($Cluster.name)' cluster"
                    New-Item -Path "$FullPath\autoexport\$($Cluster.name)" -Name "certs" -ItemType "directory"
                }

                $ClusterFolder = Test-Path "$FullPath\autoexport\$($Cluster.name)\cluster"
                if (!$ClusterFolder) {
                    Write-Host -ForegroundColor Yellow "Creating 'cluster' folder for the '$($Cluster.name)' cluster"
                    New-Item -Path "$FullPath\autoexport\$($Cluster.name)" -Name "cluster" -ItemType "directory"
                }

                $NodePoolFolder = Test-Path "$FullPath\autoexport\$($Cluster.name)\cluster\node_pool"
                if (!$NodePoolFolder) {
                    Write-Host -ForegroundColor Yellow "Creating 'cluster\node_pool' folder for the '$($Cluster.name)' cluster"
                    New-Item -Path "$FullPath\autoexport\$($Cluster.name)\cluster" -Name "node_pool" -ItemType "directory"
                }

                $IngressFolder = Test-Path "$FullPath\autoexport\$($Cluster.name)\ingress"
                if (!$IngressFolder) {
                    Write-Host -ForegroundColor Yellow "Creating 'ingress' folder for the '$($Cluster.name)' cluster"
                    New-Item -Path "$FullPath\autoexport\$($Cluster.name)" -Name "ingress" -ItemType "directory"
                }

                $NamespacesFolder = Test-Path "$FullPath\autoexport\$($Cluster.name)\namespaces"
                if (!$NamespacesFolder) {
                    Write-Host -ForegroundColor Yellow "Creating 'namespaces' folder for the '$($Cluster.name)' cluster"
                    New-Item -Path "$FullPath\autoexport\$($Cluster.name)" -Name "namespaces" -ItemType "directory"
                }

                $NodeTemplateFolder = Test-Path "$FullPath\autoexport\$($Cluster.name)\node_template"
                if (!$NodeTemplateFolder) {
                    Write-Host -ForegroundColor Yellow "Creating 'node_template' folder for the '$($Cluster.name)' cluster"
                    New-Item -Path "$FullPath\autoexport\$($Cluster.name)" -Name "node_template" -ItemType "directory"
                }

                $ProjectsFolder = Test-Path "$FullPath\autoexport\$($Cluster.name)\projects"
                if (!$ProjectsFolder) {
                    Write-Host -ForegroundColor Yellow "Creating 'projects' folder for the '$($Cluster.name)' cluster"
                    New-Item -Path "$FullPath\autoexport\$($Cluster.name)" -Name "projects" -ItemType "directory"
                }

                $RegistriesFolder = Test-Path "$FullPath\autoexport\$($Cluster.name)\registries"
                if (!$RegistriesFolder) {
                    Write-Host -ForegroundColor Yellow "Creating 'registries' folder for the '$($Cluster.name)' cluster"
                    New-Item -Path "$FullPath\autoexport\$($Cluster.name)" -Name "registries" -ItemType "directory"
                }

                $WorkloadsFolder = Test-Path "$FullPath\autoexport\$($Cluster.name)\workloads"
                if (!$WorkloadsFolder) {
                    Write-Host -ForegroundColor Yellow "Creating 'workloads' folder for the '$($Cluster.name)' cluster"
                    New-Item -Path "$FullPath\autoexport\$($Cluster.name)" -Name "workloads" -ItemType "directory"
                }

                # Create the 'cluster.json' file under the '$ClusterName/cluster/' folder
                Write-Host -ForegroundColor Yellow "Generating the 'cluster.json' file for the '$($Cluster.name)' cluster"
                $ClusterObjectRequestURL = "$RancherURL/v3/clusters/?name=$($Cluster.name)"
                $ClusterObjectRequest = Invoke-RestMethod -Method 'GET' -Authentication Basic -Credential $AuthenticationCredential -Uri $ClusterObjectRequestURL -SkipCertificateCheck -Headers @{ "Accept" = "application/json" }
                if (!$ClusterObjectRequest.data) {
                    Write-Host -ForegroundColor Red "No data was returned for the '$($Cluster.name)' cluster. I'm not even sure how this is possible. Exiting."
                    break
                } else {
                    $ClusterID = $ClusterObjectRequest.data.id
                    $ClusterJSONSpecFile = Get-Content -Path "$FullPath\autoexport_specs\clusterspec.json" | ConvertFrom-Json
                    foreach ($Property in $ClusterJSONSpecFile.PSObject.Properties) {
                        if ($Property.Value) {
                            if ($Property.Value -is [System.Management.Automation.PSCustomObject]) {
                                foreach ($SubProperty in $Property.Value.PSObject.Properties) {
                                    $ClusterJSONSpecFile.$($Property.Name).$($SubProperty.Name) =  $($ClusterObjectRequest.data.$($Property.Name).$($SubProperty.Name))
                                }
                            }
                        } else {
                            $ClusterJSONSpecFile.$($Property.Name) = $($ClusterObjectRequest.data.$($Property.Name))
                        }
                    }
                    $ClusterJSONSpecFile | ConvertTo-Json -Depth 100 | Out-File "$FullPath\autoexport\$($Cluster.name)\cluster\cluster.json"
                }

                # Create node pool files under the 'cluster\node_pool' folder
                Write-Host -ForegroundColor Yellow "Generating node pool files for the '$($Cluster.name)' cluster"
                $NodePoolRequestURL = "$RancherURL/v3/nodePools/?clusterId=$ClusterID"
                $NodePoolRequest = Invoke-RestMethod -Method 'GET' -Authentication Basic -Credential $AuthenticationCredential -Uri $NodePoolRequestURL -SkipCertificateCheck -Headers @{ "Accept" = "application/json" }
                if (!$NodePoolRequest.data) {
                    Write-Host -ForegroundColor Red "No node pool data was returned for the '$($Cluster.name)' cluster"
                } else {
                    foreach ($NodePool in $NodePoolRequest.data) {
                        $NodePoolJSONSpecFile = Get-Content -Path "$FullPath\autoexport_specs\nodepoolspec.json" | ConvertFrom-Json
                        foreach ($Property in $NodePoolJSONSpecFile.PSObject.Properties) {
                            if ($Property.Value) {
                                if ($Property.Value -is [System.Management.Automation.PSCustomObject]) {
                                    foreach ($SubProperty in $Property.Value.PSObject.Properties) {
                                        $NodePoolJSONSpecFile.$($Property.Name).$($SubProperty.Name) = $($NodePool.$($Property.Name).$($SubProperty.Name))
                                    }
                                }
                            } else {
                                $NodePoolJSONSpecFile.$($Property.Name) = $($NodePool.$($Property.Name))
                            }
                        }
                        $NodePoolJSONSpecFile | ConvertTo-Json -Depth 100 | Out-File "$FullPath\autoexport\$($Cluster.name)\cluster\node_pool\$($NodePool.hostnamePrefix).json"
                    }
                }

                # Create project files under the 'projects' folder
                Write-Host -ForegroundColor Yellow "Generating project files for the '$($Cluster.name)' cluster"
                $ProjectIDs = @()
                $ProjectRequestURL = "$RancherURL/v3/projects/?clusterId=$ClusterID"
                $ProjectRequest = Invoke-RestMethod -Method 'GET' -Authentication Basic -Credential $AuthenticationCredential -Uri $ProjectRequestURL -SkipCertificateCheck -Headers @{ "Accept" = "application/json" }
                if (!$ProjectRequest.data) {
                    Write-Host -ForegroundColor Red "No project data was returned for the '$($Cluster.name)' cluster"
                } else {
                    foreach ($Project in $ProjectRequest.data) {
                        $ProjectIDs += @{"ProjectID" = $Project.ID; "ProjectName" = $Project.Name}
                        $ProjectJSONSpecFile = Get-Content -Path "$FullPath\autoexport_specs\projectspec.json" | ConvertFrom-Json
                        foreach ($Property in $ProjectJSONSpecFile.PSObject.Properties) {
                            if ($Property.Value) {
                                if ($Property.Value -is [System.Management.Automation.PSCustomObject]) {
                                    foreach ($SubProperty in $Property.Value.PSObject.Properties) {
                                        $ProjectJSONSpecFile.$($Property.Name).$($SubProperty.Name) = $($Project.$($Property.Name).$($SubProperty.Name))
                                    }
                                }
                            } else {
                                $ProjectJSONSpecFile.$($Property.Name) = $($Project.$($Property.Name))
                            }
                        }
                        $ProjectJSONSpecFile | ConvertTo-Json -Depth 100 | Out-File "$FullPath\autoexport\$($Cluster.name)\projects\$($Project.Name).json"
                    }
                }

                # Create namespace files under the 'namespaces' folder
                Write-Host -ForegroundColor Yellow "Generating namespace files for the '$($Cluster.name)' cluster"
                $NamespaceRequestURL = "$RancherURL/v3/cluster/$ClusterID/namespaces/"
                $NamespaceRequest = Invoke-RestMethod -Method 'GET' -Authentication Basic -Credential $AuthenticationCredential -Uri $NamespaceRequestURL -SkipCertificateCheck -Headers @{ "Accept" = "application/json" }
                if (!$NamespaceRequest.data) {
                    Write-Host -ForegroundColor Red "No namespace data was returned for the '$($Cluster.name)' cluster"
                } else {
                    foreach ($Namespace in $NamespaceRequest.data) {
                        $NamespaceJSONSpecFile = Get-Content -Path "$FullPath\autoexport_specs\namespacespec.json" | ConvertFrom-Json
                        foreach ($Property in $NamespaceJSONSpecFile.PSObject.Properties) {
                            if ($Property.Value) {
                                if ($Property.Value -is [System.Management.Automation.PSCustomObject]) {
                                    foreach ($SubProperty in $Property.Value.PSObject.Properties) {
                                        $NamespaceJSONSpecFile.$($Property.Name).$($SubProperty.Name) = $($Namespace.$($Property.Name).$($SubProperty.Name))
                                    }
                                }
                            } else {
                                $NamespaceJSONSpecFile.$($Property.Name) = $($Namespace.$($Property.Name))
                            }
                        }
                        $NamespaceJSONSpecFile | ConvertTo-Json -Depth 100 | Out-File "$FullPath\autoexport\$($Cluster.name)\namespaces\$($Namespace.name).json"
                    }
                }

                # Create workload files under the 'workloads' folder
                Write-Host -ForegroundColor Yellow "Generating workload files for the '$($Cluster.name)' cluster"
                foreach ($Project in $ProjectIDs) {
                    $ProjectSubFolder = Test-Path "$FullPath\autoexport\$($Cluster.name)\workloads\$($Project.ProjectName)"
                    if (!$ProjectSubFolder) {
                        Write-Host -ForegroundColor Yellow "Creating '$($Project.ProjectName)' workspace folder for the '$($Cluster.name)' cluster"
                        New-Item -Path "$FullPath\autoexport\$($Cluster.name)\workloads" -Name $Project.ProjectName -ItemType "directory"
                    } else {
                        $WorkloadRequestURL = "$RancherURL/v3/project/$($Project.ProjectID)/workloads"
                        $WorkloadRequest = Invoke-RestMethod -Method 'GET' -Authentication Basic -Credential $AuthenticationCredential -Uri $WorkloadRequestURL -SkipCertificateCheck -Headers @{ "Accept" = "application/json" }
                        if (!$WorkloadRequest.data) {
                            Write-Host -ForegroundColor Red "No workload data was returned for project '$($Project.ProjectName)' for the '$($Cluster.name)' cluster"
                        } else {
                            foreach ($Workload in $WorkloadRequest.data) {
                                $WorkloadJSONSpecFile = Get-Content -Path "$FullPath\autoexport_specs\workloadspec.json" | ConvertFrom-Json
                                foreach ($Property in $WorkloadJSONSpecFile.PSObject.Properties) {
                                    if ($Property.Value) {
                                        if ($Property.Value -is [System.Management.Automation.PSCustomObject]) {
                                            foreach ($SubProperty in $Property.Value.PSObject.Properties) {
                                                $WorkloadJSONSpecFile.$($Property.Name).$($SubProperty.Name) = $($Workload.$($Property.Name).$($SubProperty.Name))
                                            }
                                        }
                                    } else {
                                        $WorkloadJSONSpecFile.$($Property.Name) = $($Workload.$($Property.Name))
                                    }
                                }
                                $WorkloadJSONSpecFile | ConvertTo-Json -Depth 100 | Out-File "$FullPath\autoexport\$($Cluster.name)\workloads\$($Project.ProjectName)\$($Workload.name).json"
                            }
                        }
                    }
                }

                # Create ingress files under the 'ingress' folder
                Write-Host -ForegroundColor Yellow "Generating ingress files for the '$($Cluster.name)' cluster"
                foreach ($Project in $ProjectIDs) {
                    $IngressRequestURL = "$RancherURL/v3/project/$($Project.ProjectID)/ingresses"
                    $IngressRequest = Invoke-RestMethod -Method 'GET' -Authentication Basic -Credential $AuthenticationCredential -Uri $IngressRequestURL -SkipCertificateCheck -Headers @{ "Accept" = "application/json" }
                    if (!$IngressRequest.data) {
                        Write-Host -ForegroundColor Red "No ingress data was returned for project '$($Project.ProjectName)' for the '$($Cluster.name)' cluster"
                    } else {
                        foreach ($Ingress in $IngressRequest.data) {
                            $IngressJSONSpecFile = Get-Content -Path "$FullPath\autoexport_specs\ingressspec.json" | ConvertFrom-Json
                            foreach ($Property in $IngressJSONSpecFile.PSObject.Properties) {
                                if ($Property.Value) {
                                    if ($Property.Value -is [System.Management.Automation.PSCustomObject]) {
                                        foreach ($SubProperty in $Property.Value.PSObject.Properties) {
                                            $IngressJSONSpecFile.$($Property.Name).$($SubProperty.Name) = $($Ingress.$($Property.Name).$($SubProperty.Name))
                                        }
                                    }
                                } else {
                                    $IngressJSONSpecFile.$($Property.Name) = $($Ingress.$($Property.Name))
                                }
                            }
                            $IngressJSONSpecFile | ConvertTo-Json -Depth 100 | Out-File "$FullPath\autoexport\$($Cluster.name)\ingress\$($Project.ProjectName)_$($Ingress.name).json"
                        }
                    }
                }

                # Create certificate files under the 'certs' folder
                Write-Host -ForegroundColor Yellow "Generating certificate files for the '$($Cluster.name)' cluster"
                foreach ($Project in $ProjectIDs) {
                    $CertificateRequestURL = "$RancherURL/v3/project/$($Project.ProjectID)/certificates"
                    $CertificateRequest = Invoke-RestMethod -Method 'GET' -Authentication Basic -Credential $AuthenticationCredential -Uri $CertificateRequestURL -SkipCertificateCheck -Headers @{ "Accept" = "application/json" }
                    if (!$CertificateRequest.data) {
                        Write-Host -ForegroundColor Red "No certificate data was returned for project '$($Project.ProjectName)' for the '$($Cluster.name)' cluster"
                    } else {
                        foreach ($Certificate in $CertificateRequest.data) {
                            $CertificateJSONSpecFile = Get-Content -Path "$FullPath\autoexport_specs\certificatespec.json" | ConvertFrom-Json
                            foreach ($Property in $CertificateJSONSpecFile.PSObject.Properties) {
                                if ($Property.Value) {
                                    if ($Property.Value -is [System.Management.Automation.PSCustomObject]) {
                                        foreach ($SubProperty in $Property.Value.PSObject.Properties) {
                                            $CertificateJSONSpecFile.$($Property.Name).$($SubProperty.Name) = $($Certificate.$($Property.Name).$($SubProperty.Name))
                                        }
                                    }
                                } else {
                                    $CertificateJSONSpecFile.$($Property.Name) = $($Certificate.$($Property.Name))
                                }
                            }
                            $CertificateJSONSpecFile | ConvertTo-Json -Depth 100 | Out-File "$FullPath\autoexport\$($Cluster.name)\certs\$($Project.ProjectName)_$($Certificate.name).json"
                        }
                    }
                }

                # Create registry files under the 'registries' folder
                Write-Host -ForegroundColor Yellow "Generating registry files for the '$($Cluster.name)' cluster"
                foreach ($Project in $ProjectIDs) {
                    $RegistryRequestURL = "$RancherURL/v3/project/$($Project.ProjectID)/namespacedDockerCredentials"
                    $RegistryRequest = Invoke-RestMethod -Method 'GET' -Authentication Basic -Credential $AuthenticationCredential -Uri $RegistryRequestURL -SkipCertificateCheck -Headers @{ "Accept" = "application/json" }
                    if (!$RegistryRequest.data) {
                        Write-Host -ForegroundColor Red "No registry data was returned for project '$($Project.ProjectName)' for the '$($Cluster.name)' cluster"
                    } else {
                        foreach ($Registry in $RegistryRequest.data) {
                            $RegistryJSONSpecFile = Get-Content -Path "$FullPath\autoexport_specs\registryspec.json" | ConvertFrom-Json
                            foreach ($Property in $RegistryJSONSpecFile.PSObject.Properties) {
                                if ($Property.Value) {
                                    if ($Property.Value -is [System.Management.Automation.PSCustomObject]) {
                                        foreach ($SubProperty in $Property.Value.PSObject.Properties) {
                                            $RegistryJSONSpecFile.$($Property.Name).$($SubProperty.Name) = $($Registry.$($Property.Name).$($SubProperty.Name))
                                        }
                                    }
                                } else {
                                    $RegistryJSONSpecFile.$($Property.Name) = $($Registry.$($Property.Name))
                                }
                            }
                            $RegistryJSONSpecFile | ConvertTo-Json -Depth 100 | Out-File "$FullPath\autoexport\$($Cluster.name)\registries\$($Project.ProjectName)_$($Registry.name).json"
                        }
                    }
                }
            }
        } else {
            Write-Host -ForegroundColor Red "No clusters found on '$RancherURL'. Exiting."
            break
        }

        $StopWatch.Stop()

        Write-Host -ForegroundColor Magenta "Finished"

        Write-Host -ForegroundColor DarkMagenta "Script ran in $($StopWatch.Elapsed.Hours):$($StopWatch.Elapsed.Minutes):$($StopWatch.Elapsed.Seconds).$($StopWatch.Elapsed.Milliseconds)"
    }
    catch {
        Write-Error -Message "An error occured"
        Write-Host $PSItem
        break
    }
