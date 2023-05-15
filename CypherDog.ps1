## CHANGES
# fix Dynamic param alias

## New Edges
# ACL: AddKeyCredentialLink/WriteSPN/AddSelf

## New Props
# Various > expecting no change required


## TODO

## Edges
# [x] Add New Edges to Enums
# [x] Test Edges with EdgeString/Edge/Path

## Props
# [x] Check auto-populate OK
# [x] Add time props to FixNode


## Broken Stuff
# [x] fix Labels[0] in path/edge/pathtoobj <--------------- also breaks in Watchdog


###########################################################
# CypherDog4.1 - BloodHound Dog Whisperer - @SadProcessor #
###########################################################

###########################################################
#region ############################################## VARS

##################################################### ASCII
$ASCII= @("
 _____________________________________________
 _______|_____________________________________
 ______||__________________________CYPHERDOG__
 ______||-________...____________________4.3__
 _______||-__--||||||||-._______________beta__
 ________!||||||||||||||||||--________________
 _________|||||||||||||||||||||-______________
 _________!||||||||||||||||||||||.____________
 ________.||||||!!||||||||||||||||-___________
 _______|||!||||___||||||||||||||||.__________
 ______|||_.||!___.|||'_!||_'||||||!._________
 _____||___!||____|||____||___|||||.__________
 ______||___||_____||_____||!__!|||'__________
 ___________ ||!____||!_______________________
 _____________________________________________

 BloodHound Dog Whisperer - @SadProcessor 2023
")

## Invoke-Neo4jCypher
# Fix extra verbose <-------------------------------- Rename prop $CypherDog obj
# Change blocksize stuff <--------------------------- Blocksize: Send in Process{} / last in send in End{}


##################################################### Enums

## NodeType [Add Custom if needed]
enum NodeType{
    # Classic stuff
    Base
    Computer
    Domain
    Group
    User
    GPO
    OU
    Container
    #Azure stuffs
    AZBase
    AZApp
    AZDevice
    AZGroup
    AZKeyVault
    AZManagementGroup
    AZResourceGroup
    AZRole
    AZServicePrincipal
    AZSubscription
    AZTenant
    AZUser
    AZVM
    # New Azure - 4.3
    AZAutomationAccount
    AZContainerRegistry
    AZFunctionApp
    AZLogicApp
    AZManagedCluster
    AZVMScaleSet
    AZWebApp
    }


## EdgeType [Update if new Edge added to BH]
enum EdgeType{
    #Default
    MemberOf
    AdminTo
    HasSession
    #TrustedBy
    #ACL
    AllExtendedRights
    AddMember
    ForceChangePassword
    GenericAll
    GenericWrite
    Owns
    WriteDacl
    WriteOwner
    ReadLAPSPassword
    ReadGMSAPassword
    AddKeyCredentialLink
    WriteSPN
    AddSelf
    AddAllowedToAct
    DCSync
    SyncLAPSPassword
    WriteAccountRestrictions
    #GPO
    Contains
    GPLink
    #Special
    CanRDP
    CanPSRemote
    ExecuteDCOM
    AllowedToDelegate
    AllowedToAct
    SQLAdmin
    HasSIDHistory
    #Azure
    AZAvereContributor
    AZContains
    AZContributor
    AZGetCertificates
    AZGetKeys
    AZGetSecrets
    AZHasRole
    AZMemberOf
    AZOwner
    AZRunsAs
    AZVMContributor
    AZVMAdminLogin
    AZAddMembers
    AZAddSecret
    AZExecuteCommand
    AZGlobalAdmin
    AZPrivilegedAuthAdmin
    AZGrant
    AZGrantSelf
    AZPrivilegedRoleAdmin
    AZResetPassword
    AZUserAccessAdministrator
    AZOwns
    AZScopedTo
    AZCloudAppAdmin
    AZAppAdmin
    AZAddOwner
    AZManagedIdentity
    AZKeyVaultContributor
    # New Azure - 4.3
    AZMGGrantRole
    AZMGGrantAppRole
    AZMGAddSecret
    AZMGAddOwner
    AZMGAddMember
    AZAddAutomationContributor
    AZKeyVaultKVContributor
    AZLogicAppContributor
    AZWebsiteContributor
    AZAKSContributor
    AZNodeResourceGroup
    AZMGRoleManagement_ReadWrite_Directory
    AZMGApplication_ReadWrite_All
    AZMGRoleAssignment_ReadWrite_All
    AZMGDirectory_ReadWrite_All
    AZMGGroup_ReadWrite_All
    AZMGGroupMember_ReadWrite_All
    AZMGServicePrincipalEndpoint_ReadWrite_All
    }

# Default [Update if needed]
enum EdgeDef{
    MemberOf
    AdminTo
    HasSession
    #TrustedBy
    }

# ACL [Update if needed]
enum EdgeACL{
    AllExtendedRights
    AddMember
    ForceChangePassword
    GenericAll
    GenericWrite
    Owns
    WriteDacl
    WriteOwner
    ReadLAPSPassword
    ReadGMSAPassword
    AddKeyCredentialLink
    WriteSPN
    AddSelf
    AddAllowedToAct
    DCSync
    SyncLAPSPassword
    WriteAccountRestrictions
    }

# GPO/OU [Update if needed]
enum EdgeGPO{
    Contains
    GPLink
    }

# Special [Update/Add Custom if needed]
enum EdgeSpc{
    CanRDP
    CanPSRemote
    ExecuteDCOM
    AllowedToDelegate
    AllowedToAct
    SQLAdmin
    HasSIDHistory
    }

# Azure
enum EdgeAzr{
    AZAvereContributor
    AZContains
    AZContributor
    AZGetCertificates
    AZGetKeys
    AZGetSecrets
    AZHasRole
    AZMemberOf
    AZOwner
    AZRunsAs
    AZVMContributor
    AZVMAdminLogin
    AZAddMembers
    AZAddSecret
    AZExecuteCommand
    AZGlobalAdmin
    AZPrivilegedAuthAdmin
    AZGrant
    AZGrantSelf
    AZPrivilegedRoleAdmin
    AZResetPassword
    AZUserAccessAdministrator
    AZOwns
    AZScopedTo
    AZCloudAppAdmin
    AZAppAdmin
    AZAddOwner
    AZManagedIdentity
    AZKeyVaultContributor
    # New Azure - 4.3
    AZMGGrantRole
    AZMGGrantAppRole
    AZMGAddSecret
    AZMGAddOwner
    AZMGAddMember
    AZAddAutomationContributor
    AZKeyVaultKVContributor
    AZLogicAppContributor
    AZWebsiteContributor
    AZAKSContributor
    AZNodeResourceGroup
    AZMGRoleManagement_ReadWrite_Directory
    AZMGApplication_ReadWrite_All
    AZMGRoleAssignment_ReadWrite_All
    AZMGDirectory_ReadWrite_All
    AZMGGroup_ReadWrite_All
    AZMGGroupMember_ReadWrite_All
    AZMGServicePrincipalEndpoint_ReadWrite_All
    }


################################################### BHEdge
Class BHEdge{
    [int]$ID
    [int]$Step
    [int]$Dist
    [String]$SourceType
    [string]$Source
    [string]$Edge
    [String]$Direction
    [String]$TargetType
    [string]$target
    }

#endregion ################################################


###########################################################
#region ############################################## UTIL

# CacheNode
# DynParam
# CredToToken
# CacheNode
# EdgeString



<#function CacheNode{
    [CmdletBinding()]
    Param(
        # Specify Type(s)
        [parameter(Mandatory=0)][NodeType[]]$Type
        )
    Write-Verbose "Caching Node names..."
    # Base/No Type = All
    If($Type -eq $Null -OR $type -contains 'Base'){$Type=[Enum]::GetNames([NodeType]) -notmatch 'Base'}
    # For each type
    foreach($T in $Type){
        # Prep Query
        $Query = "MATCH (n:$T) WHERE n.name IS NOT NULL RETURN n.name"
        # Cache matching name list
        $Script:CypherDog."${T}List"= neo $Query -wa Stop -ea stop -Verbose:$False
        }}
#####End
#>

<#
.Synopsis
   Cache Bloodhound Node Lists [Internal]
.DESCRIPTION
   Cache Name Lists for tab-completion
.EXAMPLE
    CacheNode
#>
function CacheNode{
    [CmdletBinding()]
    Param(
        # Specify Type(s)
        [parameter(Mandatory=0)][NodeType[]]$Type
        )
    $CQL = if($Type -eq $Null){
        Write-Verbose "Caching node names..."
        "// Cache All Nodes
MATCH (x) WHERE x.name IS NOT NULL
WITH DISTINCT [lbl IN LABELS(x) WHERE NOT lbl=~'Base|AZBase'][0] AS label, COLLECT(x.name) AS list
RETURN {Label:label,List:list}"}
        else{Foreach($Label in $Type){
            Write-Verbose "Caching $Label names..."
            "// Cache $Label names
MATCH (x:$Label) WHERE x.name IS NOT NULL
WITH DISTINCT [lbl IN LABELS(x) WHERE NOT lbl=~'Base|AZBase'][0] AS label, COLLECT(x.name) AS list
RETURN {Label:label,List:list}"
            }}
    $Res = Cypher $CQL
    foreach($List in $Res){
        $Script:CypherDog."$($List.Label)List"=$List.list
        }
    }
#End


<#
.Synopsis
   Get Dynamic Param [Internal]
.DESCRIPTION
   Return Single DynParam to be added to dictionnary
.EXAMPLE
    DynP TestParam String -mandatory 1
#>
function DynParam{
    [CmdletBinding()]
    [Alias('DynP')]
    Param(
        [Parameter(Mandatory=1)][String]$Name,
        [Parameter(Mandatory=1)][string]$Type,
        [Parameter(Mandatory=0)][bool]$Mandat=0,
        [Parameter(Mandatory=0)][int]$Pos=$Null,
        [Parameter(Mandatory=0)][bool]$Pipe=0,
        [Parameter(Mandatory=0)][bool]$PipeProp=0,
        [Parameter(Mandatory=0)]$VSet=$Null,
        [Parameter(Mandatory=0)][String]$Alias
        )
    # Create Attribute Obj
    $Attrb = New-Object Management.Automation.ParameterAttribute
    $Attrb.Mandatory=$Mandat
    $Attrb.ValueFromPipeline=$Pipe
    $Attrb.ValueFromPipelineByPropertyName=$PipeProp
    if($Pos -ne $null){$Attrb.Position=$Pos}
    # Create AttributeCollection
    $Cllct = New-Object Collections.ObjectModel.Collection[System.Attribute]
    # Add Attribute Obj to Collection
    $Cllct.Add($Attrb)
    if($VSet -ne $Null){
        # Create ValidateSet & add to collection
        $VldSt=New-Object Management.Automation.ValidateSetAttribute($VSet)
        $Cllct.Add($VldSt)
        }
    if($Alias){
        # Create ValidateSet & add to collection
        $Als=New-Object Management.Automation.AliasAttribute($Alias)
        $Cllct.Add($Als)
        }
    # Create Runtine DynParam
    $DynP = New-Object Management.Automation.RuntimeDefinedParameter("$Name",$($Type-as[type]),$Cllct)
    # Return DynParam
    Return $DynP
    }
#End

<#
.Synopsis
   Generate Edge String [Internal/DIY]
.DESCRIPTION
   Generate Edge String for Cypher Queries
.EXAMPLE
   EdgeString NoACL,NoSpc -Include ForceChangePassword
#>
function EdgeString{
    Param(
        [ValidateSet('NoDefault','NoACL','NoGPO','NoSpecial','NoAzure','AzOnly')]
        [Parameter(Mandatory=0)][String[]]$Filter,
        [Parameter(Mandatory=0)][Edgetype[]]$Exclude,
        [Parameter(Mandatory=0)][Edgetype[]]$Include,
        [Parameter(Mandatory=0)][Switch]$Clip
        )
    if($Filter -Contains 'AzOnly' -and $filter.count -gt 1){Write-Warning "Invalid Filter. AzOnly is Azure Only..."}
    # Start with nothing if only -Include
    if($Include.count -AND -Not$Filter -AND -Not$Exclude){$EdgeList=@()}
    # else start with all
    Else{$EdgeList = [Enum]::GetNames([EdgeType])}
    # Filter by Category
    Switch -regex ($Filter){
        NoDefault {$EdgeList = (Compare-object $EdgeList ([Enum]::GetNames([EdgeDef]))).InputObject}
        NoACL     {$EdgeList = (Compare-object $EdgeList ([Enum]::GetNames([EdgeACL]))).InputObject}
        NoGPO     {$EdgeList = (Compare-object $EdgeList ([Enum]::GetNames([EdgeGPO]))).InputObject}
        NoSpecial {$EdgeList = (Compare-object $EdgeList ([Enum]::GetNames([EdgeSpc]))).InputObject}
        NoAzure   {$EdgeList = (Compare-object $EdgeList ([Enum]::GetNames([EdgeAzr]))).InputObject}
        AzOnly    {$EdgeList = [Enum]::GetNames([EdgeAzr])}
        }
    # Exclude stuff
    foreach($Excl in $Exclude){$EdgeList = $EdgeList -ne $Excl}
    # Include stuff
    Foreach($Incl in $Include){$EdgeList += $Incl}
    # Return String
    $String = ':'+($EdgeList -join '|')
    if($CypherDog.CypherToClip -OR $Clip){$String|set-Clipboard}
    Return $String
    }
#End

<#
.Synopsis
   Cred To Token [Internal/DIY]
.DESCRIPTION
   Cred to Token
.EXAMPLE
   CredToToken
#>
Function CredToToken{
    Param(
        # Cred
        [Parameter(Mandatory=1)][PSCredential]$Cred=$(Get-Credential)
        )
    # Cred to Token
    [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$($Cred.UserName):$($cred.GetNetworkCredential().Password)"))
    }
#End

<#
.Synopsis
   Join-Cypher [Internal/DIY]
.DESCRIPTION
   Join Cypher queries
.EXAMPLE
   $Queries|Join-Cypher
#>
Function Join-Cypher{
    [Alias('UNION')]
    Param(
        # Queries
        [Parameter(Mandatory=1,Position=1,ValueFromPipeline=1)][String[]]$Query,
        [Parameter(Mandatory=0)][Switch]$All
        )
    Begin{
        $List=[System.Collections.ArrayList]@()
        $Joint = if($All){"`r`nUNION ALL`r`n"}else{"`r`nUNION`r`n"}
        }
    Process{Foreach($Q in $Query){$Null=$list.Add($Q)}}
    End{$list-join$Joint}
    }
#End

<#
.Synopsis
   FromUnixTime [Internal/DIY]
.DESCRIPTION
   Convert from Umix timestamp
.EXAMPLE
   $timeStamp|FromUnixTime
#>
Function FromUnixTime{
    Param(
        [Parameter(Mandatory=1,ValueFromPipeline=1)][int]$UnixTime
        )
    Process{
        [datetime]::new(1970,1,1).AddSeconds($UnixTime)
        }
    }

<#
.Synopsis
   ToUnixTime [Internal/DIY]
.DESCRIPTION
   Convert to Unix timestamp
.EXAMPLE
   $DateObj|ToUnixTime
#>
function ToUnixTime{
    Param(
        [Parameter(Mandatory=1,ValueFromPipeline)][DateTime]$Date
        )
    Process{[Math]::truncate(($date-[Datetime]::new(1970,1,1)).totalseconds)}
    }
#End

<#
.Synopsis
   FixNodeDates [Internal/DIY]
.DESCRIPTION
   Fix Node Dates
.EXAMPLE
   $Node|FixNodeDates
#>
function FixNodeDates{
    [Alias('FixDate')]
    Param(
        [Parameter(Mandatory=1,ValueFromPipeline=1)][PSCustomObject[]]$Node
        )
    Begin{}
    Process{foreach($Obj in $Node){
        if($Obj.lastlogon){$Obj.lastlogon=$Obj.lastlogon|FromUnixTime}
        if($Obj.lastlogontimestamp){$Obj.lastlogontimestamp=$Obj.lastlogontimestamp|FromUnixTime}
        if($Obj.pwdlastset){$Obj.pwdlastset=$Obj.pwdlastset|FromUnixTime}
        if($Obj.whencreated){$Obj.WhenCreated=$Obj.WhenCreated|FromUnixTime}
        $obj
        }}
    End{}
    }
#End

<#
.Synopsis
   CustomObjectToHashtable [Internal/DIY]
.DESCRIPTION
   Custom Object To Hashtable
.EXAMPLE
   $CustomObject|ToHashTable
#>
Function CustomObjectToHashTable{
    [Alias('ToHashtable')]
    Param(
        [Parameter(Mandatory=1,ValueFromPipeline=1)][PSCustomObject[]]$Object
        )
    Begin{}
    Process{foreach($Obj in $Object){
        $HashTable=@{}
        ($Obj|GM|? membertype -eq NoteProperty).name|%{
            $HashTable[$_]=$Obj.$_
            }
        $HashTable
        }}
    End{}
    }
#End

<#
.Synopsis
   ToPathObj [Internal/DIY]
.DESCRIPTION
   Output of  invoked "Path ... -Cypher -Raw" To Path Object
.EXAMPLE
   Path User Group * 'DOMAIN ADMINS@DEMO.LOCAL' -Cypher -Raw | Invoke-Neo4jCypher | ToPathObj

   same as:
   PS> Path User Group * 'DOMAIN ADMINS@DEMO.LOCAL'
#>
function ToPathObj{
    Param(
        [Parameter(Mandatory=1,ValueFromPipeline=1)][PSCustomObject]$Data
        )
    Begin{$id=$x=0}
    Process{
        Foreach($Row in $Data){
            if(-not$Data.lngth){Return}
            While($x -lt $Row.lngth){
                [PSCustomObject]@{
                    ID   = $id
                    Step = $x
                    Dist = $Row.lngth-$X
                    SourceType=$Row.labels[$x]
                    Source=$Row.Nodes[$x]
                    Edge=$Row.edgeTypes[$x]
                    Direction='->'
                    TargetType=$Row.labels[$x+1]
                    Target=$Row.Nodes[$x+1]
                    }
                $x+=1
                }
            $Id+=1
            $x=0
            }}
    End{}###
    }
#End

#endregion ################################################


###########################################################
#region ############################################## BASE

# New-CypherDogSession
# Invoke-Neo4jCypher


<#
.Synopsis
   New-CypherDogSession
.DESCRIPTION
   Connect to Neo4jDatabase
.EXAMPLE
   New-CypherDogSession -Cred (Get-Credential) -CypherToClip $true
#>
Function New-CypherDogSession{
    [CmdletBinding()]
    [Alias('CypherDog')]
    Param(
        [Parameter(Mandatory=0)][Alias('Host')][String]$Server='localHost',
        [Parameter(Mandatory=0)][String]$Port=7474,
        [Parameter(Mandatory=0)][String]$Database='neo4j',
        [Parameter(Mandatory=0)][PSCredential]$CredentialObject,
        [Parameter(Mandatory=0)][Switch]$https,
        [Parameter(Mandatory=0)][Switch]$NoCache,
        [Parameter(Mandatory=0)][bool]$CypherToClip=$false
        #[Parameter(Mandatory=0)][bool]$VerboseCall=$false
        )
    if(-Not$CypherDog.Host){
        $Script:CypherDog = [PSCustomObject]@{
            Com          = 'http'
            Host         = 'localhost'
            Port         = 7474
            DB           = 'neo4j'
            Token        = $Null
            CypherToClip = $False
            }
        [Enum]::GetNames([NodeType]) -notmatch 'Base|AZBase'|%{
            $Script:CypherDog|Add-Member -MemberType NoteProperty -Name "$($_)List" -Value $Null -Force
            }}
    # Connection Info
    $Script:CypherDog.Host  = $server
    $Script:CypherDog.Port  = $Port
    $Script:CypherDog.DB    = $Database
    $Script:CypherDog.Token = if($CredentialObject){CredToToken $CredentialObject}Else{$Null}
    $Script:CypherDog.Com   = if($https){'https'}Else{'http'}
    $Script:CypherDog.CypherToCLip = $CypherToClip
    #$Script:CypherDog.VerboseCall  = $VerboseCall
    Write-Host "$ASCII" -ForegroundColor Blue
    # Cache
    If($NoCache){[Enum]::GetNames([NodeType]) -notmatch 'Base|AzBase'|%{$Script:CypherDog."$($_)List"=$Null}}Else{CacheNode}
    }
#End

<#
.Synopsis
   Invoke-Neo4jCypher
.DESCRIPTION
   Invoke Neo4j Cypher
.EXAMPLE
   Invoke-Neo4jCypher "MATCH (x:User) RETURN x.name"
#>
function Invoke-Neo4jCypher{
    [CmdletBinding()]
    [Alias('Neo','Cypher')]
    Param(
        # Cypher Queries
        [Parameter(Mandatory=1,ValueFromPipeline=1)][Alias('Statement')][String[]]$Query,
        # Output Raw Result
        [Parameter(Mandatory=0)][Switch]$Raw,
        # Include Stats
        [Parameter(Mandatory=0)][Switch]$IncludeStats,
        # Host
        [Parameter(Mandatory=0)][Alias('Host')][String]$Server,
        # Port
        [Parameter(Mandatory=0)][String]$Port,
        # DB Name
        [Parameter(Mandatory=0)][String]$Database,
        # Creds
        [Parameter(Mandatory=0)][PSCredential]$CredentialObject,
        # Use https
        [Parameter(Mandatory=0)][Switch]$https
        )
    Begin{
        # URI
        if(-Not$server){$Server=$CypherDog.Host}
        if(-Not$port){$Port=$CypherDog.Port}
        if(-Not$Database){$Database=$CypherDog.DB}
        if(-Not$https){$Com=$CypherDog.com}Else{$Com='https'}
        $URI = "${Com}://${Server}:$Port/db/$Database/tx/commit"
        # HEADERS
        $Headers=@{'Accept'='application/json; charset=UTF-8';'Content-Type'='application/json'}
        if($CredentialObject){
            $Auth = CredToToken $CredentialObject
            }Else{$Auth = $CypherDog.Token}
        if($Auth){$Headers+=@{'Authorization'="Basic $Auth"}}
        # BODY
        [Collections.ArrayList]$Statements = @()
        }
    Process{
        foreach($Q in $Query){
                Write-Verbose "[CYPHER]`r`n$Q"
                # Dodgy Fix for Funky Chars
                $Q=$($Q.ToCharArray()|%{$x=[Byte][Char]"$_";if($x-gt191-AND$x-le255){'\u{0:X4}'-f$x}else{$_}})-join''
                # Add Q to Statemenets
                $Null = $Statements.add(@{
                    statement=$Q
                    includeStats=$IncludeStats.IsPresent
                    })}}
    End{# Body to Json
        $Body=@{statements=$Statements}|ConvertTo-Json
        # POST & ERRORS
        Try{$Reply = irm $URI -Method Post -Headers $Headers -Body $Body -verbose:$false}Catch{
            $Oops =$Error[0]
            if($Oops.ErrorDetails){$OopsMsg = ($Oops.ErrorDetails|ConvertFrom-Json).Errors.Message}
            if($OopsMsg){Write-Warning $OopsMsg}else{Write-Error $Oops}
            }
        # OUTPUT & ERRORS
        if($Reply.Errors.count){Write-Warning $Reply.errors.message}
        if($Raw){$Reply.results}
        else{$Reply.results.data.row}
        }}
#####End

#endregion ################################################


###########################################################
#region ############################################## NODE

# Get-BloodHoundNode
# New-BloodHoundNode
# Set-BloodHoundNode
# Remove-BloodHoundNode


<#
.Synopsis
   Get-BloodHoundNode
.DESCRIPTION
   Get BloodHound Node
.EXAMPLE
   Node User BOB
.EXAMPLE
   Node User -Props @{enabled=$true}
.EXAMPLE
   Node User -Where "x.enabled"
#>
function Get-BloodHoundNode{
    [CmdletBinding(DefaultParameterSetName='ByName')]
    [Alias('Get-Node','Node','x')]
    Param(
        [Parameter(ParameterSetName='ByProp',Mandatory=0,Position=0)]
        [Parameter(ParameterSetName='ByName',Mandatory=0,Position=0)][Alias('Label')][NodeType]$Type='Base',
        [Parameter(ParameterSetName='ByProp',Mandatory=1)][HashTable]$Props,
        [Parameter(Mandatory=0)][Alias('xWhere','NodeWhere')][String]$Where,
        [Parameter(Mandatory=0)][String]$With,
        [Parameter(Mandatory=0)][String]$Return='x',
        [Parameter(Mandatory=0)][String]$OrderBy,
        [Parameter(Mandatory=0)][String]$Limit,
        [Parameter(Mandatory=0)][Switch]$AzHoundData,
        [Parameter(Mandatory=0)][Switch]$Cypher,
        [Parameter(Mandatory=0)][Switch]$Raw
        )
    DynamicParam{
        if($Type -ne 'Base' -AND $PSCmdlet.ParameterSetName -eq 'ByName'){
            $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
            # Prep DynNamelist
            $DynNameList = @($Script:CypherDog."${Type}List")
            # Prep DynP
            $DynName = DynP -Name 'Name' -Type 'String[]' -Mandat 0 -Pos 1 -Pipe 1 -PipeProp 1 -VSet $DynNameList
            # DynP to Dico
            $Dico.Add("Name",$DynName)
            # Return Dico
            Return $Dico
            }}
    Begin{# Prep Q Vars
        if($Type -ne 'Base'){$xType=":$Type"}else{$xType=$Null}
        if($Props){
            $Map = " $($Props|ConvertTo-Json -Compress)".replace('"',"'")
            $Props.Keys|%{$Map = $Map.replace("'$_':","${_}:")}
            }
        if($WHERE){$xWHERE ="`r`nWHERE $WHERE "}
        if($WITH){$WITH ="`r`nWITH $WITH "}
        if($ORDERBY){$RETURN +=" ORDER BY $ORDERBY"}
        if($LIMIT){$RETURN +=" LIMIT $LIMIT"}
        }
    Process{# Build Qs
        $QueryList=@($(
            ## If No Name
            If(-Not$DynName.isset){"MATCH (x${xType}$Map)${xWHERE}${WITH}`r`nRETURN $RETURN"}
            ## If Name
            Foreach($Obj in $DynName.value){
                $Map=" {name:'$Obj'}"
                "MATCH (x${xType}$Map)${xWHERE}${WITH}`r`nRETURN $RETURN"
                }))
        # Invoke Cypher
        if($Cypher){if($CypherDog.CypherToClip){$QueryList|set-clipboard};$QueryList}
        else{$Reply = Invoke-Neo4jCypher $QueryList -Raw:$Raw
            if($AzHoundData -AND $xType -match '^:AZ' -AND $Script:AzHound.Meta.type -eq 'azure'){$reply|Azhound $Xtype.trimStart(':')}
            else{$reply}
            }
        #else{Invoke-Neo4jCypher $QueryList -Raw:$Raw}
        }
    End{}
    }
#End

<#
.Synopsis
   New-BloodHoundNode
.DESCRIPTION
   New BloodHound Node
.EXAMPLE
   NodeCreate User BOB
.EXAMPLE
   NodeCreate User BOB -Props @{enabled=$false}
#>
function New-BloodHoundNode{
    [Alias("NodeCreate")]
    Param(
        [Parameter(Mandatory=1,Position=0)][Alias('Type')][NodeType]$NodeType,
        [Parameter(Mandatory=1,Position=1,ValueFromPipeline=1)][String[]]$Name,
        [Parameter(Mandatory=0,Position=2)][Hashtable]$Props,
        [Parameter(Mandatory=0)][Alias('AutoProps')][Switch]$UseTemplate,
        [Parameter(Mandatory=0)][Alias('ReturnObj')][Switch]$PassThru,
        [Parameter(Mandatory=0)][Switch]$Cypher,
        [Parameter(Mandatory=0)][Switch]$NoCache
        )
    Begin{
        $Tmpl = Switch($NodeType){
            Domain  {@{highvalue=$false;domain='tbd';functionallevel='tbd';distinguishedname='tbd'}}
            User    {@{highvalue=$False;domain='tbd';sidhistory=@();passwordnotreqd=$False;description='';sensitive=$False;unconstraineddelegation=$False;enabled=$True;pwdneverexpires=$False;hasspn=$False;owned=$False;pwdlastset=-1.0;lastlogon=-1.0;distinguishedname='tbd';admincount=$False;serviceprincipalnames=@();lastlogontimestamp=-1.0;dontreqpreauth=$False}}
            Computer{@{highvalue=$False;domain='tbd';haslaps=$False;operatingsystem='tbd';unconstraineddelegation=$False;enabled=$True;owned=$False;pwdlastset=-1.0;serviceprincipalnames=@();distinguishedname='tbd';lastlogontimestamp=-1.0}}
            Group   {@{highvalue=$False;domain='tbd';description='';admincount=$False;distinguishedname='tbd'}}
            OU      {@{highvalue=$False;domain='tbd';blocksinheritance=$False;description='';distinguishedname='tbd'}}
            GPO     {@{highvalue=$False;domain='tbd';gpcpath='tbd';distinguishedname='tbd'}}
            Base    {@{highvalue=$False;domain='tbd';distinguishedname='tbd'}}
            }
        }
    Process{foreach($Obj in $Name){
        $OID=if(-Not$Props.ObjectId){"X-"+[GUID]::NewGuid().guid.toupper()}else{$Props.ObjectId}
        $Query = "MERGE (x:Base {objectid:'$OID'})`r`nSET x:$NodeType, x.name = '$Obj'"
        if($UseTemplate){
            $TmplQ = "SET x += $($Tmpl|ConvertTo-Json)".replace('"',"'")
            $Tmpl.Keys|%{$TmplQ = $TmplQ.replace("'$_':","${_}:")-replace"(\[(.*)\n\s+\n(.*)\])",'[]'}
            $Query+="`r`n$TmplQ"
            }
        if($Props){
            $SetQ = "SET x += $($Props|ConvertTo-Json)".replace('"',"'")
            $Props.Keys|%{$SetQ = $SetQ.replace("'$_':","${_}:")-replace"(\[(.*)\n\s+\n(.*)\])",'[]'}
            $Query+="`r`n$SetQ"
            }
        if($PassThru){$Query+="`r`nRETURN x"}
        if($Cypher){if($CypherDog.CypherToClip){$Query|set-clipboard};$Query}else{neo $Query}
        }}
    End{if($Cypher -OR $NoCache){}else{CacheNode $NodeType}}
    }
#End

<#
.Synopsis
   Set-BloodHoundNode
.DESCRIPTION
   Set BloodHound Node
.EXAMPLE
   NodeSet User BOB @{enabled=$true}
#>
function Set-BloodHoundNode{
    [Alias('NodeSet','NodeUpdate')]
    Param(
        [Parameter(Mandatory=1,Position=0)][NodeType]$Nodetype,
        [Parameter(Mandatory=0)][Alias('ReturnObj')][Switch]$PassThru,
        [Parameter(Mandatory=0)][Switch]$Cypher,
        [Parameter(Mandatory=0)][Switch]$NoCache
        )
    DynamicParam{
        if($NodeType -ne 'Base'){
            $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
            # Prep DynNamelist
            $DynNameList = @($Script:CypherDog."${NodeType}List")
            # Prep DynP
            $DynName = DynP -Name 'Name' -Type 'String[]' -Mandat 1 -Pos 1 -Pipe 1 -PipeProp 1 -VSet $DynNameList
            $DynProps = DynP -Name 'Props' -Type 'Hashtable' -Mandat 1 -Pos 2
            # DynP to Dico
            $Dico.Add("Name",$DynName)
            $Dico.Add("Props",$DynProps)
            # Return Dico
            Return $Dico
            }}
    Begin{}
    Process{foreach($Obj in $DynName.Value){
        # Match
        $MatchQ="MATCH (x:$NodeType {name:'$Obj'})"
        # Set
        $SetQ = "SET x += $($DynProps.value|ConvertTo-Json)".replace('"',"'")
        $DynProps.value.Keys|%{$SetQ = $SetQ.replace("'$_':","${_}:")-replace"(\[(.*)\n\s+\n(.*)\])",'[]'}
        $Query = "$MatchQ`r`n$SetQ"
        # Return
        if($PassThru){$Query+="`r`nRETURN x"}
        # Call
        if($Cypher){if($CypherDog.CypherToClip){$Query|set-clipboard};$Query}else{neo $Query}
        }}
    # Cache
    End{if($DynProps.value.keys -match 'name' -AND -Not($Cypher -OR $NoCache)){CacheNode $NodeType}}
    }
#End

<#
.Synopsis
   Remove-BloodHoundNode
.DESCRIPTION
   Remove BloodHound Node
.EXAMPLE
   NodeDelete User BOB
#>
function Remove-BloodHoundNode{
    [Alias('NodeDelete','NodeRemove')]
    Param(
        [Parameter(Mandatory=1,Position=0)][NodeType]$Nodetype,
        [Parameter(Mandatory=0)][String[]]$Props,
        #[Parameter(Mandatory=1,ValueFromPipelinebyPropertyName=1)][Alias('OID')][String[]]$ObjectID,
        [Parameter(Mandatory=0)][Alias('ReturnObj')][Switch]$PassThru,
        [Parameter(Mandatory=0)][Switch]$Cypher,
        [Parameter(Mandatory=0)][Switch]$NoCache
        )
    DynamicParam{
        if($NodeType -ne 'Base'){
            $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
            # Prep DynNamelist
            $DynNameList = @($Script:CypherDog."${NodeType}List")
            # Prep DynP
            $DynName = DynP -Name 'Name' -Type 'String[]' -Mandat 1 -Pos 1 -Pipe 1 -PipeProp 1 -VSet $DynNameList
            # DynP to Dico
            $Dico.Add("Name",$DynName)
            # Return Dico
            Return $Dico
            }}
    Begin{
        $Rtrn = if($Props){"REMOVE x.$($Props-join", x.")"}else{"DETACH DELETE x"}
        if($PassThru){$Rtrn += " RETURN x"}
        }
    Process{foreach($Obj in $DynName.Value){
        $Query="MATCH (x:$NodeType {name:'$Obj'}) $Rtrn".trim()
        if($Cypher){if($CypherDog.CypherToClip){$Query|set-clipboard};$Query}else{neo $Query}
        }}
    End{if(-Not($Cypher -OR $NoCache)){CacheNode $NodeType}}
    }
#End

#endregion ##################################################


###########################################################
#region ############################################## EDGE

# Get-BloodHoundEdge
# New-BloodHoundEdge
# Remove-BloodHoundEdge
# Get-BloodHoundEdgeInfo


<#
.Synopsis
   Get-BloodHoundEdge
.DESCRIPTION
   Get BloodHound Edge
.EXAMPLE
   Edge user AdminTo Computer * DC1.TEST.LOCAL
.EXAMPLE
   Edge user AdminTo Computer ALICE@TEST.LOCAL *
.EXAMPLE
   Edge user MemberOf Group * 'DOMAIN ADMINS@WHISPERER.LABZ' -Hop 1..
#>
function Get-BloodHoundEdge{
    [CmdletBinding()]
    [Alias('Edge','xy')]
    Param(
        # SourceType
        [Parameter(Mandatory=0,Position=0)][Alias('xType','From')][NodeType]$SourceType='Base',
        # Edge
        [Parameter(Mandatory=1,Position=1)][Edgetype]$Edge,
        # TargetType
        [Parameter(Mandatory=0,Position=2)][Alias('yType','To')][NodeType]$TargetType='Base',
        ## Source (Dyn/Madat0/Pos2)
        ## Target (Dyn/Madat0/Pos3)
        # SourceWhere
        [Parameter(Mandatory=0)][Alias('xWhere')][String]$SourceWhere,
        # TargetWhere
        [Parameter(Mandatory=0)][Alias('yWhere')][String]$TargetWhere,
        # EdgeWhere
        [Parameter(Mandatory=0)][Alias('Where')][String]$EdgeWhere,
        # With
        [Parameter(Mandatory=0)][String]$With,
        # Return
        [Parameter(Mandatory=0)][String]$Return,
        # Return
        [ValidateSet('Source','Target')]
        [Parameter(Mandatory=0)][String]$Expand,
        # Cypher
        [Parameter(Mandatory=0)][Switch]$Cypher,
        # Raw
        [Parameter(Mandatory=0)][Switch]$Raw
        )
    DynamicParam{
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynNamelist
        $DynSourceList = @($Script:CypherDog."${SourceType}List")
        $DynTargetList = @($Script:CypherDog."${TargetType}List")
        # Prep DynP
        $DynSource = DynP -Name 'Source' -Type 'String[]' -Mandat 0 -Pos 3 -Pipe 1 -VSet ($DynSourceList+'*')
        $DynTarget = DynP -Name 'Target' -Type 'string[]' -Mandat 0 -Pos 4 -Pipe 0 -VSet ($DynTargetList+'*')
        # DynP to Dico
        $Dico.Add("Source",$DynSource)
        $Dico.Add("Target",$DynTarget)
        if($Edge -match "MemberOf|Contains"){
            $DynMax = DynP -Name 'Hop' -Type 'string' -Mandat 0 -Pos 5 -Pipe 0
            $Dico.Add("Hop",$DynMax)
            }
        # Return Dico
        Return $Dico
        }
    ## PREP QUERY BLOCKS
    Begin{
        # Src/Tgt Type
        $SrcType = if(-Not$SourceType -OR $SourceType -eq 'Base'){$Null}else{":$SourceType"}
        $TgtType = if(-Not$TargetType -OR $TargetType -eq 'Base'){$Null}else{":$TargetType"}
        # Path MATCH
        $Hop = if($DynMax.IsSet){$DynMax.Value}else{'1'}
        $PathMATCH = "`r`nMATCH p=$Ptype((x)-[:$Edge*$Hop]->(y))" 
        # Where
        $SourceWHERE = if($SourceWHERE){"`r`nWHERE $SourceWHERE"}else{$Null}
        $TargetWHERE = if($SourceType -eq $TargetType -OR $SourceType -eq 'Base' -OR $TargetType -eq 'Base'){
                            if($TargetWHERE){"`r`nWHERE y<>x AND $TargetWHERE"}else{"`r`nWHERE y<>x"}
                            }Else{if($TargetWHERE){"`r`nWHERE $targetWHERE"}}
        $EdgeWHERE   = if($EdgeWHERE){"`r`nWHERE $EdgeWHERE"}else{$Null}
        # With
        $WITH = if($WITH){"`r`nWITH $WITH"}else{
            if(($Cypher -AND -Not $Raw) -OR $Return){$Null}Else{
                "`r`nWITH p, LENGTH(p) as ln,`r`n[a in NODES(p)|a.name] as nd,`r`n[b in NODES(p)|[d IN LABELS(b) WHERE NOT d  =~ '^Base$|^AZBase$'][0]] as lbl,`r`n[c IN RELATIONSHIPS(p)|TYPE(c)] as tp"
                }}
        # Return
        $RTRN = if($RETURN){"`r`nRETURN $RETURN"}Else{
            if($Cypher -AND -Not$Raw){"`r`nRETURN p"}Else{
                "`r`nRETURN {Lngth:ln, Nodes:nd, Labels:lbl, EdgeTypes:tp} AS Obj"
                }}}
    ## COLLECT QUERIES
    Process{
        $Source = if(-Not$DynSource.Value){'*'}Else{$DynSource.Value}
        $Target = if(-Not$DynTarget.Value){'*'}Else{$DynTarget.Value}
        $QueryList = $(foreach($Src in $Source){
            $SrcMap = if($Source -ne '*'){" {name:'$Src'}"}
            $SrcMATCH = "MATCH (x${SrcType}$SrcMap)$SourceWHERE"
            foreach($tgt in $Target){
                $TgtMap = if($Target -ne '*'){" {name:'$Tgt'}"}
                $TgtMATCH = "`r`nMATCH (y${TgtType}$TgtMap)$TargetWHERE"
                "${SrcMATCH}${tgtMATCH}${PathMATCH}${EdgeWhere}${WITH}${RTRN}"
                }})}
    ## INVOKE CYPHER
    End{if($Cypher){if($CypherDog.CypherToClip){$QueryList|set-clipboard};$QueryList}else{
            $Reply=Invoke-Neo4jCypher $QueryList -Raw:$Raw
            if($Raw -OR $Return){$Reply}else{
                if($Reply){$PathObj = $Reply|ToPathObj}
                }
            if($Expand){$PathObj.$Expand}else{$PathObj}
            }}}
#########End

<#
.Synopsis
   New-BloodHoundEdge
.DESCRIPTION
   New BloodHound Edge
.EXAMPLE
   EdgeCreate User Owns User ALICE BOB
#>
function New-BloodHoundEdge{
    [CmdletBinding()]
    [Alias('EdgeCreate')]
    Param(
        # SourceType
        [Parameter(Mandatory=1,Position=0)][Alias('xType','From')][NodeType]$SourceType,
        # Edge
        [Parameter(Mandatory=1,Position=1)][Edgetype]$Edge,
        # TarrgetType
        [Parameter(Mandatory=1,Position=2)][Alias('yType','To')][NodeType]$TargetType,
        ## Source (Dyn/Madat0/Pos2)
        ## Target (Dyn/Madat0/Pos3)
        # Cypher
        [Parameter(Mandatory=0)][Switch]$Cypher
        )
    DynamicParam{
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynNamelist
        $DynSourceList = @($Script:CypherDog."${SourceType}List")
        $DynTargetList = @($Script:CypherDog."${TargetType}List")
        # Prep DynP
        $DynSource = DynP -Name 'Source' -Type 'String[]' -Mandat 1 -Pos 3 -Pipe 1 -VSet ($DynSourceList)
        $DynTarget = DynP -Name 'Target' -Type 'string[]' -Mandat 1 -Pos 4 -Pipe 0 -VSet ($DynTargetList)
        # DynP to Dico
        $Dico.Add("Source",$DynSource)
        $Dico.Add("Target",$DynTarget)
        # Return Dico
        Return $Dico
        }
    ## PREP QUERY BLOCKS
    Begin{$IsACL=if($Edge -in [enum]::GetNames([EdgeACL])){'True'}Else{'False'}}
    Process{foreach($src in $DynSource.value){
        foreach($tgt in $DynTarget.value){
            $Query = "MATCH (x:$SourceType {name:'$Src'})
MATCH (y:$TargetType {name: '$tgt'})
MERGE (x)-[r:$Edge]->(y)
SET r.isacl=$IsACL"
            if($Cypher){if($CypherDog.CypherToClip){$Query|set-clipboard};$Query}else{neo $Query}
            }}}
    End{}###
    }
#End

<#
.Synopsis
   Remove-BloodHoundEdge
.DESCRIPTION
   Remove BloodHound Edge
.EXAMPLE
   EdgeDelete User Owns User ALICE BOB
#>
function Remove-BloodHoundEdge{
    [CmdletBinding()]
    [Alias('EdgeDelete','EdgeRemove')]
    Param(
        # SourceType
        [Parameter(Mandatory=1,Position=0)][Alias('xType','From')][NodeType]$SourceType,
        # Edge
        [Parameter(Mandatory=1,Position=1)][Edgetype]$Edge,
        # TarrgetType
        [Parameter(Mandatory=1,Position=2)][Alias('yType','To')][NodeType]$TargetType,
        ## Source (Dyn/Madat0/Pos2)
        ## Target (Dyn/Madat0/Pos3)
        # Cypher
        [Parameter(Mandatory=0)][Switch]$Cypher
        )
    DynamicParam{
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynNamelist
        $DynSourceList = @($Script:CypherDog."${SourceType}List")
        $DynTargetList = @($Script:CypherDog."${TargetType}List")
        # Prep DynP
        $DynSource = DynP -Name 'Source' -Type 'String[]' -Mandat 1 -Pos 3 -Pipe 1 -VSet ($DynSourceList)
        $DynTarget = DynP -Name 'Target' -Type 'string[]' -Mandat 1 -Pos 4 -Pipe 0 -VSet ($DynTargetList)
        # DynP to Dico
        $Dico.Add("Source",$DynSource)
        $Dico.Add("Target",$DynTarget)
        # Return Dico
        Return $Dico
        }
    Begin{}
    Process{foreach($src in $DynSource.value){
        foreach($tgt in $DynTarget.value){
            # Query
            $Query = "MATCH (x:$SourceType {name:'$Src'})
MATCH (y:$TargetType {name: '$tgt'})
MATCH (x)-[r:$Edge]->(y)
DELETE r"####
            # Action
            if($Cypher){if($CypherDog.CypherToClip){$Query|set-clipboard};$Query}else{neo $Query}
            }}}
    End{}###
    }
#End

<#
.Synopsis
   Get-BloodHoundEdge Info
.DESCRIPTION
   Get BloodHound Edge Info online
.EXAMPLE
   EdgeInfo
#>
function Get-BloodHoundEdgeInfo{
    [Alias('EdgeInfo')]
    Param()
    Start-Process "https://bloodhound.readthedocs.io/en/latest/data-analysis/edges.html"
    }

#endregion #################################################


###########################################################
#region ############################################## PATH

# Get-BloodHoundPath
# Get-BloodHoundPathNodeWeight


<#
.Synopsis
   Get-BloodHoundPath
.DESCRIPTION
   Get BloodHound Path
.EXAMPLE
   Path User Group * 'DOMAIN ADMINS@WHISPERER.LABZ' |ft
#>
function Get-BloodHoundPath{
    [CmdletBinding()]
    [Alias('Path','bh')]
    Param(
        # SourceType
        [Parameter(Mandatory=0,Position=0)][Alias('xType','From')][NodeType]$SourceType='Base',
        # TarrgetType
        [Parameter(Mandatory=0,Position=1)][Alias('yType','To')][NodeType]$TargetType='Base',
        ## Source (Dyn/Madat0/Pos2)
        ## Target (Dyn/Madat0/Pos3)
        # Path Type
        [ValidateSet('Shortest','AllShortest','Any')]
        [Parameter(Mandatory=0)][Alias('pType')][String]$PathType='Shortest',
        # Filter
        [ValidateSet('NoDefault','NoACL','NoGPO','NoSpecial','NoAzure','AzOnly')]
        [Parameter(Mandatory=0)][String[]]$FilterEdge,
        # Exclude
        [Parameter(Mandatory=0)][Edgetype[]]$ExcludeEdge,
        # Include
        [Parameter(Mandatory=0)][Alias('Edge')][Edgetype[]]$IncludeEdge,
        # Path Length
        [Parameter(Mandatory=0)][Alias('Length')][String]$Hop='1..',
        # SourceWhere
        [Parameter(Mandatory=0)][Alias('xWhere')][String]$SourceWhere,
        # TargetWhere
        [Parameter(Mandatory=0)][Alias('yWhere')][String]$TargetWhere,
        # PathWhere
        [Parameter(Mandatory=0)][Alias('Where')][String]$PathWhere,
        # With
        [Parameter(Mandatory=0)][String]$With,
        # Return
        [Parameter(Mandatory=0)][String]$Return,
        # OrderBy
        [Parameter(Mandatory=0)][String]$OrderBy,
        # Limit
        [Parameter(Mandatory=0)][String]$Limit,
        # ObjectID
        [Parameter(Mandatory=0)][Alias('OID')][Switch]$ShowObjectID,
        # Cypher
        [Parameter(Mandatory=0)][Switch]$Cypher,
        # Raw
        [Parameter(Mandatory=0)][Switch]$Raw
        )
    DynamicParam{
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynNamelist
        $DynSourceList = @($Script:CypherDog."${SourceType}List")
        $DynTargetList = @($Script:CypherDog."${TargetType}List")
        # Prep DynP
        $DynSource = DynP -Name 'Source' -Type 'String[]' -Mandat 0 -Pos 2 -Pipe 1 -VSet ($DynSourceList+'*')
        $DynTarget = DynP -Name 'Target' -Type 'string[]' -Mandat 0 -Pos 3 -Pipe 0 -VSet ($DynTargetList+'*')
        # DynP to Dico
        $Dico.Add("Source",$DynSource)
        $Dico.Add("Target",$DynTarget)
        # Return Dico
        Return $Dico
        }
    ## PREP QUERY BLOCKS
    Begin{
        # Src/Tgt Type
        $SrcType = if(-Not$SourceType -OR $SourceType -eq 'Base'){$Null}else{":$SourceType"}
        $TgtType = if(-Not$TargetType -OR $TargetType -eq 'Base'){$Null}else{":$TargetType"}
        # Edge String
        $EdgeParam = @{Include=$IncludeEdge;Exclude=$ExcludeEdge}
        if($FilterEdge){$EdgeParam += @{Filter=$FilterEdge}}
        $EdgeString = EdgeString @EdgeParam
        # Path MATCH
        $pType = Switch($PathType){
            Shortest   {'shortestPath'}
            AllShortest{'allShortestPaths'}
            Any        {$Null}
            }
        $PathMATCH = "`r`nMATCH p=$Ptype((x)-[$EdgeString*$Hop]->(y))"
        # Where
        $SourceWHERE = if($SourceWHERE){"`r`nWHERE $SourceWHERE"}else{$Null}
        $TargetWHERE = if($SourceType -eq $TargetType -OR $SourceType -eq 'Base' -OR $TargetType -eq 'Base'){
                            if($TargetWHERE){"`r`nWHERE y<>x AND $TargetWHERE"}else{"`r`nWHERE y<>x"}
                            }Else{if($TargetWHERE){"`r`nWHERE $targetWHERE"}}
        $PathWHERE   = if($PathWHERE){"`r`nWHERE $PathWHERE"}else{$Null}
        # With
        $WITH = if($WITH){"`r`nWITH $WITH"}else{
            if(($Cypher -AND -Not $Raw) -OR $Return){$Null}Else{
                $Prp = if($ShowObjectID){'objectid'}else{'name'}
                "`r`nWITH p, LENGTH(p) as ln,`r`n[a in NODES(p)|a.$prp] as nd,`r`n[b in NODES(p)|[d IN LABELS(b) WHERE NOT d  =~ '^Base$|^AZBase$'][0]] as lbl,`r`n[c IN RELATIONSHIPS(p)|TYPE(c)] as tp"
                }}
        # Return
        $RTRN = if($RETURN){"`r`nRETURN $RETURN"}Else{
            if($Cypher -AND -Not$Raw){"`r`nRETURN p"}Else{
                "`r`nRETURN {Lngth:ln, Nodes:nd, Labels:lbl, EdgeTypes:tp}"
                }}
        # OrberBy
        $ORDERBY = if($ORDERBY){"`r`nORDER BY $ORDERBY"}
        # Limit
        $LIMIT   = if($LIMIT){"`r`nLIMIT $LIMIT"}
        }
    ## COLLECT QUERIES
    Process{
        $Source = if(-Not$DynSource.Value){'*'}Else{$DynSource.Value}
        $Target = if(-Not$DynTarget.Value){'*'}Else{$DynTarget.Value}
        $QueryList = $(foreach($Src in $Source){
            $SrcMap = if($Source -ne '*'){" {name:'$Src'}"}
            $SrcMATCH = "MATCH (x${SrcType}$SrcMap)$SourceWHERE"
            foreach($tgt in $Target){
                $TgtMap = if($Target -ne '*'){" {name:'$Tgt'}"}
                $TgtMATCH = "`r`nMATCH (y${TgtType}$TgtMap)$TargetWHERE"
                "${SrcMATCH}${tgtMATCH}${PathMATCH}${PathWHERE}${WITH}${RTRN}${ORDERBY}${LIMIT}"
                }})}
    ## INVOKE CYPHER
    End{if($Cypher){if($CypherDog.CypherToClip){$QueryList|set-clipboard};$QueryList}else{
            $Reply=Invoke-Neo4jCypher $QueryList -Raw:$Raw
            if($Raw -OR $Return){$Reply}else{if($Reply){$Reply|TopathObj}}
            }}}
#########End

<#
.Synopsis
   Get-BloodHoundPathNodeWeight
.DESCRIPTION
   Get BloodHound Path Node weight
.EXAMPLE
   $Path | NodeWeight
#>
function Get-BloodHoundPathNodeWeight{
    [Alias('NodeWeight')]
    Param(
        [Parameter(Mandatory=0,ValueFromPipeline=1)][BHEdge[]]$PathObj,
        [Parameter(Mandatory=0)][Switch]$NoTarget,
        [Parameter(Mandatory=0)][Switch]$NoSource
        )
    Begin{[Collections.ArrayList]$All=@()}
    Process{
        foreach($Obj in $PathObj){$Null=$All.add($Obj)}
        }
    End{
        $tgt = ($All|? dist -eq 1)
        $TtlCnt = $Tgt.Count
        $tgtGrp = $tgt|group-object target
        $SrcGrp=$(if($NoSource){$All|? step -ne 0}else{$All})|Group-object Source
        $res = $(foreach($SG in $SrcGrp){$W=($All|? {$_.source -eq $SG.name}).count
            $Pct = [Math]::Round($W/$TTLCnt*100,1)
            [PSCustomObject]@{Type=$SG.Group[0].SourceType;Name=$SG.name;Distance=$($SG.Group.dist|sort-object -Unique|select -first 1);Weight=$W;Impact=$Pct}
            }
        if(-Not$NoTarget){Foreach($TG in $TgtGrp){$W=($All|? {$_.Target -eq $TG.name}).count
            $Pct = [Math]::Round($W/$TTLCnt*100,1)
            [PSCustomObject]@{Type=$TG.Group[0].TargetType;Name=$TG.name;Distance=0;Weight=$W;Impact=$Pct}}}
            )
        $Res|Sort-object distance|sort-object impact -descending
        }}
#####End

#endregion ################################################


###########################################################
###################################################### INIT
if(-Not$CypherDog.Host){
    $CypherDog = [PSCustomObject]@{
        Com          = 'http'
        Host         = 'localhost'
        Port         = 7474
        DB           = 'neo4j'
        Token        = $Null
        CypherToClip = $False
        }
    [Enum]::GetNames([NodeType]) -notmatch 'Base|AZBase'|%{
        $CypherDog|Add-Member -MemberType NoteProperty -Name "$($_)List" -Value $Null
        }
    #CacheNode
    }
#End

###########################################################
####################################################### EOF
