# CypherDog2.1
PoSh BloodHound Dog Whisperer
aka PowerShell Cmdlets to interact with BloodHound Data via Neo4j REST API

![CypherDog](https://github.com/SadProcessor/CypherDog/blob/master/img/CypherDog.png)


## Index
| Cmdlet | Synopsis |
| :--- | :--- |
| [Get-BloodHoundCmdlet](#get-bloodhoundcmdlet) | BloodHound RTFM - Get Cmdlet | 
| [Send-BloodHoundPost](#send-bloodhoundpost) | BloodHound POST - Cypher to REST API | 
| [Get-BloodHoundNode](#get-bloodhoundnode) | BloodHound Node - Get Node | 
| [Search-BloodHoundNode](#search-bloodhoundnode) | BloodHound Node - Search Node | 
| [New-BloodHoundNode](#new-bloodhoundnode) | BloodHound Node - Create Node | 
| [Set-BloodHoundNode](#set-bloodhoundnode) | BloodHound Node - Update Node | 
| [Remove-BloodHoundNode](#remove-bloodhoundnode) | BloodHound Node - Delete Node | 
| [Get-BloodHoundNodeList](#get-bloodhoundnodelist) | BloodHound Node - Get List | 
| [Get-BloodHoundNodeHighValue](#get-bloodhoundnodehighvalue) | BloodHound Node - Get HighValue | 
| [Get-BloodHoundNodeOwned](#get-bloodhoundnodeowned) | BloodHound Node - Get Owned | 
| [Get-BloodHoundNodeNote](#get-bloodhoundnodenote) | BloodHound Node - Get Note | 
| [Set-BloodHoundNodeNote](#set-bloodhoundnodenote) | BloodHound Node - Set Notes | 
| [Get-BloodHoundBlacklist](#get-bloodhoundblacklist) | BloodHound Node - Get Blacklist | 
| [Set-BloodHoundBlacklist](#set-bloodhoundblacklist) | BloodHound Node - Set Blacklist | 
| [Remove-BloodHoundBlacklist](#remove-bloodhoundblacklist) | BloodHound Node - Remove Blacklist | 
| [Get-BloodHoundEdge](#get-bloodhoundedge) | BloodHound Edge - Get Target | 
| [Get-BloodHoundEdgeReverse](#get-bloodhoundedgereverse) | BloodHound Edge - Get Source | 
| [Get-BloodHoundEdgeCrossDomain](#get-bloodhoundedgecrossdomain) | BloodHound Edge - Get CrossDomain | 
| [Get-BloodHoundEdgeCount](#get-bloodhoundedgecount) | BloodHound Edge - Get Count | 
| [Get-BloodHoundEdgeInfo](#get-bloodhoundedgeinfo) | BloodHound Edge - Get Info | 
| [New-BloodHoundEdge](#new-bloodhoundedge) | BloodHound Edge - Create Edge | 
| [Remove-BloodHoundEdge](#remove-bloodhoundedge) | BloodHound Edge - Delete Edge | 
| [Get-BloodHoundPathShort](#get-bloodhoundpathshort) | BloodHound Path - Get Shortest | 
| [Get-BloodHoundPathAny](#get-bloodhoundpathany) | BloodHound Path - Get Any | 
| [Get-BloodHoundPathCost](#get-bloodhoundpathcost) | BloodHound Path - Get Cost | 
| [Get-BloodHoundPathCheap](#get-bloodhoundpathcheap) | BloodHound Path - Get Cheapest | 
| [Get-BloodHoundWald0IO](#get-bloodhoundwald0io) | BloodHound Path - Get Wald0 Index |
| | |

<br>

###### Go to [Notes](#notes)
____

____

<br>

# **Get-BloodHoundCmdlet**
**Alias**: `BloodHound`, `CypherDog`
###### Back to [Index](#index) 
## Synopsis
BloodHound RTFM - Get Cmdlet

<br>

## Description
Get Bloodhound [CypherDog] Cmdlets

<br>

## Syntax 

```
Get-BloodHoundCmdlet [-Online] [+]
```

<br>

## Parameters

> **Online**


        
|||
|---|---|
|Mandatory|false|
|Type|switch|
|Position|named|
|Default|False|
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>


<br>

## Examples

_-------------------------- EXAMPLE 1 --------------------------_

```powershell
BloodHound
```


<br>


##### Back to [Cmdlet](#get-bloodhoundcmdlet) 

<br>

 
____

<br>

# **Send-BloodHoundPost**
**Alias**: `DogPost`
###### Back to [Index](#index) 
## Synopsis
BloodHound POST - Cypher to REST API

<br>

## Description
Post Cypher Query to DB REST API

DogPost $Query [$Params] [-expand <prop,prop>]

<br>

## Syntax 

```
Send-BloodHoundPost [-Query] <String> [[-Params] <Hashtable>] [[-Expand] <String[]>] [-Profile] [+]
```

<br>

## Parameters

> **Query**


        
|||
|---|---|
|Mandatory|true|
|Type|string|
|Position|1|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Params**


        
|||
|---|---|
|Mandatory|false|
|Type|hashtable|
|Position|2|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Expand**


        
|||
|---|---|
|Mandatory|false|
|Type|string[]|
|Position|3|
|Default|@('data','data')|
|PipelineInput|false|
|Dynamic|False|
|Alias|x|
|||

<br>
 
> **Profile**


        
|||
|---|---|
|Mandatory|false|
|Type|switch|
|Position|named|
|Default|False|
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>


<br>

## Examples

_-------------------------- EXAMPLE 1 --------------------------_
$query="MATCH 

n:User

 RETURN n"

DogPost $Query

<br>

 
_-------------------------- EXAMPLE 2 --------------------------_
$query  = "MATCH 

A:Computer {name: {ParamA}}

 RETURN A"

$Params = @{ParamA="APOLLO.EXTERNAL.LOCAL"}
DogPost $Query $Params

<br>

 
_-------------------------- EXAMPLE 3 --------------------------_

B

 RETURN x"

$Params= @{ParamA="ACHAVARIN@EXTERNAL.LOCAL";ParamB="DOMAIN ADMINS@EXTERNAL.LOCAL"}
DogPost $Query $Params -Expand Data | ToPathObj

<br>

 
_-------------------------- EXAMPLE 4 --------------------------_

```powershell
$Query="MATCH
```

U:User
-[r:MemberOf|:AdminTo*1..]->
C:Computer
   WITH
   U.name as n,
   COUNT
DISTINCT
C
 as c 
   RETURN 
   {Name: n, Count: c} as SingleColumn
   ORDER BY c DESC
   LIMIT 10"
DogPost $Query -x Data

<br>


##### Back to [Cmdlet](#send-bloodhoundpost) 

<br>

 
____

<br>

# **Get-BloodHoundNode**
**Alias**: `Get-Node`, `Node`
###### Back to [Index](#index) 
## Synopsis
BloodHound Node - Get Node

<br>

## Description
Get BloodHound Node by Type and Name(s)

<br>

## Syntax 

```
Get-BloodHoundNode [-Type] {Computer | Domain | Group | User | GPO | OU} [-Label] [-Notes] [-Cypher] [+]
```

<br>

## Parameters

> **Type**


        
|||
|---|---|
|Mandatory|true|
|Type|NodeType|
|Position|1|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Label**


        
|||
|---|---|
|Mandatory|false|
|Type|switch|
|Position|named|
|Default|False|
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Notes**


        
|||
|---|---|
|Mandatory|false|
|Type|switch|
|Position|named|
|Default|False|
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Cypher**


        
|||
|---|---|
|Mandatory|false|
|Type|switch|
|Position|named|
|Default|False|
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Name**


        
|||
|---|---|
|Mandatory||
|Type|string[]|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>


<br>

## Examples

_-------------------------- EXAMPLE 1 --------------------------_

```powershell
Get-BloodhoundNode User
```


<br>

 
_-------------------------- EXAMPLE 2 --------------------------_

```powershell
Node User BRITNI_GIRARDIN@DOMAIN.LOCAL
```


<br>


##### Back to [Cmdlet](#get-bloodhoundnode) 

<br>

 
____

<br>

# **Search-BloodHoundNode**
**Alias**: `NodeSearch`, `Search-Node`
###### Back to [Index](#index) 
## Synopsis
BloodHound Node - Search Node

<br>

## Description
Search Nodes by partial Name or Properties

<br>

## Syntax 

```
Search-BloodHoundNode [[-Type] {Computer | Domain | Group | User | GPO | OU}] [-Key] <Regex> [-Sensitive] [-Cypher] [+]
``` 
```
Search-BloodHoundNode [[-Type] {Computer | Domain | Group | User | GPO | OU}] -Label <String> [-Cypher] [+]
``` 
```
Search-BloodHoundNode [[-Type] {Computer | Domain | Group | User | GPO | OU}] -Label <String> -NotExist [-Cypher] [+]
``` 
```
Search-BloodHoundNode [[-Type] {Computer | Domain | Group | User | GPO | OU}] -Property <String> [-Cypher] [+]
``` 
```
Search-BloodHoundNode [[-Type] {Computer | Domain | Group | User | GPO | OU}] -Property <String> -Value <String> [-Cypher] [+]
``` 
```
Search-BloodHoundNode [[-Type] {Computer | Domain | Group | User | GPO | OU}] -Property <String> -NotExist [-Cypher] [+]
```

<br>

## Parameters

> **Type**

Node Type
        
|||
|---|---|
|Mandatory|false|
|Type|NodeType|
|Position|1|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Property**

Property Name
        
|||
|---|---|
|Mandatory|true|
|Type|string|
|Position|named|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Label**

Label
        
|||
|---|---|
|Mandatory|true|
|Type|string|
|Position|named|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Value**

Property Name & Value
        
|||
|---|---|
|Mandatory|true|
|Type|string|
|Position|named|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **NotExist**

Property/Label doesn't exists
        
|||
|---|---|
|Mandatory|true|
|Type|switch|
|Position|named|
|Default|False|
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Key**

KeyWord
        
|||
|---|---|
|Mandatory|true|
|Type|regex|
|Position|2|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Sensitive**

Case Sensitive
        
|||
|---|---|
|Mandatory|false|
|Type|switch|
|Position|named|
|Default|False|
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Cypher**

Show Cypher
        
|||
|---|---|
|Mandatory|false|
|Type|switch|
|Position|named|
|Default|False|
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>


<br>

## Examples

_-------------------------- EXAMPLE 1 --------------------------_

```powershell
NodeSearch Group admin
```


<br>

 
_-------------------------- EXAMPLE 2 --------------------------_

```powershell
Nodesearch User -Property sensitive -Value $true
```


<br>


##### Back to [Cmdlet](#search-bloodhoundnode) 

<br>

 
____

<br>

# **New-BloodHoundNode**
**Alias**: `New-Node`, `NodeCreate`
###### Back to [Index](#index) 
## Synopsis
BloodHound Node - Create Node

<br>

## Description
Create New Node by type

<br>

## Syntax 

```
New-BloodHoundNode [-Type] {Computer | Domain | Group | User | GPO | OU} [-Name] <String[]> [-Cypher] [+]
``` 
```
New-BloodHoundNode [-Type] {Computer | Domain | Group | User | GPO | OU} [-Name] <String[]> [[-Property] <Hashtable>] [-Cypher] [+]
``` 
```
New-BloodHoundNode [-Type] {Computer | Domain | Group | User | GPO | OU} [-Name] <String[]> -Clone [-Cypher] [+]
```

<br>

## Parameters

> **Type**

Node Type [Mandatory]
        
|||
|---|---|
|Mandatory|true|
|Type|NodeType|
|Position|1|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Name**

Node Name [Mandatory]
        
|||
|---|---|
|Mandatory|true|
|Type|string[]|
|Position|2|
|Default||
|PipelineInput|true (ByValue)|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Property**

Specify Node Properties [Option]
        
|||
|---|---|
|Mandatory|false|
|Type|hashtable|
|Position|3|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Clone**

Clone similar Node Properties [Option]
        
|||
|---|---|
|Mandatory|true|
|Type|switch|
|Position|named|
|Default|False|
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Cypher**

Cypher [Option]
        
|||
|---|---|
|Mandatory|false|
|Type|switch|
|Position|named|
|Default|False|
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>


<br>

## Examples

_-------------------------- EXAMPLE 1 --------------------------_

```powershell
New-BloodHoundNode -Type User -name Bob
```


<br>

 
_-------------------------- EXAMPLE 2 --------------------------_

```powershell
NodeCreate User Bob
```


<br>


##### Back to [Cmdlet](#new-bloodhoundnode) 

<br>

 
____

<br>

# **Set-BloodHoundNode**
**Alias**: `NodeUpdate`, `Set-Node`
###### Back to [Index](#index) 
## Synopsis
BloodHound Node - Update Node

<br>

## Description
Update BloodHound Node Properties

<br>

## Syntax 

```
Set-BloodHoundNode [-Type] {Computer | Domain | Group | User | GPO | OU} [-Cypher] [+]
``` 
```
Set-BloodHoundNode [-Type] {Computer | Domain | Group | User | GPO | OU} -Delete [-Cypher] [+]
``` 
```
Set-BloodHoundNode [-Type] {Computer | Domain | Group | User | GPO | OU} [-Cypher] -Label [+]
``` 
```
Set-BloodHoundNode [-Type] {Computer | Domain | Group | User | GPO | OU} -Delete [-Cypher] -Label [+]
```

<br>

## Parameters

> **Type**


        
|||
|---|---|
|Mandatory|true|
|Type|NodeType|
|Position|1|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Delete**


        
|||
|---|---|
|Mandatory|true|
|Type|switch|
|Position|named|
|Default|False|
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Cypher**


        
|||
|---|---|
|Mandatory|false|
|Type|switch|
|Position|named|
|Default|False|
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Label**


        
|||
|---|---|
|Mandatory|true|
|Type|switch|
|Position|named|
|Default|False|
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Name**


        
|||
|---|---|
|Mandatory||
|Type|string[]|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>
 
> **Property**


        
|||
|---|---|
|Mandatory||
|Type|hashtable|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>


<br>

## Examples

_-------------------------- EXAMPLE 1 --------------------------_

```powershell
Set-BloodHoundNode User Bob @{MyProp='This'}
```


<br>


##### Back to [Cmdlet](#set-bloodhoundnode) 

<br>

 
____

<br>

# **Remove-BloodHoundNode**
**Alias**: `NodeDelete`, `Remove-Node`
###### Back to [Index](#index) 
## Synopsis
BloodHound Node - Delete Node

<br>

## Description
Delete Bloodhound Node from Database

<br>

## Syntax 

```
Remove-BloodHoundNode [-Type] {Computer | Domain | Group | User | GPO | OU} [-Force] [-Cypher] [?] [+]
```

<br>

## Parameters

> **Type**

Node Type [Mandatory]
        
|||
|---|---|
|Mandatory|true|
|Type|NodeType|
|Position|1|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Force**

Force (Skip Confirm)
        
|||
|---|---|
|Mandatory|false|
|Type|switch|
|Position|named|
|Default|False|
|PipelineInput|false|
|Dynamic|False|
|Alias|x|
|||

<br>
 
> **Cypher**

Force (Skip Confirm)
        
|||
|---|---|
|Mandatory|false|
|Type|switch|
|Position|named|
|Default|False|
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Name**


        
|||
|---|---|
|Mandatory||
|Type|string[]|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>


<br>

## Examples

_-------------------------- EXAMPLE 1 --------------------------_

```powershell
Remove-BloodhoundNode Remove-BloodHoundNode -Type User -Name Bob
```


<br>

 
_-------------------------- EXAMPLE 2 --------------------------_

```powershell
NodeDelete User Bob -Force
```


<br>


##### Back to [Cmdlet](#remove-bloodhoundnode) 

<br>

 
____

<br>

# **Get-BloodHoundNodeList**
**Alias**: `List`, `NodeList`
###### Back to [Index](#index) 
## Synopsis
BloodHound Node - Get List

<br>

## Description
List BloodHound nodes per Edge

<br>

## Syntax 

```
Get-BloodHoundNodeList [-Type] <String> [+]
```

<br>

## Parameters

> **Type**


        
|||
|---|---|
|Mandatory|true|
|Type|string|
|Position|1|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Name**


        
|||
|---|---|
|Mandatory||
|Type|string|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>
 
> **Domain**


        
|||
|---|---|
|Mandatory||
|Type|string|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>
 
> **Cypher**


        
|||
|---|---|
|Mandatory||
|Type|switch|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>


<br>

## Examples

_-------------------------- EXAMPLE 1 --------------------------_

```powershell
List Membership ALBINA_BRASHEAR@DOMAIN.LOCAL
```


<br>


##### Back to [Cmdlet](#get-bloodhoundnodelist) 

<br>

 
____

<br>

# **Get-BloodHoundNodeHighValue**
**Alias**: `Get-NodeHighValue`, `HighValue`
###### Back to [Index](#index) 
## Synopsis
BloodHound Node - Get HighValue

<br>

## Description
Get Bloodhound HighValueNode

<br>

## Syntax 

```
Get-BloodHoundNodeHighValue [[-Type] <String>] [+]
```

<br>

## Parameters

> **Type**


        
|||
|---|---|
|Mandatory|false|
|Type|string|
|Position|1|
|Default|User|
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Domain**


        
|||
|---|---|
|Mandatory||
|Type|string|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>


<br>

## Examples

_-------------------------- EXAMPLE 1 --------------------------_

```powershell
HighValue User
```


<br>


##### Back to [Cmdlet](#get-bloodhoundnodehighvalue) 

<br>

 
____

<br>

# **Get-BloodHoundNodeOwned**
**Alias**: `Get-NodeOwned`, `Owned`
###### Back to [Index](#index) 
## Synopsis
BloodHound Node - Get Owned

<br>

## Description
Get BloodHound Owned Nodes per type

<br>

## Syntax 

```
Get-BloodHoundNodeOwned [[-Type] <String>] [+]
```

<br>

## Parameters

> **Type**


        
|||
|---|---|
|Mandatory|false|
|Type|string|
|Position|1|
|Default|Computer|
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Domain**


        
|||
|---|---|
|Mandatory||
|Type|string|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>


<br>

## Examples

_-------------------------- EXAMPLE 1 --------------------------_

```powershell
Owned Computer
```


<br>


##### Back to [Cmdlet](#get-bloodhoundnodeowned) 

<br>

 
____

<br>

# **Get-BloodHoundNodeNote**
**Alias**: `NodeNote`, `Note`
###### Back to [Index](#index) 
## Synopsis
BloodHound Node - Get Note

<br>

## Description
Get BloodHound Node Notes

<br>

## Syntax 

```
Get-BloodHoundNodeNote [-Type] {Computer | Domain | Group | User | GPO | OU} [-Cypher] [+]
```

<br>

## Parameters

> **Type**


        
|||
|---|---|
|Mandatory|true|
|Type|NodeType|
|Position|1|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Cypher**


        
|||
|---|---|
|Mandatory|false|
|Type|switch|
|Position|named|
|Default|False|
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Name**


        
|||
|---|---|
|Mandatory||
|Type|string[]|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>


<br>

## Examples

_-------------------------- EXAMPLE 1 --------------------------_

```powershell
note user ALBINA_BRASHEAR@DOMAIN.LOCAL
```


<br>


##### Back to [Cmdlet](#get-bloodhoundnodenote) 

<br>

 
____

<br>

# **Set-BloodHoundNodeNote**
**Alias**: `NoteUpdate`, `Set-NodeNote`
###### Back to [Index](#index) 
## Synopsis
BloodHound Node - Set Notes

<br>

## Description
Set BloodHound Node Notes

<br>

## Syntax 

```
Set-BloodHoundNodeNote [-Type] {Computer | Domain | Group | User | GPO | OU} [-Overwrite] [-Stamp] [-Cypher] [+]
``` 
```
Set-BloodHoundNodeNote [-Type] {Computer | Domain | Group | User | GPO | OU} -Clear [-Cypher] [+]
```

<br>

## Parameters

> **Type**

Node Type [Mandatory]
        
|||
|---|---|
|Mandatory|true|
|Type|NodeType|
|Position|1|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Overwrite**

Overwrite
        
|||
|---|---|
|Mandatory|false|
|Type|switch|
|Position|named|
|Default|False|
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Stamp**

Stamp
        
|||
|---|---|
|Mandatory|false|
|Type|switch|
|Position|named|
|Default|False|
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Clear**

Cypher
        
|||
|---|---|
|Mandatory|true|
|Type|switch|
|Position|named|
|Default|False|
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Cypher**

Cypher
        
|||
|---|---|
|Mandatory|false|
|Type|switch|
|Position|named|
|Default|False|
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Name**


        
|||
|---|---|
|Mandatory||
|Type|string[]|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>
 
> **Text**


        
|||
|---|---|
|Mandatory||
|Type|string|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>


<br>

## Examples

_-------------------------- EXAMPLE 1 --------------------------_

```powershell
NoteUpdate user ALBINA_BRASHEAR@DOMAIN.LOCAL 'HelloWorld'
```


<br>


##### Back to [Cmdlet](#set-bloodhoundnodenote) 

<br>

 
____

<br>

# **Get-BloodHoundBlacklist**
**Alias**: `Blacklist`, `Get-Blacklist`
###### Back to [Index](#index) 
## Synopsis
BloodHound Node - Get Blacklist

<br>

## Description
Get BloodHound Node Blacklist

<br>

## Syntax 

```
Get-BloodHoundBlacklist [-Type] {Computer | Domain | Group | User | GPO | OU} [+]
```

<br>

## Parameters

> **Type**


        
|||
|---|---|
|Mandatory|true|
|Type|NodeType|
|Position|1|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>


<br>

## Examples

_-------------------------- EXAMPLE 1 --------------------------_

```powershell
Blacklist User
```


<br>


##### Back to [Cmdlet](#get-bloodhoundblacklist) 

<br>

 
____

<br>

# **Set-BloodHoundBlacklist**
**Alias**: `BlacklistAdd`, `Set-Blacklist`
###### Back to [Index](#index) 
## Synopsis
BloodHound Node - Set Blacklist

<br>

## Description
Set BloodHound Blacklist Node

<br>

## Syntax 

```
Set-BloodHoundBlacklist [-Type] {Computer | Domain | Group | User | GPO | OU} [+]
```

<br>

## Parameters

> **Type**


        
|||
|---|---|
|Mandatory|true|
|Type|NodeType|
|Position|1|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Name**


        
|||
|---|---|
|Mandatory||
|Type|string[]|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>
 
> **Cypher**


        
|||
|---|---|
|Mandatory||
|Type|switch|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>


<br>

## Examples

_-------------------------- EXAMPLE 1 --------------------------_

```powershell
BlacklistUpdate User Bob
```


<br>


##### Back to [Cmdlet](#set-bloodhoundblacklist) 

<br>

 
____

<br>

# **Remove-BloodHoundBlacklist**
**Alias**: `BlacklistDelete`, `Remove-Blacklist`
###### Back to [Index](#index) 
## Synopsis
BloodHound Node - Remove Blacklist

<br>

## Description
Remove Node from blacklist

<br>

## Syntax 

```
Remove-BloodHoundBlacklist [-Type] {Computer | Domain | Group | User | GPO | OU} [+]
```

<br>

## Parameters

> **Type**


        
|||
|---|---|
|Mandatory|true|
|Type|NodeType|
|Position|1|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> ****


        
|||
|---|---|
|Mandatory||
|Type||
|Position||
|Default||
|PipelineInput||
|Dynamic||
|Alias||
|||

<br>
 
> ****


        
|||
|---|---|
|Mandatory||
|Type||
|Position||
|Default||
|PipelineInput||
|Dynamic||
|Alias||
|||

<br>


<br>

## Examples

_-------------------------- EXAMPLE 1 --------------------------_

```powershell
BlacklistDelete User Bob
```


<br>


##### Back to [Cmdlet](#remove-bloodhoundblacklist) 

<br>

 
____

<br>

# **Get-BloodHoundEdge**
**Alias**: `Edge`, `Get-Edge`, `WhereTo`
###### Back to [Index](#index) 
## Synopsis
BloodHound Edge - Get Target

<br>

## Description
Specify Source Name / Return Target

<br>

## Syntax 

```
Get-BloodHoundEdge [-SourceType] {Computer | Domain | Group | User | GPO | OU} [+]
```

<br>

## Parameters

> **SourceType**


        
|||
|---|---|
|Mandatory|true|
|Type|NodeType|
|Position|1|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Name**


        
|||
|---|---|
|Mandatory||
|Type|string[]|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>
 
> **EdgeType**


        
|||
|---|---|
|Mandatory||
|Type|EdgeType|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>
 
> **TargetType**


        
|||
|---|---|
|Mandatory||
|Type|NodeType|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>
 
> **Degree**


        
|||
|---|---|
|Mandatory||
|Type|string|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>
 
> **Cypher**


        
|||
|---|---|
|Mandatory||
|Type|switch|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>


<br>

## Examples

_-------------------------- EXAMPLE 1 --------------------------_

```powershell
Edge user ALBINA_BRASHEAR@DOMAIN.LOCAL MemberOf Group
```


<br>


##### Back to [Cmdlet](#get-bloodhoundedge) 

<br>

 
____

<br>

# **Get-BloodHoundEdgeReverse**
**Alias**: `EdgeR`, `Get-EdgeR`, `What`
###### Back to [Index](#index) 
## Synopsis
BloodHound Edge - Get Source

<br>

## Description
Specify Target Name / Return Source

<br>

## Syntax 

```
Get-BloodHoundEdgeReverse [-SourceType] {Computer | Domain | Group | User | GPO | OU} [-EdgeType] {MemberOf | HasSession | AdminTo | TrustedBy | AllExtendedRights | AddMember | ForceChangePassword | GenericAll | GenericWrite | Owns | WriteDacl | WriteOwner | ReadLAPSPassword | Contains | GpLink | CanRDP | ExecuteDCOM | AllowedToDelegate} [-TargetType] {Computer | Domain | Group | User | GPO | OU} [+]
```

<br>

## Parameters

> **SourceType**


        
|||
|---|---|
|Mandatory|true|
|Type|NodeType|
|Position|1|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **EdgeType**


        
|||
|---|---|
|Mandatory|true|
|Type|EdgeType|
|Position|2|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **TargetType**


        
|||
|---|---|
|Mandatory|true|
|Type|NodeType|
|Position|3|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Name**


        
|||
|---|---|
|Mandatory||
|Type|string[]|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>
 
> **Degree**


        
|||
|---|---|
|Mandatory||
|Type|string|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>
 
> **Cypher**


        
|||
|---|---|
|Mandatory||
|Type|switch|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>


<br>

## Examples

_-------------------------- EXAMPLE 1 --------------------------_

```powershell
EdgeR User MemberOf Group ADMINISTRATORS@SUB.DOMAIN.LOCAL
```


<br>


##### Back to [Cmdlet](#get-bloodhoundedgereverse) 

<br>

 
____

<br>

# **Get-BloodHoundEdgeCrossDomain**
**Alias**: `CrossDomain`
###### Back to [Index](#index) 
## Synopsis
BloodHound Edge - Get CrossDomain

<br>

## Description
Get BloodHound Cross Domain Member|Session Relationships

<br>

## Syntax 

```
Get-BloodHoundEdgeCrossDomain [-Type] <String> [-Cypher] [+]
```

<br>

## Parameters

> **Type**


        
|||
|---|---|
|Mandatory|true|
|Type|string|
|Position|1|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Cypher**


        
|||
|---|---|
|Mandatory|false|
|Type|switch|
|Position|named|
|Default|False|
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>


<br>

## Examples

_-------------------------- EXAMPLE 1 --------------------------_

```powershell
Get-BloodHoundCrossDomain Session
```


<br>

 
_-------------------------- EXAMPLE 2 --------------------------_

```powershell
CrossDomain Member
```


<br>


##### Back to [Cmdlet](#get-bloodhoundedgecrossdomain) 

<br>

 
____

<br>

# **Get-BloodHoundEdgeCount**
**Alias**: `EdgeCount`, `TopNode`
###### Back to [Index](#index) 
## Synopsis
BloodHound Edge - Get Count

<br>

## Description
Get Top Nodes By Edge Count

<br>

## Syntax 

```
Get-BloodHoundEdgeCount [-type] <String> [-Limit <Int32>] [-Cypher] [+]
```

<br>

## Parameters

> **type**


        
|||
|---|---|
|Mandatory|true|
|Type|string|
|Position|1|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Limit**


        
|||
|---|---|
|Mandatory|false|
|Type|int|
|Position|named|
|Default|5|
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Cypher**


        
|||
|---|---|
|Mandatory|false|
|Type|switch|
|Position|named|
|Default|False|
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Domain**


        
|||
|---|---|
|Mandatory||
|Type|string|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>


<br>

## Examples

_-------------------------- EXAMPLE 1 --------------------------_

```powershell
EdgeCount Membership
```


<br>


##### Back to [Cmdlet](#get-bloodhoundedgecount) 

<br>

 
____

<br>

# **Get-BloodHoundEdgeInfo**
**Alias**: `EdgeInfo`, `Get-EdgeInfo`
###### Back to [Index](#index) 
## Synopsis
BloodHound Edge - Get Info

<br>

## Description
Get BloodHound Edge Info [online]

<br>

## Syntax 

```
Get-BloodHoundEdgeInfo [-Type] {MemberOf | HasSession | AdminTo | TrustedBy | AllExtendedRights | AddMember | ForceChangePassword | GenericAll | GenericWrite | Owns | WriteDacl | WriteOwner | ReadLAPSPassword | Contains | GpLink | CanRDP | ExecuteDCOM | AllowedToDelegate} [-Online] [+]
```

<br>

## Parameters

> **Type**


        
|||
|---|---|
|Mandatory|true|
|Type|EdgeType|
|Position|1|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Online**


        
|||
|---|---|
|Mandatory|false|
|Type|switch|
|Position|named|
|Default|False|
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>


<br>

## Examples

_-------------------------- EXAMPLE 1 --------------------------_

```powershell
EdgeInfo MemberOf
```


<br>

 
_-------------------------- EXAMPLE 2 --------------------------_

```powershell
EdgeInfo MemberOf -Online
```


<br>


##### Back to [Cmdlet](#get-bloodhoundedgeinfo) 

<br>

 
____

<br>

# **New-BloodHoundEdge**
**Alias**: `EdgeCreate`, `New-Edge`
###### Back to [Index](#index) 
## Synopsis
BloodHound Edge - Create Edge

<br>

## Description
Create Edges Between nodes

<br>

## Syntax 

```
New-BloodHoundEdge [-SourceType] {Computer | Domain | Group | User | GPO | OU} [-EdgeType] {MemberOf | HasSession | AdminTo | TrustedBy | AllExtendedRights | AddMember | ForceChangePassword | GenericAll | GenericWrite | Owns | WriteDacl | WriteOwner | ReadLAPSPassword | Contains | GpLink | CanRDP | ExecuteDCOM | AllowedToDelegate} [-TargetType] {Computer | Domain | Group | User | GPO | OU} [+]
```

<br>

## Parameters

> **SourceType**


        
|||
|---|---|
|Mandatory|true|
|Type|NodeType|
|Position|1|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **EdgeType**


        
|||
|---|---|
|Mandatory|true|
|Type|EdgeType|
|Position|2|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **TargetType**


        
|||
|---|---|
|Mandatory|true|
|Type|NodeType|
|Position|3|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Name**


        
|||
|---|---|
|Mandatory||
|Type|string[]|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>
 
> **To**


        
|||
|---|---|
|Mandatory||
|Type|string[]|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>
 
> **Cypher**


        
|||
|---|---|
|Mandatory||
|Type|switch|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>


<br>

## Examples

_-------------------------- EXAMPLE 1 --------------------------_

```powershell
EdgeCreate User MemberOf Group ALBINA_BRASHEAR@DOMAIN.LOCAL ADMINISTRATORS@DOMAIN.LOCAL
```


<br>


##### Back to [Cmdlet](#new-bloodhoundedge) 

<br>

 
____

<br>

# **Remove-BloodHoundEdge**
**Alias**: `EdgeDelete`, `Remove-Edge`
###### Back to [Index](#index) 
## Synopsis
BloodHound Edge - Delete Edge

<br>

## Description
Remove Edge between nodes

<br>

## Syntax 

```
Remove-BloodHoundEdge [-SourceType] {Computer | Domain | Group | User | GPO | OU} [-EdgeType] {MemberOf | HasSession | AdminTo | TrustedBy | AllExtendedRights | AddMember | ForceChangePassword | GenericAll | GenericWrite | Owns | WriteDacl | WriteOwner | ReadLAPSPassword | Contains | GpLink | CanRDP | ExecuteDCOM | AllowedToDelegate} [-TargetType] {Computer | Domain | Group | User | GPO | OU} [?] [+]
```

<br>

## Parameters

> **SourceType**


        
|||
|---|---|
|Mandatory|true|
|Type|NodeType|
|Position|1|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **EdgeType**


        
|||
|---|---|
|Mandatory|true|
|Type|EdgeType|
|Position|2|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **TargetType**


        
|||
|---|---|
|Mandatory|true|
|Type|NodeType|
|Position|3|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Name**


        
|||
|---|---|
|Mandatory||
|Type|string[]|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>
 
> **To**


        
|||
|---|---|
|Mandatory||
|Type|string[]|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>
 
> **Cypher**


        
|||
|---|---|
|Mandatory||
|Type|switch|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>


<br>

## Examples

_-------------------------- EXAMPLE 1 --------------------------_

```powershell
EdgeDelete User MemberOf Group ALBINA_BRASHEAR@DOMAIN.LOCAL ADMINISTRATORS@DOMAIN.LOCAL
```


<br>


##### Back to [Cmdlet](#remove-bloodhoundedge) 

<br>

 
____

<br>

# **Get-BloodHoundPathShort**
**Alias**: `Get-PathShort`, `Path`
###### Back to [Index](#index) 
## Synopsis
BloodHound Path - Get Shortest

<br>

## Description
Get BloodHound Shortest/AllShortest Path

<br>

## Syntax 

```
Get-BloodHoundPathShort [-SourceType] {Computer | Domain | Group | User | GPO | OU} [-TargetType] {Computer | Domain | Group | User | GPO | OU} [+]
```

<br>

## Parameters

> **SourceType**


        
|||
|---|---|
|Mandatory|true|
|Type|NodeType|
|Position|1|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **TargetType**


        
|||
|---|---|
|Mandatory|true|
|Type|NodeType|
|Position|2|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Name**


        
|||
|---|---|
|Mandatory||
|Type|string[]|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>
 
> **To**


        
|||
|---|---|
|Mandatory||
|Type|string[]|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>
 
> **Edge**


        
|||
|---|---|
|Mandatory||
|Type|string[]|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>
 
> **Exclude**


        
|||
|---|---|
|Mandatory||
|Type|EdgeType[]|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>
 
> **Include**


        
|||
|---|---|
|Mandatory||
|Type|EdgeType[]|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>
 
> **MaxHop**


        
|||
|---|---|
|Mandatory||
|Type|int|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>
 
> **BlackL**


        
|||
|---|---|
|Mandatory||
|Type|switch|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>
 
> **All**


        
|||
|---|---|
|Mandatory||
|Type|switch|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>
 
> **Cypher**


        
|||
|---|---|
|Mandatory||
|Type|switch|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>


<br>

## Examples

_-------------------------- EXAMPLE 1 --------------------------_

```powershell
Path user Group ALBINA_BRASHEAR@DOMAIN.LOCAL 'SCHEMA ADMINS@DOMAIN.LOCAL'
```


<br>


##### Back to [Cmdlet](#get-bloodhoundpathshort) 

<br>

 
____

<br>

# **Get-BloodHoundPathAny**
**Alias**: `Get-PathAny`, `PathAny`
###### Back to [Index](#index) 
## Synopsis
BloodHound Path - Get Any

<br>

## Description
Get 'Any' Path

<br>

## Syntax 

```
Get-BloodHoundPathAny [-SourceType] {Computer | Domain | Group | User | GPO | OU} [-TargetType] {Computer | Domain | Group | User | GPO | OU} [+]
```

<br>

## Parameters

> **SourceType**


        
|||
|---|---|
|Mandatory|true|
|Type|NodeType|
|Position|1|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **TargetType**


        
|||
|---|---|
|Mandatory|true|
|Type|NodeType|
|Position|2|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Name**


        
|||
|---|---|
|Mandatory||
|Type|string[]|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>
 
> **To**


        
|||
|---|---|
|Mandatory||
|Type|string[]|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>
 
> **Edge**


        
|||
|---|---|
|Mandatory||
|Type|string[]|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>
 
> **Exclude**


        
|||
|---|---|
|Mandatory||
|Type|EdgeType[]|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>
 
> **Include**


        
|||
|---|---|
|Mandatory||
|Type|EdgeType[]|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>
 
> **MaxHop**


        
|||
|---|---|
|Mandatory||
|Type|int|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>
 
> **BlackL**


        
|||
|---|---|
|Mandatory||
|Type|switch|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>
 
> **Cypher**


        
|||
|---|---|
|Mandatory||
|Type|switch|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>


<br>

## Examples

_-------------------------- EXAMPLE 1 --------------------------_

```powershell
PathAny user Group ALBINA_BRASHEAR@DOMAIN.LOCAL 'SCHEMA ADMINS@DOMAIN.LOCAL'
```


<br>


##### Back to [Cmdlet](#get-bloodhoundpathany) 

<br>

 
____

<br>

# **Get-BloodHoundPathCost**
**Alias**: `PathCost`
###### Back to [Index](#index) 
## Synopsis
BloodHound Path - Get Cost

<br>

## Description
Get BloodHound Path Cost

<br>

## Syntax 

```
Get-BloodHoundPathCost [-Path] <BHEdge> [+]
```

<br>

## Parameters

> **Path**


        
|||
|---|---|
|Mandatory|true|
|Type|BHEdge|
|Position|1|
|Default||
|PipelineInput|true (ByValue)|
|Dynamic|False|
|Alias||
|||

<br>


<br>

## Examples

_-------------------------- EXAMPLE 1 --------------------------_

```powershell
path user group GARY_CATANIA@SUB.DOMAIN.LOCAL 'RDS ENDPOINT SERVERS@DOMAIN.LOCAL' -all | pathcost
```


<br>


##### Back to [Cmdlet](#get-bloodhoundpathcost) 

<br>

 
____

<br>

# **Get-BloodHoundPathCheap**
**Alias**: `Get-PathCheap`, `PathCheap`
###### Back to [Index](#index) 
## Synopsis
BloodHound Path - Get Cheapest

<br>

## Description
Get BloodHound Cheapest Path

<br>

## Syntax 

```
Get-BloodHoundPathCheap [-SourceType] {Computer | Domain | Group | User | GPO | OU} [-TargetType] {Computer | Domain | Group | User | GPO | OU} [+]
```

<br>

## Parameters

> **SourceType**


        
|||
|---|---|
|Mandatory|true|
|Type|NodeType|
|Position|1|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **TargetType**


        
|||
|---|---|
|Mandatory|true|
|Type|NodeType|
|Position|2|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Name**


        
|||
|---|---|
|Mandatory||
|Type|string|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>
 
> **To**


        
|||
|---|---|
|Mandatory||
|Type|string|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>
 
> **Edge**


        
|||
|---|---|
|Mandatory||
|Type|string[]|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>
 
> **Exclude**


        
|||
|---|---|
|Mandatory||
|Type|EdgeType[]|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>
 
> **Include**


        
|||
|---|---|
|Mandatory||
|Type|EdgeType[]|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>
 
> **Expand**


        
|||
|---|---|
|Mandatory||
|Type|int|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>
 
> **BlackL**


        
|||
|---|---|
|Mandatory||
|Type|switch|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>
 
> **Cypher**


        
|||
|---|---|
|Mandatory||
|Type|switch|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>
 
> **Limit**


        
|||
|---|---|
|Mandatory||
|Type|int|
|Position||
|Default||
|PipelineInput||
|Dynamic|True|
|Alias||
|||

<br>


<br>

## Examples

_-------------------------- EXAMPLE 1 --------------------------_

```powershell
pathcheap user group GARY_CATANIA@SUB.DOMAIN.LOCAL 'RDS ENDPOINT SERVERS@DOMAIN.LOCAL'
```


<br>


##### Back to [Cmdlet](#get-bloodhoundpathcheap) 

<br>

 
____

<br>

# **Get-BloodHoundWald0IO**
**Alias**: `Get-Wald0IO`, `Wald0IO`
###### Back to [Index](#index) 
## Synopsis
BloodHound Path - Get Wald0 Index

<br>

## Description
Calculate wald0 Index for specified Group

<br>

## Syntax 

```
Get-BloodHoundWald0IO [[-Name] <String>] [[-Direction] <String>] [[-Type] <String>] [[-Edge] <String[]>] [-Exclude {MemberOf | HasSession | AdminTo | TrustedBy | AllExtendedRights | AddMember | ForceChangePassword | GenericAll | GenericWrite | Owns | WriteDacl | WriteOwner | ReadLAPSPassword | Contains | GpLink | CanRDP | ExecuteDCOM | AllowedToDelegate}] [-Include {MemberOf | HasSession | AdminTo | TrustedBy | AllExtendedRights | AddMember | ForceChangePassword | GenericAll | GenericWrite | Owns | WriteDacl | WriteOwner | ReadLAPSPassword | Contains | GpLink | CanRDP | ExecuteDCOM | AllowedToDelegate}] [-DomainOnly] [-BlackL] [-Cypher] [+]
```

<br>

## Parameters

> **Name**


        
|||
|---|---|
|Mandatory|false|
|Type|string|
|Position|1|
|Default||
|PipelineInput|true (ByValue, ByPropertyName)|
|Dynamic|False|
|Alias|TargetGroup|
|||

<br>
 
> **Direction**


        
|||
|---|---|
|Mandatory|false|
|Type|string|
|Position|2|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Type**


        
|||
|---|---|
|Mandatory|false|
|Type|string|
|Position|3|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Edge**


        
|||
|---|---|
|Mandatory|false|
|Type|string[]|
|Position|4|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Exclude**


        
|||
|---|---|
|Mandatory|false|
|Type|EdgeType[]|
|Position|named|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Include**


        
|||
|---|---|
|Mandatory|false|
|Type|EdgeType[]|
|Position|named|
|Default||
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **DomainOnly**


        
|||
|---|---|
|Mandatory|false|
|Type|switch|
|Position|named|
|Default|False|
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **BlackL**


        
|||
|---|---|
|Mandatory|false|
|Type|switch|
|Position|named|
|Default|False|
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>
 
> **Cypher**


        
|||
|---|---|
|Mandatory|false|
|Type|switch|
|Position|named|
|Default|False|
|PipelineInput|false|
|Dynamic|False|
|Alias||
|||

<br>


<br>

## Examples

_-------------------------- EXAMPLE 1 --------------------------_

```powershell
Node Group ADMINISTRATORS@DOMAIN.LOCAL | Wlad0IO
```


<br>


##### Back to [Cmdlet](#get-bloodhoundwald0io) 

<br>


____

____
### Notes

This is it...

That's all Folks
 
____

##### **Version 1.2.3**

##### _Generated on 03/05/2019 13:55:06_

###### Back to [Index](#index)

<br>

____
____
