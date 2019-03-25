#### CypherDog2.1 - TR19 - Demos ###

# Cmdlet
BloodHound
CypherDog

#region ############################ Go Fetch

### Get-BloodHoundNode

# Full Syntax 
Get-BloodHoundNode -Type Computer
Get-BloodHoundNode -Type Computer -Name DC_1.SUB.DOMAIN.LOCAL
# Short Syntax
Node Computer
Node Computer | Out-GridView
Node Computer DC_1.DOMAIN.LOCAL
# Get Cypher
Node Computer DC_1.DOMAIN.LOCAL -Cypher

# Multiple Nodes
Node User GARY_CATANIA@SUB.DOMAIN.LOCAL,NIKIA_DIVINE@SUB.DOMAIN.LOCAL,KANISHA_HARPOLE@SUB.DOMAIN.LOCAL | ft
# Pipeline
'GARY_CATANIA@SUB.DOMAIN.LOCAL','NIKIA_DIVINE@SUB.DOMAIN.LOCAL','KANISHA_HARPOLE@SUB.DOMAIN.LOCAL' | Node User | ft

# Filtering (client side)
Node User | where sensitive -eq true | ft
Node Computer | Where operatingsystem -match 10 | where unconstraineddelegation -eq $false | select name,objectsid | ft


### Search-BloodHoundNode (Filtering on server side)

# Search by partial name
Search-BloodHoundNode -Type Group -Key admin | Select-Object name,description | Format-Table
NodeSearch Group admin | ft name,description

# Search by Prop
# Full
Search-BloodHoundNode -Type Computer -Property unconstraineddelegation -Value $true | Select-Object -Property name,domain,objectsid | format-table
# Short
NodeSearch Computer -prop unconstraineddelegation -val true | ft name,domain,objectsid

# Search where prop exists
NodeSearch User -Prop hgtfkh
NodeSearch User -prop hbhblhjb -NotExist -Cypher


## Get-BloodHoundEdge
Get-BloodHoundEdge -SourceType User -Name GARY_CATANIA@SUB.DOMAIN.LOCAL -EdgeType MemberOf -TargetType Group
Get-BloodHoundEdge -SourceType User -Name GARY_CATANIA@SUB.DOMAIN.LOCAL -EdgeType MemberOf -TargetType Group -Degree *

Edge user GARY_CATANIA@SUB.DOMAIN.LOCAL MemberOf Group
Edge user GARY_CATANIA@SUB.DOMAIN.LOCAL MemberOf Group | count
Edge User GARY_CATANIA@SUB.DOMAIN.LOCAL MemberOf Group *
Edge User GARY_CATANIA@SUB.DOMAIN.LOCAL MemberOf Group * | Count
Edge User GARY_CATANIA@SUB.DOMAIN.LOCAL MemberOf Group * -Cypher

WhereTo User GARY_CATANIA@SUB.DOMAIN.LOCAL MemberOf Group
WhereTo User GARY_CATANIA@SUB.DOMAIN.LOCAL MemberOf Group * | ? domain -Match ^sub | ft

## Get-BloodHoundEdgeR
Get-BloodHoundEdgeReverse -SourceType User -EdgeType MemberOf -TargetType Group -Name 'PRE-WINDOWS 2000 COMPATIBLE ACCESS@SUB.DOMAIN.LOCAL' -Degree *
edgeR user MemberOf Group 'PRE-WINDOWS 2000 COMPATIBLE ACCESS@SUB.DOMAIN.LOCAL' *

What user MemberOf Group 'PRE-WINDOWS 2000 COMPATIBLE ACCESS@DOMAIN.LOCAL' *
What Computer HasSession User GARY_CATANIA@SUB.DOMAIN.LOCAL
what Group GenericWrite Group GROUP_1@SUB.DOMAIN.LOCAL


Get-BloodHoundPathShort -SourceType User -Name AZALEE_CASALE@DOMAIN.LOCAL -TargetType Computer -To DC_2.DOMAIN.LOCAL | ft
Path user Computer AZALEE_CASALE@DOMAIN.LOCAL DC_2.DOMAIN.LOCAL | ft 
Path user Computer AZALEE_CASALE@DOMAIN.LOCAL DC_2.DOMAIN.LOCAL NoACL,NoGPO | ft
Path user Computer AZALEE_CASALE@DOMAIN.LOCAL DC_2.DOMAIN.LOCAL NoACL,NoGPO  -Cypher
Path user Computer AZALEE_CASALE@DOMAIN.LOCAL DC_2.DOMAIN.LOCAL NoACL,NoGPO -All | ft
Path user Computer AZALEE_CASALE@DOMAIN.LOCAL DC_2.DOMAIN.LOCAL NoACL,NoGPO -All -Cypher

PathAny user Computer GARY_CATANIA@SUB.DOMAIN.LOCAL DC_2.DOMAIN.LOCAL | ft
PathAny user Computer GARY_CATANIA@SUB.DOMAIN.LOCAL DC_2.DOMAIN.LOCAL -Cypher


#endregion

#region ############################ Feed the Dog

# Create Nodes
New-BloodHoundNode -Type User -Name bob@demo.local
NodeCreate user alice@demo.local

Node user alice@demo.local,bob@demo.local

Nodecreate user alice@demo.local,bob@demo.local -Clone

Node user alice@demo.local,bob@demo.local

NodeUpdate User alice@demo.local,bob@demo.local -Property @{admincount=$true;myprop='myvalue'}
Node user alice@demo.local,bob@demo.local

EdgeCreate user Owns User alice@demo.local -To bob@demo.local
what user Owns User bob@demo.local | name

NodeDelete user bob@demo.local,alice@demo.local -WhatIf
NodeDelete user bob@demo.local,alice@demo.local
NodeDelete user bob@demo.local,alice@demo.local -Force

Node user alice@demo.local,bob@demo.local

try{Node user alice@demo.local,bob@demo.local}catch{}

#endregion

#region ############################ New Tricks

# Notes
Note User GARY_CATANIA@SUB.DOMAIN.LOCAL
NoteUpdate User GARY_CATANIA@SUB.DOMAIN.LOCAL 'hello world'
Note User GARY_CATANIA@SUB.DOMAIN.LOCAL
NoteUpdate User GARY_CATANIA@SUB.DOMAIN.LOCAL 'hello world' -Stamp
NoteUpdate User GARY_CATANIA@SUB.DOMAIN.LOCAL 'This is fine' -Stamp -Overwrite
Note User GARY_CATANIA@SUB.DOMAIN.LOCAL
NoteUpdate User GARY_CATANIA@SUB.DOMAIN.LOCAL -Clear
Note User GARY_CATANIA@SUB.DOMAIN.LOCAL

Nodesearch computer ^DC | NoteUpdate Computer -text 'This is cool'
NodeSearch Computer -Property notes | select name,notes
NodeSearch Computer -Property notes | NoteUpdate Computer -Clear
NodeSearch Computer -Property notes

# EdgeInfo
EdgeInfo AddAllowedToAct
EdgeInfo AddAllowedToAct -Online

### EdgeCount [TopNode]
TopNode Member
TopNode Member -Limit $null
TopNode Member -Domain SUB.DOMAIN.LOCAL -Limit $Null
TopNode Member -Limit $Null -Cypher

TopNode Membership
TopNode AdminBy
TopNode AdminTo
TopNode Logon
TopNode Session

### List [cc. John Lambert]
list AdminBy GARY_CATANIA@SUB.DOMAIN.LOCAL

list AdminTo DC_2.DOMAIN.LOCAL Direct
list AdminTo DC_2.DOMAIN.LOCAL Direct | name
list AdminTo DC_2.DOMAIN.LOCAL Delegated | name
list AdminTo DC_2.DOMAIN.LOCAL Derivative | name
list AdminTo DC_2.DOMAIN.LOCAL Derivative -Cypher

List logon GARY_CATANIA@SUB.DOMAIN.LOCAL
List Session WS_5.SUB.DOMAIN.LOCAL | ft name,objectsid

List Member 'ACCOUNT OPERATORS@DOMAIN.LOCAL'
List Membership WILHELMINA_MARIANI@SUB.DOMAIN.LOCAL

### CrossDomain
CrossDomain Member | ft
CrossDomain Member -Cypher

CrossDomain Session | Out-GridView

### Owned / highValue
Owned Computer
Highvalue Group

### Cheapest path
PathCheap user Computer AZALEE_CASALE@DOMAIN.LOCAL WS_5.DOMAIN.LOCAL | ft
PathCheap user Computer AZALEE_CASALE@DOMAIN.LOCAL WS_5.DOMAIN.LOCAL -Cypher

PathCheap user Computer AZALEE_CASALE@DOMAIN.LOCAL WS_5.DOMAIN.LOCAL NoACL -Include GenericAll| ft
PathCheap user Computer AZALEE_CASALE@DOMAIN.LOCAL WS_5.DOMAIN.LOCAL NoACL -Cypher


### PathCost
Path user Group GARY_CATANIA@SUB.DOMAIN.LOCAL (highValue Group).name | ft
Path user Group GARY_CATANIA@SUB.DOMAIN.LOCAL (highValue Group).name | fixID  | ft
Path user Group GARY_CATANIA@SUB.DOMAIN.LOCAL (highValue Group).name | fixID | pathCost | ft
Path user Group GARY_CATANIA@SUB.DOMAIN.LOCAL (highValue Group).name | fixID | PathCost | select -First 1 | expand path | ft


### PoSh Pipeline Combo ftW
what user MemberOf Group 'SCHEMA ADMINS@DOMAIN.LOCAL' * | name
what user MemberOf Group 'SCHEMA ADMINS@DOMAIN.LOCAL' * | list logon |ft
what user MemberOf Group 'SCHEMA ADMINS@DOMAIN.LOCAL' * | list logon -Domain SUB.DOMAIN.LOCAL | ? operat* -match 10 | ft
what user MemberOf Group 'SCHEMA ADMINS@DOMAIN.LOCAL' * | list logon -Domain SUB.DOMAIN.LOCAL | ? operat* -match 10 | list AdminTo | select name,lastlogon | sort name -unique | sort lastlogon
what user MemberOf Group 'SCHEMA ADMINS@DOMAIN.LOCAL' * | list logon -Domain SUB.DOMAIN.LOCAL | ? operat* -match 10 | list AdminTo |? name -notmatch guest | select name,lastlogon | sort name -unique | sort lastlogon | Export-csv democsv.csv -NoTypeInformation -Force
start-process democsv.csv


### Custom Queries 
DogPost "

MATCH 

p=shortestPath((S:User)-[r:MemberOf|:AdminTo|:HasSession*1..]->(T:Computer)) 

RETURN p

" -x data


### WaldoIO

# Single group
Node Group 'DOMAIN ADMINS@DOMAIN.LOCAL' | Wald0IO | ft

# Multiple Group
HighValue Group | Wald0IO | ft
HighValue Group | Wald0IO | Out-GridView

# Multiple Group Average
HighValue Group | Wald0IO | Wald0IOAvg | ft

### Blacklist Nodes [Probably not enough time to demo, but it's in here...]
start-process https://insinuator.net/2019/01/2019-year-of-the-blue-dog/

## Moar Cypher??
start-process https://insinuator.net/2018/11/the-dog-whisperers-handbook/

#endregion